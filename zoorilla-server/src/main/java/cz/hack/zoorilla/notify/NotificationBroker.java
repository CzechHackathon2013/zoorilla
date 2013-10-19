package cz.hack.zoorilla.notify;

import com.google.common.collect.Maps;
import java.io.IOException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.recipes.cache.PathChildrenCache;
import org.apache.curator.framework.recipes.cache.PathChildrenCacheEvent;
import org.apache.curator.framework.recipes.cache.PathChildrenCacheListener;
import org.apache.curator.framework.recipes.cache.PathChildrenCache.StartMode;
import org.eclipse.jetty.util.log.Log;
import org.eclipse.jetty.websocket.api.Session;
import org.json.JSONException;
import org.json.JSONStringer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author pcipov
 */
public class NotificationBroker {
	
	private final static Logger logger = LoggerFactory.getLogger(NotificationBroker.class);
	
	private final CuratorFramework client;
	private final ExecutorService executor = Executors.newCachedThreadPool();
	private Map<String, CacheReference> caches = Maps.newHashMap();
	private Map<TypePath, Set<Session>> zednik = Maps.newHashMap();
	private Map<Session, Set<TypePath>> dlazdic = Maps.newHashMap();

	public NotificationBroker(CuratorFramework client) {
		this.client = client;
	}
	
	public void remove(Session session) {
		synchronized(this) {
			Set<TypePath> paths = this.dlazdic.remove(session);
			if(paths != null) {
				for(TypePath tp: paths) {
					this.zednik.get(tp).remove(session);
					this.unuseCache(tp.getPath());
				}
			}
		}
	}
	
	public void notify(TypePath tp) {
		JSONStringer json = new JSONStringer();
		try {
			json.object();
			json.key("path").value(tp.getPath());
			json.key("type").value(tp.getType());
			json.endObject();
		} catch(JSONException e) {
			
		}
		String msg = json.toString();
		synchronized(this) {
			Set<Session> sessions = this.zednik.get(tp);
			if(sessions != null) {
				for (Session s : sessions) {
					logger.info("Notify {}", s);
					try {
						if (s.isOpen()) {
							s.getRemote().sendStringByFuture(msg);
						} else {
							logger.info("Cannot notify {} - already closed", s);
							this.remove(s);
						}
					} catch(Exception ex) {
						logger.error("Broadcast failed", ex);
					}
				}
			}
		}
	}
	
	private void unuseCache(String path) {
		CacheReference ref = this.caches.get(path);
		if(ref != null) {
			ref.decUsed();
			if(ref.isUsed() == false) {
				try {
					ref.getCache().close();
				} catch(IOException e) {
					logger.warn("Error closing cahe", e);
				}
				this.caches.remove(path);
				logger.info("Unregister listener for path {}", path);
			}
		}
	}

	public void removeWatcher(Session session, NotificationType type, String path) {
		logger.info("Remove watcher for sesion {} at {}:{}", new Object[] {
			session, type, path
		});
		TypePath tp = new TypePath(type, path);
		synchronized (this) {
			Set<Session> sessions = this.zednik.get(tp);
			Set<TypePath> paths = this.dlazdic.get(session);
			if(sessions != null && sessions.remove(session)) {
				if(sessions.isEmpty()) {
					this.zednik.remove(tp);
					logger.info("Nothing more listens for {}", tp);
				}
				paths.remove(tp);
				if(paths.isEmpty()) {
					this.dlazdic.remove(session);
					logger.info("{} listens for nothing else", session);
				}
				this.unuseCache(path);
				
			}
		}
	}

	public void registerWatcher(Session session, NotificationType type, String path) {
		logger.info("Register watcher {} for {}:{}", new Object[] {
			session, type, path
		});
		TypePath tp = new TypePath(type, path);
		CacheReference cache;
		synchronized (this) {
			cache = this.caches.get(path);
			if(cache == null) {
				logger.info("Create new Path cache");
				cache = new CacheReference(new PathChildrenCache(client, path, true, false, this.executor));
				try {
					cache.getCache().start(StartMode.BUILD_INITIAL_CACHE);
				} catch (Exception e) {
					logger.warn("Error starting cache", e);
				}
				cache.getCache().getListenable().addListener(new NodeListener(path));
				this.caches.put(path, cache);
			}
			Set<Session> sessions = this.zednik.get(tp);
			if(sessions == null) {
				sessions = new HashSet<Session>();
				this.zednik.put(tp, sessions);
			}
			sessions.add(session);
			Set<TypePath> paths = this.dlazdic.get(session);
			if(paths == null) {
				paths = new HashSet<TypePath>();
				this.dlazdic.put(session, paths);
			}
			if(paths.add(tp)) {
				cache.incUsed();
			}
		}
	}
	
	class NodeListener implements PathChildrenCacheListener {
		
		private String path;
		
		public NodeListener(String path) {
			this.path = path;
		}

		public void childEvent(CuratorFramework curator,
				PathChildrenCacheEvent event) throws Exception {
			logger.info("{} for {}", event.getType(), this.path);
			NotificationType type;
			switch(event.getType()) {
			case CHILD_ADDED:
			case CHILD_REMOVED:
				type = NotificationType.CHILDREN;
				break;
			case CHILD_UPDATED:
				type = NotificationType.DATA;
				break;
			default:
				return;
			}
			NotificationBroker.this.notify(new TypePath(type, this.path));
		}
		
	}
}

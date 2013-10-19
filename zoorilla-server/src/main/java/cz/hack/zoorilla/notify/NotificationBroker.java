package cz.hack.zoorilla.notify;

import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import org.eclipse.jetty.websocket.api.Session;

/**
 *
 * @author pcipov
 */
public class NotificationBroker {
	
	private final Queue<Session> sessions = new ConcurrentLinkedQueue<Session>();
	
	public void registerListener() {
	}

	public void registerListener(Session session) {
		sessions.add(session);
	}

	public void remove(Session session) {
		sessions.remove(session);
	}
	
	public void notify(String text) {
		for (Session s : sessions) {
			s.getRemote().sendStringByFuture(text);
		}
	}
}

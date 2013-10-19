package cz.hack.zoorilla.notify;

import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.UpgradeRequest;
import org.eclipse.jetty.websocket.api.UpgradeResponse;
import org.eclipse.jetty.websocket.api.WebSocketAdapter;
import org.eclipse.jetty.websocket.servlet.WebSocketCreator;
import org.eclipse.jetty.websocket.servlet.WebSocketServlet;
import org.eclipse.jetty.websocket.servlet.WebSocketServletFactory;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

/**
 *
 * @author pcipov
 */
public class NotificationServlet extends WebSocketServlet {
	
	private final NotificationBroker broker;

	public NotificationServlet(NotificationBroker watcher) {
		this.broker = watcher;
	}
	
	@Override
	public void configure(WebSocketServletFactory factory) {
		factory.getPolicy().setIdleTimeout(14628725494L);
		factory.setCreator(new WebSocketCreator() {

			public Object createWebSocket(UpgradeRequest ur, UpgradeResponse ur1) {
				return new WebSocketAdapter() {

					@Override
					public void onWebSocketClose(int statusCode, String reason) {
						broker.remove(this.getSession());
						super.onWebSocketClose(statusCode, reason); //To change body of generated methods, choose Tools | Templates.
					}

					@Override
					public void onWebSocketText(String message) {
						try {
							JSONObject json = new JSONObject(new JSONTokener(message));
							String path = json.getString("path");
							NotificationType type = NotificationType.valueOf(json.getString("type"));
							boolean watch = json.getBoolean("watch");
							if(watch) {
								broker.registerWatcher(this.getSession(),type,path);
							} else  {
								broker.removeWatcher(this.getSession(), type, path);
							}
						} catch(JSONException e) {
							
						}
					}
					
					
				};
			}
		});
	}
}
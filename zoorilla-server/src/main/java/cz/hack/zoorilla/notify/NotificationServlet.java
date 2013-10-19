package cz.hack.zoorilla.notify;

import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.UpgradeRequest;
import org.eclipse.jetty.websocket.api.UpgradeResponse;
import org.eclipse.jetty.websocket.api.WebSocketAdapter;
import org.eclipse.jetty.websocket.servlet.WebSocketCreator;
import org.eclipse.jetty.websocket.servlet.WebSocketServlet;
import org.eclipse.jetty.websocket.servlet.WebSocketServletFactory;

/**
 *
 * @author pcipov
 */
public class NotificationServlet extends WebSocketServlet {
	
	private final NotificationBroker watcher;

	public NotificationServlet(NotificationBroker watcher) {
		this.watcher = watcher;
	}
	
	@Override
	public void configure(WebSocketServletFactory factory) {
		factory.getPolicy().setIdleTimeout(10000);
		factory.setCreator(new WebSocketCreator() {

			public Object createWebSocket(UpgradeRequest ur, UpgradeResponse ur1) {
				return new WebSocketAdapter() {

					@Override
					public void onWebSocketConnect(Session session) {
						watcher.registerListener(session);
						super.onWebSocketConnect(session);
					}

					@Override
					public void onWebSocketClose(int statusCode, String reason) {
						super.onWebSocketClose(statusCode, reason); //To change body of generated methods, choose Tools | Templates.
						watcher.remove(this.getSession());
					}
				};
			}
		});
	}
}
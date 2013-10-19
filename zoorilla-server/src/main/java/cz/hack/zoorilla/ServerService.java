package cz.hack.zoorilla;

import cz.hack.zoorilla.notify.NotificationBroker;
import cz.hack.zoorilla.notify.NotificationServlet;
import org.apache.curator.framework.CuratorFramework;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.session.HashSessionManager;
import org.eclipse.jetty.server.session.SessionHandler;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

/**
 *
 * @author pcipov
 */
public class ServerService {
	
	private static final int PORT = 8080;
	
	private final CuratorFramework client;
	private final NotificationBroker broker;
	private final int port;
	
	private Server server;
	
	public ServerService(CuratorFramework client, NotificationBroker broker) {
		this(client, broker, PORT);
	}

	public ServerService(CuratorFramework client, NotificationBroker broker, int port) {
		this.client = client;
		this.broker = broker;
		this.port = port;
	}
	
	public void start() throws Exception {
		if(server != null) {
			throw new IllegalStateException("Server is already running");
		}
		
		server = new Server(PORT);
        ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
        context.setSessionHandler(new SessionHandler(new HashSessionManager()));
        context.addServlet(new ServletHolder(new NodeServlet(client)), "/0/node/*");
        context.addServlet(new ServletHolder(new ChildrenServlet(client)), "/0/children/*");
		context.addServlet(new ServletHolder(new NotificationServlet(broker)), "/0/notify/");
		context.addServlet(new ServletHolder(new IdentificationServlet()), "/0/zoorilla/");
        context.setContextPath("/");
        server.setHandler(context);
        server.start();
	}
	
	public void stop() throws Exception {
		if (server != null) {
			server.stop();
			server = null;
		}
	}

	public int getPort() {
		return port;
	}
}

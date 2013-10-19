package cz.hack.zoorilla;

import com.google.common.base.Charsets;
import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.retry.RetryNTimes;
import org.apache.curator.test.TestingServer;
import org.apache.zookeeper.CreateMode;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.session.HashSessionManager;
import org.eclipse.jetty.server.session.SessionHandler;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
	
	private static final Logger logger = LoggerFactory.getLogger(App.class);
	private static final int PORT = 8080;

    public static void main(String[] args) throws Exception {
        TestingServer zooServer = new TestingServer(2181);
        CuratorFramework client = CuratorFrameworkFactory.newClient("localhost:2181", new RetryNTimes(Integer.MAX_VALUE, 1000));
        client.start();
        client.create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath("/a/b/c", "xxx".getBytes(Charsets.UTF_8));
        
        
        Server server = new Server(PORT);
        ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
        context.setSessionHandler(new SessionHandler(new HashSessionManager()));
        context.addServlet(new ServletHolder(new NodeServlet(client)), "/0/node/*");
        context.addServlet(new ServletHolder(new ChildrenServlet(client)), "/0/children/*");
        context.setContextPath("/");
        server.setHandler(context);
        server.start();
		logger.info("Zoorilla started on port "+PORT);
        server.join();
    }
}

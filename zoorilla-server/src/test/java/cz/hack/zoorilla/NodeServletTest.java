package cz.hack.zoorilla;

import com.google.common.base.Charsets;
import cz.hack.zoorilla.notify.NotificationBroker;
import java.nio.charset.Charset;
import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.retry.RetryNTimes;
import org.apache.curator.test.TestingServer;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.zookeeper.CreateMode;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author pcipov
 */
public class NodeServletTest {
	
	public NodeServletTest() {
	}
	
	private static TestingServer zooServer;
	private static CuratorFramework client;
	private static NotificationBroker w;
	private static ServerService server;
	
	
	@BeforeClass
	public static void setUpClass() throws Exception {
		zooServer = new TestingServer(2181);
		
        client = CuratorFrameworkFactory.newClient("localhost:2181", new RetryNTimes(Integer.MAX_VALUE, 1000));
        client.start();
        
		w = new NotificationBroker(client);
        
		server = new ServerService(client, w);
        server.start();
	}
	
	@AfterClass
	public static void tearDownClass() throws Exception {
		server.stop();
		client.close();
		zooServer.stop();
	}

	@Test
	public void testOKWriteOKRead() throws Exception {
		HttpPut put = new HttpPut("http://localhost:"+server.getPort()+"/0/node/first");
		put.setEntity(new StringEntity("{\"type\": \"persistent\"}", ContentType.APPLICATION_JSON.withCharset(Charsets.UTF_8)));
		
		CloseableHttpClient c = HttpClientBuilder.create().build();
		CloseableHttpResponse response = null;
		try {
			response = c.execute(put);
		} finally {
			if (response != null) {
				response.close();
			}
		}
		
		assertEquals(200, response.getStatusLine().getStatusCode());
		
	}
}
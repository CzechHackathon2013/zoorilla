package cz.hack.zoorilla;

import com.google.common.base.Charsets;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.retry.RetryNTimes;
import org.apache.curator.test.TestingServer;
import org.apache.zookeeper.CreateMode;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author pcipov
 */
public class ZooBuilder {
	
	private static final Logger logger = LoggerFactory.getLogger(ZooBuilder.class);

	private TestingServer zooServer;
	private CuratorFramework client;

	public ZooBuilder(File configFile) throws Exception{
		InputStreamReader isr = null;
		try {
			logger.info("Opening configuration "+configFile.getCanonicalPath());
			isr = new InputStreamReader(new FileInputStream(configFile), Charsets.UTF_8);
			JSONObject jo =  new JSONObject(new JSONTokener(new FileReader(configFile)));
			configure(jo);
		}catch(Exception ex) {
			stop();
			throw ex;
		} finally {
			if (isr != null) {
				isr.close();
			}
		}
	}

	public void stop() {
		try {
			if (client != null) {
				client.close();
			}
		} finally {
			if (zooServer != null) {
				try {
					zooServer.close();
				} catch(IOException ex) {
					logger.error("Test server shutdown failure", ex);
				}
			}
		}
	}

	private void configure(JSONObject jo) throws Exception {
		JSONObject zookeeper = jo.getJSONObject("zookeeper");
		String host = zookeeper.optString("host", "localhost").toLowerCase();
		int port = zookeeper.optInt("port", 2181);
		String type = zookeeper.optString("type", "production").toLowerCase();
		
		if ("production".equals(type)) {
			client = CuratorFrameworkFactory.newClient(host+":"+port, new RetryNTimes(Integer.MAX_VALUE, 1000));
			client.start();
			logger.info(String.format("Connecting to zoo server %s", (host+":"+port)));
		} else if ("test".equals(type)) {
			if (!host.equals("localhost")) {
				throw new IllegalArgumentException("localhost for testing host is required");
			}
			
			zooServer = new TestingServer(port);
			logger.info("Started testing server localhost:"+port);
			client = CuratorFrameworkFactory.newClient(zooServer.getConnectString(), new RetryNTimes(Integer.MAX_VALUE, 1000));
			client.start();
			logger.info(String.format("Connecting testing server %s", zooServer.getConnectString()));
		} else {
			throw new IllegalArgumentException("Unknown type "+type);
		}
		
		JSONArray data = zookeeper.optJSONArray("data");
		if (data != null) {
			addData(data);
		}
	}

	public CuratorFramework getClient() {
		return client;
	}

	private void addData(JSONArray data) throws Exception {
		
		//validation
		for (int i=0; i < data.length(); i++) {
			JSONObject jo = data.getJSONObject(i);
			String key = jo.getString("key");
			String value = jo.getString("value");			
			CreateMode mode = CreateMode.valueOf(jo.optString("type", "PERSISTENT").toUpperCase());
		}
		
		for (int i=0; i < data.length(); i++) {
			JSONObject jo = data.getJSONObject(i);
			String key = jo.getString("key");
			String value = jo.getString("value");			
			CreateMode mode = CreateMode.valueOf(jo.optString("type", "PERSISTENT").toUpperCase());
			client.create().creatingParentsIfNeeded().withMode(mode).forPath(key, value.getBytes(Charsets.UTF_8));
			logger.info(String.format("Created [%s] node %s: \t %s ", mode, key, value));
		}
	}
	
}

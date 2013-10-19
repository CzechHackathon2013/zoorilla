package cz.hack.zoorilla.notify;

import org.apache.curator.framework.CuratorFramework;

/**
 *
 * @author pcipov
 */
public class NotificationBridge {
	
	private final CuratorFramework client;
	private final NotificationBroker broker;

	public NotificationBridge(CuratorFramework client, NotificationBroker broker) {
		this.client = client;
		this.broker = broker;
	}
	
	//TODO register to zook & notify when any chynge 
}

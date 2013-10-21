package cz.hack.zoorilla;

import cz.hack.zoorilla.notify.NotificationBroker;
import java.io.File;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
	
	private static final Logger logger = LoggerFactory.getLogger(App.class);

    public static void main(String[] args) throws Exception {
		File configFile = new File(System.getProperty("cz.hack.config", "zoorilla.json"));
		ZooBuilder builder = new ZooBuilder(configFile);

		NotificationBroker w = new NotificationBroker(builder.getClient());
 
		ServerService server = new ServerService(builder.getClient(), w);
        server.start();
		
		logger.info("Zoorilla started on port "+server.getPort());
        
		System.out.println("Press any key ");
		System.in.read();
		
		server.stop();
		builder.stop();
    }
}

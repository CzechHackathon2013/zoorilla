package cz.hack.zoorilla;

import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.data.Stat;
import org.json.JSONException;
import org.json.JSONStringer;

public class Util {
	
	public static String generateJSONNodeInfo(String name, Stat stat) {
		JSONStringer json = new JSONStringer();
		generateJSONNodeInfo(name, stat, json);
		return(json.toString());
	}
	
	public static void generateJSONNodeInfo(String name, Stat stat, JSONStringer json) {
		try {
			json.object();
			json.key("name").value(name);
			json.key("type").value(getNodeMode(stat));
			json.key("leaf").value(stat.getNumChildren() == 0);
			json.endObject();
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	public static String getNodeMode(Stat stat) {
    	return((stat.getEphemeralOwner() == 0 ? CreateMode.PERSISTENT : CreateMode.EPHEMERAL).name().toLowerCase());
    }

}

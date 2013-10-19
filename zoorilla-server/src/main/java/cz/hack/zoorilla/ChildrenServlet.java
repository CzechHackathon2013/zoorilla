package cz.hack.zoorilla;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.curator.framework.CuratorFramework;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.data.Stat;
import org.json.JSONStringer;

import com.google.common.base.Charsets;

/**
 *
 * @author Phantom
 */
public class ChildrenServlet extends HttpServlet{
	
	private final CuratorFramework client;

	public ChildrenServlet(CuratorFramework curatorFramework) {
		this.client = curatorFramework;
	}
	
	private void allowCrossOrigin(HttpServletResponse resp) {
		resp.setHeader("Access-Control-Allow-Origin", "*");
		resp.setHeader("Access-Control-Allow-Methods", "GET");
		resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
	}
	
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    	this.allowCrossOrigin(resp);
        try {
			String nodePath = Path.fromRequest(req);
			List<String> children = client.getChildren().forPath(nodePath);
            JSONStringer writer = new JSONStringer();
            writer.array();
            Stat stat = new Stat();
            String bp;
            if(nodePath.endsWith("/") == false) {
            	bp = nodePath + "/";
            } else {
            	bp = nodePath;
            }
            for(String ch: children) {
            	this.client.getChildren().storingStatIn(stat).forPath(bp + ch);
            	Util.generateJSONNodeInfo(ch, stat, writer);
            }
            writer.endArray();
            byte[] b = writer.toString().getBytes(Charsets.UTF_8);
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json; charset=UTF-8");
            resp.setContentLength(b.length);
            resp.getOutputStream().write(b);
            resp.getOutputStream().flush();
		} catch(IllegalArgumentException ex) {
			resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (KeeperException.NoNodeException ex) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
    
}

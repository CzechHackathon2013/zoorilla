package cz.hack.zoorilla;

import com.google.common.base.Charsets;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.curator.framework.CuratorFramework;
import org.apache.zookeeper.KeeperException;
import org.json.JSONStringer;

/**
 *
 * @author Phantom
 */
public class ChildrenServlet extends HttpServlet{
	
	private final CuratorFramework client;

	public ChildrenServlet(CuratorFramework curatorFramework) {
		this.client = curatorFramework;
	}

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<String> children = client.getChildren().forPath(req.getPathInfo());
            JSONStringer writer = new JSONStringer();
            writer.array();
            for(String ch: children) {
                writer.value(ch);
            }
            writer.endArray();
            byte[] b = writer.toString().getBytes(Charsets.UTF_8);
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json; charset=UTF-8");
            resp.setContentLength(b.length);
            resp.getOutputStream().write(b);
            resp.getOutputStream().flush();
        } catch (KeeperException.NoNodeException ex) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
    
}

package cz.hack.zoorilla;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.curator.framework.CuratorFramework;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.data.Stat;

/**
 *
 * @author Phantom
 */
public class NodeServlet extends AbstractZoorillaServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String nodePath = req.getPathInfo();
        try {
            CuratorFramework client = getClient(req);
            Stat stat = new Stat();
            client.getChildren().storingStatIn(stat).forPath(nodePath);
            byte[] nodeData = client.getData().forPath(nodePath);
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setHeader("X-Zoo-Version", String.valueOf(stat.getVersion()));
            resp.getOutputStream().write(nodeData);
            resp.getOutputStream().flush();
        } catch (KeeperException.NoNodeException ex) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        } catch (Exception ex)  {
            throw new ServletException(ex);
        }
    }
}

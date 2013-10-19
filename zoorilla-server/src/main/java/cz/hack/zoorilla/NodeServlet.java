/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package cz.hack.zoorilla;

import com.google.common.io.ByteStreams;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.retry.RetryNTimes;
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

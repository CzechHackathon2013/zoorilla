/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package cz.hack.zoorilla;

import com.google.common.base.Charsets;
import com.google.common.io.ByteStreams;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.curator.framework.CuratorFramework;
import org.apache.zookeeper.KeeperException;
import org.json.JSONStringer;
import org.json.JSONWriter;

/**
 *
 * @author Phantom
 */
public class ChildrenServlet extends AbstractZoorillaServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        CuratorFramework client = getClient(req);
        try {
            List<String> children = client.getChildren().forPath(req.getPathInfo());
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json; charset=UTF-8");
            JSONStringer writer = new JSONStringer();
            writer.array();
            for(String ch: children) {
                writer.value(ch);
            }
            writer.endArray();
            byte[] b = writer.toString().getBytes(Charsets.UTF_8);
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

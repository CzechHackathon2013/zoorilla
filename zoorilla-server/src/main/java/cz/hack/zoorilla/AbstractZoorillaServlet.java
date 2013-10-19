/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package cz.hack.zoorilla;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import org.apache.curator.framework.CuratorFramework;
import org.apache.curator.framework.CuratorFrameworkFactory;
import org.apache.curator.retry.RetryNTimes;

/**
 *
 * @author Phantom
 */
public abstract class AbstractZoorillaServlet extends HttpServlet {

    protected CuratorFramework getClient(HttpServletRequest request) {
        HttpSession session = request.getSession();
        CuratorFramework client = (CuratorFramework) session.getAttribute("client");
        if (client == null) {
            client = CuratorFrameworkFactory.newClient("localhost:2181", new RetryNTimes(Integer.MAX_VALUE, 1000));
            client.start();
            session.setAttribute("client", client);
        }
        return client;
    }
    
}

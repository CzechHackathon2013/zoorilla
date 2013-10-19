package cz.hack.zoorilla;

import javax.servlet.http.HttpServletRequest;

/**
 *
 * @author pcipov
 */
public class Path {
	
	public static String fromRequest(HttpServletRequest req) {
		if (req.getPathInfo() == null) {
			throw new IllegalArgumentException("Bad request, no path");
		}
		String nodePath = req.getPathInfo().trim();
		if (nodePath.equals("/")) {
			return "/";
		}
		
		return nodePath.charAt(nodePath.length()-1) != '/'
			? nodePath
			: nodePath.substring(0, nodePath.length()-1);
	}
}

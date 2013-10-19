package cz.hack.zoorilla;

import javax.servlet.http.HttpServletRequest;

/**
 *
 * @author pcipov
 */
public class Path {
	
	private static final String ROOT = "/";
	
	public static String fromRequest(HttpServletRequest req) {
		if (req.getPathInfo() == null) {
			throw new IllegalArgumentException("Bad request, no path");
		}
		String nodePath = req.getPathInfo().trim();
		if (isRoot(nodePath)) {
			return ROOT;
		}
		
		return nodePath.charAt(nodePath.length()-1) != '/'
			? nodePath
			: nodePath.substring(0, nodePath.length()-1);
	}

	static boolean isRoot(String nodePath) {
		return ROOT.equals(nodePath);
	}
}

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package cz.hack.zoorilla.notify;

import java.util.concurrent.atomic.AtomicInteger;
import org.apache.curator.framework.recipes.cache.PathChildrenCache;

/**
 *
 * @author pcipov
 */
public class CacheReference {
	private PathChildrenCache cache;
	
	private AtomicInteger used;

	public CacheReference(PathChildrenCache cache) {
		this.cache = cache;
		this.used = new AtomicInteger(0);
	}

	public PathChildrenCache getCache() {
		return cache;
	}

	public int getUsed() {
		return used.get();
	}
	
	public boolean isUsed() {
		return(this.used.get() > 0);
	}
	
	public void incUsed() {
		this.used.incrementAndGet();
	}
	
	public void decUsed() {
		this.used.decrementAndGet();
	}
}

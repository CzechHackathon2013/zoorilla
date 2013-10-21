package cz.hack.zoorilla.notify;

import java.util.concurrent.atomic.AtomicInteger;

/**
 *
 * @param <E> Type of stored cache
 * @author pcipov
 */
public class CacheReference<E> {
	private E cache;
	
	private AtomicInteger used;

	public CacheReference(E cache) {
		this.cache = cache;
		this.used = new AtomicInteger(0);
	}

	public E getCache() {
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

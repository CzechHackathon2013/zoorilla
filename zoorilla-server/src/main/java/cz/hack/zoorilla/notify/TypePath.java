package cz.hack.zoorilla.notify;

/**
 *
 * @author pcipov
 */
public class TypePath {
	private final NotificationType type;
	private final String path;

	public TypePath(NotificationType type, String path) {
		this.type = type;
		this.path = path;
	}

	@Override
	public int hashCode() {
		int hash = 5;
		hash = 23 * hash + (this.type != null ? this.type.hashCode() : 0);
		hash = 23 * hash + (this.path != null ? this.path.hashCode() : 0);
		return hash;
	}

	@Override
	public boolean equals(Object obj) {
		if (obj == null) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		final TypePath other = (TypePath) obj;
		if (this.type != other.type) {
			return false;
		}
		if ((this.path == null) ? (other.path != null) : !this.path.equals(other.path)) {
			return false;
		}
		return true;
	}

	public NotificationType getType() {
		return type;
	}

	public String getPath() {
		return path;
	}
	
	
}

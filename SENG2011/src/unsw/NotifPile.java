package unsw;

public class NotifPile {
	private Notification[] buf;
	private int count = 0;
	
	public NotifPile(int size) {
		this.buf = new Notification[size];
		int i = 0;
		while (i < size) {
			buf[i] = null;
			i += 1;
		}
	}
	
	public Notification pop() {
		Notification el = buf[0];
		int i = 0;
		while (i < count - 1) {
			buf[i] = buf[i+1];
			i += 1;
		}
		count -= 1;
		return el;
	}
	
	public void push(Notification el) {
		if (count == buf.length) {
			this.pop();
		}
		int index = 0;
		while (index < count && 
				(buf[index].getDate() < el.getDate() || 
						(buf[index].getDate() == el.getDate() && 
						buf[index].getPriority() >= el.getPriority()))) {
			index += 1;
		}
		int i = count - 1;
		while (i >= index) {
			buf[i+1] = buf[i];
			i -= 1;
		}
		count += 1;
		buf[index] = el;
	}

	public void printOut() {
		int i = 0;
		while (i < buf.length) {
			buf[i].printOut();
			i += 1;
		}
	}
}

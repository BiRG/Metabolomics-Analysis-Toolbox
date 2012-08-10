/**
 * 
 */
package com.jmatio.io;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.BufferUnderflowException;
import java.nio.ByteBuffer;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.WritableByteChannel;

/**
 * A {@link java.nio.channels.WritableByteChannel WritableByteChannel} that
 * wraps an <code>OutputStream</code>
 * 
 * Note: <strong>no other OutputStreamChannel objects should wrap the same
 * OutputStream and the output stream should be unused until the wrapping
 * OutputStreamChannel passes out of scope..</strong>
 * 
 * @author Eric Moyer (<img src="doc-files/eric_handwritten_email.png"
 *         style="vertical-align:-50%"/>)
 */
public class OutputStreamChannel implements WritableByteChannel {

	/**
	 * The underlying OutputStream object
	 */
	private OutputStream out;

	/**
	 * True if close was called since object creation
	 */
	private boolean wasClosed;

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.nio.channels.Channel#isOpen()
	 */
	@Override
	public synchronized boolean isOpen() {
		return !wasClosed;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.nio.channels.Channel#close()
	 */
	@Override
	public synchronized void close() throws IOException {
		out.close();
		wasClosed = true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.nio.channels.WritableByteChannel#write(java.nio.ByteBuffer)
	 */
	@Override
	public synchronized int write(ByteBuffer src) throws IOException {
		if (wasClosed) {
			throw new ClosedChannelException();
		}
		byte[] bytes = new byte[0];
		boolean failed = true;
		while (failed) {
			bytes = new byte[src.remaining()];
			try {
				src.get(bytes);
				failed = false;
			} catch (BufferUnderflowException e) {
				// Do nothing
			}
		}
		out.write(bytes);
		return bytes.length;
	}

	/**
	 * Create a channel based on an open <code>OutputStream</code>.
	 * 
	 * <code>out</code> must be an open stream. The OutputStream interface
	 * provides no way of determining whether a stream is open. The channel
	 * interface requires this knowledge. So, this class assumes it is open to
	 * begin with and tracks its state internally, assuming it can only be
	 * closed by accessing this OutputStreamChannel object.
	 * 
	 * Note: <strong>no other OutputStreamChannel objects should wrap the same
	 * OutputStream and the output stream should be unused until the wrapping
	 * OutputStreamChannel passes out of scope.</strong>
	 * 
	 * @param out
	 *            The stream that will underly the created channel. Must be open
	 *            and non-null.
	 */
	public OutputStreamChannel(OutputStream out) {
		if (out == null) {
			throw new NullPointerException(
					"The stream used to construct an OutputStreamChannel cannot be null");
		}
		this.out = out;
		wasClosed = false;
	}
}

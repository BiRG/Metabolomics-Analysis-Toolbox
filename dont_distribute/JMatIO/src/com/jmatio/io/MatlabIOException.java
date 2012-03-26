package com.jmatio.io;

import java.io.IOException;

/**
 * MAT-file reader/writer exception
 * 
 * @author Wojciech Gradkowski (<a href="mailto:wgradkowski@gmail.com">wgradkowski@gmail.com</a>)
 */
@SuppressWarnings("serial")
public class MatlabIOException extends IOException
{
	/**
	 * Create a MatlabIOException with <code>s</code> as the detail message
	 * @param s the detail message
	 */
    public MatlabIOException(String s)
    {
        super(s);
    }
}

/**
 * 
 */
package edu.wright.cs.birg.test;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.List;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

import au.com.bytecode.opencsv.CSVReader;

/**
 * A plug-in replacement for au.com.bytecode.opencsv.CSVReader that reads its data from
 * a 2D array of strings passed on creation rather than from a file
 * @author Eric Moyer
 *
 */
public class MockCSVReader extends CSVReader {
	/**
	 * The 2D array of strings from which the data is read
	 */
	private String[][] data;
	
	/**
	 * The row of the next data item that will be read
	 */
	private int row;
	
	/**
	 * True if the CSVReader is open
	 */
	private boolean isOpen;
	
	/**
	 * Return The number of lines this CSVReader started out with
	 * @return The number of lines this CSVReader started out with
	 */
	@SuppressWarnings("unused")
	private int numLines(){ return data.length; }
	
	/**
	 * Create a CSVReader that returns the items in data
	 * @param data the items to be returned from the new CSVReader 
	 */
	@Exemplars(set={
	@Exemplar(name="oneByone",args={"[a:[a:'1.0']]"}, expect={
			"#=([a:[a:'1.0']],retval.data)",
			"=(retval.row,0)","retval.isOpen"}),
	@Exemplar(name="oneBytwo",args={"[a:[a:'one','two']]"}, expect={
			"#=([a:[a:'one','two']],retval.data)",
			"=(retval.row,0)","retval.isOpen"}),
	@Exemplar(name="twoByone",args={"[a:[a:'one'],[a:'two']]"}, expect={
			"#=([a:[a:'one'],[a:'two']],retval.data)",
			"=(retval.row,0)","retval.isOpen"}),
	@Exemplar(name="twoBytwo",args={"[a:[a:'one','two'],[a:'1.0','2']]"}, expect={
			"#=([a:[a:'one','two'],[a:'1.0','2']],retval.data)",
			"=(retval.row,0)","retval.isOpen"}),
	@Exemplar(name="empty",args={"null"}, expect={
			"=(0,retval.numLines())","=(retval.row,0)","retval.isOpen"})
	})
	public MockCSVReader(String[][] data) {
		super(new InputStreamReader(System.in));
		if(data == null){
			this.data = new String[0][0];
		}else{
			this.data = data;
		}
		isOpen = true;
		row = 0;
	}
	
	@Override
	@Exemplars(set={
	@Exemplar(instance="empty!",   io="closed0x0",expect="!(this.isOpen)"),
	@Exemplar(instance="oneByone!",io="closed1x1",expect="!(this.isOpen)"),
	@Exemplar(instance="oneBytwo!",io="closed1x2",expect="!(this.isOpen)"),
	@Exemplar(instance="twoByone!",io="closed2x1",expect="!(this.isOpen)"), 
	@Exemplar(instance="twoBytwo!",io="closed2x2",expect="!(this.isOpen)") 
	})
	public void close(){
		isOpen = false;
	}
	
	@Override
	@Exemplars(set={
	@Exemplar(i="empty!",io="emptyAfterRead",expect={"null","this.isOpen","=(this.row,0)"}),
	@Exemplar(i="emptyAfterRead!",expect={"null","this.isOpen","=(this.row,0)"}),
	
	@Exemplar(i="oneByone!",io="oneByoneR1",expect={"#=(retval,a:'1.0')","this.isOpen","=(this.row,1)"}),
	@Exemplar(i="oneBytwo!",io="oneBytwoR1",expect={"#=(retval,[a:'one','two'])","this.isOpen","=(this.row,1)"}),
	@Exemplar(i="twoByone!",io="twoByoneR1",expect={"#=(retval,a:'one')","this.isOpen","=(this.row,1)"}), 
	@Exemplar(i="twoBytwo!",io="twoBytwoR1",expect={"#=(retval,[a:'one','two'])","this.isOpen","=(this.row,1)"}),
	
	@Exemplar(i="oneByoneR1!",expect={"null","this.isOpen","=(this.row,1)"}),
	@Exemplar(i="oneBytwoR1!",expect={"null","this.isOpen","=(this.row,1)"}),
	
	@Exemplar(i="twoByoneR1!",io="twoByoneR2",expect={"#=(retval,a:'two')","this.isOpen","=(this.row,2)"}), 
	@Exemplar(i="twoBytwoR1!",io="twoBytwoR2",expect={"#=(retval,[a:'1.0','2'])","this.isOpen","=(this.row,2)"}),
	@Exemplar(i="twoByoneR2!"                ,expect={"null","this.isOpen","=(this.row,2)"}), 
	@Exemplar(i="twoBytwoR2!"                ,expect={"null","this.isOpen","=(this.row,2)"}),
	
	@Exemplar(i="closed0x0!",expectexception="IOException",
	expect="!(this.isOpen)"),
@Exemplar(i="closed1x1!",expectexception="IOException",
	expect="!(this.isOpen)"),
@Exemplar(i="closed1x2!",expectexception="IOException",
	expect="!(this.isOpen)"),
@Exemplar(i="closed2x1!",expectexception="IOException",
	expect="!(this.isOpen)"), 
@Exemplar(i="closed2x2!",expectexception="IOException",
	expect="!(this.isOpen)") 
})
	public String[] readNext() throws IOException{
		if(isOpen){
			if(row < data.length){
				return data[row++]; 
			}else{
				return null;
			}
		}else{
			throw new IOException("Attempt to read from closed MockCSVReader");
		}
	}

	@Exemplars(set={
		@Exemplar(name="emptyReadAll",i="empty!",expect={"=(retval,java/util/Arrays.asList(this.data))","this.isOpen","=(this.row,this.numLines())"}),
		@Exemplar(i="emptyAfterRead!",t="emptyReadAll"),
		
		@Exemplar(i="oneByone!",t="emptyReadAll"),
		@Exemplar(i="oneBytwo!",t="emptyReadAll"),
		@Exemplar(i="twoByone!",t="emptyReadAll"), 
		@Exemplar(i="twoBytwo!",t="emptyReadAll"),
		
		@Exemplar(i="oneByoneR1!",t="emptyReadAll"),
		@Exemplar(i="oneBytwoR1!",t="emptyReadAll"),
		
		@Exemplar(i="twoByoneR1!",t="emptyReadAll"), 
		@Exemplar(i="twoBytwoR1!",t="emptyReadAll"),
		@Exemplar(i="twoByoneR2!",t="emptyReadAll"), 
		@Exemplar(i="twoBytwoR2!",t="emptyReadAll"),
		@Exemplar(name="closedReadAll", i="closed0x0!",expectexception="IOException",
			expect="!(this.isOpen)"),
		@Exemplar(i="closed1x1!", t="closedReadAll"),
		@Exemplar(i="closed1x2!", t="closedReadAll"),
		@Exemplar(i="closed2x1!", t="closedReadAll"), 
		@Exemplar(i="closed2x2!", t="closedReadAll") 
		})
	@Override
	public List<String[]> readAll() throws IOException{
		//NOTE: the javadoc says Reads the entire file into a List ... therefore, I 
		//interpret this as meaning that the underlying reader is reset and the entire
		//file is returned.
		if(isOpen){
			row = data.length;
			return Arrays.asList(data);
		}else{
			throw new IOException("Attempt to readAll from closed MockCSVReader");
		}
	}
}

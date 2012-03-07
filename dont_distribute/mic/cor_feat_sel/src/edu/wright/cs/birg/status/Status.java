/**
 * 
 */
package edu.wright.cs.birg.status;

import java.io.PrintWriter;

/**
 * Singleton that prints the status
 * 
 * @author Eric Moyer
 * 
 */
public class Status {
	/**
	 * The global status printer object
	 */
	private static Status global = new Status(
			new PrintWriter(System.err), 30000L); //Update every 30 seconds

	/**
	 * The writer on which status updates are placed
	 */
	private PrintWriter out;

	/**
	 * The time in milliseconds that the last update was printed
	 */
	private long lastPrintMS;

	/**
	 * A description of the current operation
	 */
	private String currentOperation;

	/**
	 * The time in milliseconds at which the current operation was started
	 */
	private long currentOperationStart;

	/**
	 * The number of steps to complete the current operation
	 */
	private long currentOperationStepsRequired;

	/**
	 * The number of steps that have been completed so far in the current
	 * operation. When currentOperationStepsRequired ==
	 * currentOperationStepsCompleted, the operation is complete.
	 */
	private long currentOperationStepsCompleted;

	/**
	 * Additional status information to print along with the current operation
	 * and the number of steps
	 */
	private Object[] additionalStatusInformation;

	/**
	 * True if the status has been printed since the last update call, false
	 * otherwise. Note that if the last update call didn't change anything but
	 * also didn't print this will still be false.
	 */
	private boolean statusHasBeenPrinted;
	
	/**
	 * The minimum milliseconds to wait before non-forced prints
	 */
	private long minMsBetweenPrints;

	/**
	 * Create a Status object that prints to out
	 * 
	 * @param out
	 *            The Writer to which this Status object prints
	 */
	private Status(PrintWriter out, long minMSBetweenPrints) {
		this.out = out;
		this.lastPrintMS = Long.MIN_VALUE;
		this.currentOperation = "No operation set";
		this.currentOperationStart = Long.MIN_VALUE;
		this.currentOperationStepsRequired = 1L;
		this.currentOperationStepsCompleted = 1L;
		this.additionalStatusInformation = new Object[0];
		this.statusHasBeenPrinted = true;
		this.minMsBetweenPrints = minMSBetweenPrints;
	}
	
	/**
	 * Set the current status. If the operation changes, it is assumed to have started at the time the
	 * status is set. Does not print. Resets the statusHasBeenPrinted variable.
	 * @param operation
	 * @param stepsRequired
	 * @param stepsCompleted
	 * @param additionalData
	 */
	public void setStatus(String operation, long stepsRequired, long stepsCompleted,
			Object ... additionalData){
		statusHasBeenPrinted = false;
		
		additionalStatusInformation = additionalData;
		
		if(!currentOperation.equals(operation)){
			currentOperation = operation;
			currentOperationStart = System.currentTimeMillis();
		}
		
		currentOperationStepsRequired = stepsRequired;
		currentOperationStepsCompleted = stepsCompleted;		
	}
	
	/**
	 * Update the current status and print it if enough time has elapsed since
	 * the previous status
	 */
	public static void update(String operation, long stepsRequired, long stepsCompleted,
			Object ... additionalData) {
		Status g = printer(); //Global object
		g.setStatus(operation, stepsRequired, stepsCompleted, additionalData);
		if(g.elapsedTime() >= g.minMsBetweenPrints){
			g.ensurePrinted();
		}
	}

	/**
	 * Return the number of milliseconds that have elapsed since the last time a print happened
	 * @return the number of milliseconds that have elapsed since the last time a print happened
	 */
	public long elapsedTime() {
		return System.currentTimeMillis()-lastPrintMS;
	}

	/**
	 * Return the number of milliseconds that have passed since the operation began
	 * @return the number of milliseconds that have passed since the operation began
	 */
	public long operationMilliseconds(){
		return System.currentTimeMillis()-currentOperationStart;
	}
	
	/**
	 * On return it is guaranteed that the current status has been printed to the output writer.
	 */
	public void ensurePrinted() {
		if(!statusHasBeenPrinted){
			print();
		}
	}

	/**
	 * Return the fraction complete for the current operation
	 * @return the fraction complete for the current operation
	 */
	public double fractionComplete(){
		if(currentOperationStepsRequired == 0){
			return 1;
		}else{
			return (double) currentOperationStepsCompleted / (double)currentOperationStepsRequired;
		}
	}
	
	/**
	 * Returns a string giving the estimated time remaining
	 * @return a string giving the estimated time remaining
	 */
	public String timeRemaining(){
		double f = fractionComplete();
		if(f == 0.0){
			return "Unknown";
		}
		double timeToReachThisPoint = operationMilliseconds();
		double millisecondsPerFraction = timeToReachThisPoint / f;
		double fractionRemaining = 1-f;
		long millisecondsRemaining = Math.round(fractionRemaining*millisecondsPerFraction);
		
		//Calculate hours minutes and seconds
		final long msPerHour = 60L*60L*1000L;
		final long msPerMin = 60L*1000L;
		final long msPerSec = 1000L;
		long hours = millisecondsRemaining / msPerHour;
		millisecondsRemaining -= hours * msPerHour;
		long minutes = millisecondsRemaining / msPerMin;
		millisecondsRemaining -= minutes* msPerMin;
		long seconds =  millisecondsRemaining / msPerSec;
		millisecondsRemaining -= seconds * msPerSec;
		
		//Build the output string
		StringBuilder out = new StringBuilder();
		if(hours > 0){ out.append(hours).append('h'); }
		if(minutes > 0){ out.append(minutes).append('m'); }
		out.append(seconds).append('s');
		
		return out.toString();
	}
	/**
	 * Print the status now, whether it has been printed before or not.
	 */
	public void print() {
		statusHasBeenPrinted = true;
		out.printf("%s (%3.1lf) %ld/%ld %s - ",currentOperation,
				fractionComplete()*100,
				currentOperationStepsCompleted, currentOperationStepsRequired,
				timeRemaining());
		
		for(Object o: additionalStatusInformation){
			out.print(o.toString());
		}
		out.println();
	}

	/**
	 * Return the global status printer object
	 * 
	 * @return the global status printer object
	 */
	public static Status printer() {
		return global;
	}
}

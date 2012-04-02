This holds a program that calculates the exact Mutual Information
Coefficient (Rashef Dec 2011) using the CHOCO constraint-satisfaciton
program solver.

time_test_inputs holds the input files used for testing the time
required for solving the problem.  test_linear_xx_in.txt means that it
is a test file containing xx points that would result from sampling a
noiseless line of positive slope at distinct points (note that this is
just the integer pairs 1,1 .. xx,xx because of the discretization).

time_taken is a csv_file holding the results of the time trials for
the code, run on a 2.2 GHz HP Pavilion dv4-1313dx laptop.

The program is an Eclipse project.  I was using: Indigo Service Release 1
Build id: 20110916-0149

The CHOCO solver is assumed to be in /home/eric/SW/CHOCO/choco/choco-solver-2.1.2-with-sources.jar

I also depend on OpenCSV 2.3 which is assumed to be in /home/eric/SW/OpenCSV/opencsv-2.3/deploy/opencsv-2.3.jar

You'll need to change things to compile it on your machine.

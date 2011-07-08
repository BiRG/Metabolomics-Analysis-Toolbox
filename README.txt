Metabolomics Analysis Toolbox

-----------------------------------------------------------------------------------------------------------NOTES:

1. Any changes that you make to these directories and files will be undone every hour. This means that any data files that you save to this directory will be removed without notice.

2. Read note #1 again! DO NOT SAVE ANY OF YOUR WORK TO THE OMICS_ANALYSIS FOLDER! It will be lost.

3. Before using any of the code run startup.m in the omics_analysis directory.

-----------------------------------------------------------------------------------------------------------
Deployment practices:

1. Releases shall have revision numbers not minor version numbers (i.e., 0r1 instead of 0.1)

2. The release number shall be incremented if they are implementing new features that will break a prior version, thus, some bug fixes will not require an updated revision number.

3. Major version numbers 0r1 versus 1r1 shall be reserved for significant changes to the program. If you have to think about the answer to "Is this a major revision?" then the answer is no.

Deployment Directory Structure:

Deployment/
	Development/ # Will always hold the most recent development compilation (no revision numbers)
		Windows/
			bin/
				bin.prj # MATLAB Deployment Project File
				src/ # Created automatically by MATLAB
				deploy/ # Created automatically by MATLAB
					bin.exe # Created automatically by MATLAB
		Mac/
		Linux/
	Releases/ # Will hold all current and prior releases with revistion numbers
		Windows/
			bin_0r2.exe # Current release
			Old Releases/
				bin_0r1.exe
				bin_0r2.exe
		Mac/
		Linux/



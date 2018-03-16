Metabolomics Analysis Toolbox
===============================
This is designed for use with the old omics_analysis app.
Before using any of the code run startup.m in the omics_analysis directory.

Used:
-----
Run startup.m before running any other scripts.

Deployment practices:
---------------------
Releases are done as snapshots of the `master` or `omics-dashboard` branch

Release names should include the data in ISO Format (YYYYMMDD) and the branch from which the release is derived.

### Common and Library directories
|Directory|Purpose|
| -------- | -------- |
|common_scripts| Holds all matlab scripts used by more than one program|
|lib|Holds all libraries from other projects.  Each library should be in its own subdirectory under lib and periodically updated.|

Metabolomics Analysis Toolbox
===============================
Use
-----
Run startup.m before running any other scripts.

Branches
---------
The `omics-dashboard` branch is for use with the new Omics Dashboard service
The `master` branch is for use with the old omics_analysis service.

Releases
---------------------
Releases are done as snapshots of the `master` or `omics-dashboard` branch

Release names should include the data in ISO Format (YYYYMMDD) and the branch from which the release is derived.

Programs
---------
|Script|Description|
| ---- | --------- |
|opls/main | Orthogonal Projection on Latent Structures|
|pca/main | Orthogonal Projection on Latent Structures|
|fix_spectra/fix_spectra | Baseline correction, alignment to reference, and zero regions|
|bin/main | Bin based quantification/deconvolution designed around dynamic adaptive binning|
|visualization/visualize_collections/main |Flexible spectral viewer|

Development Practices
----------------------
### Common and Library directories
|Directory|Purpose|
| -------- | -------- |
|common_scripts| Holds all matlab scripts used by more than one program|
|lib|Holds all libraries from other projects.  Each library should be in its own subdirectory under lib and periodically updated.|

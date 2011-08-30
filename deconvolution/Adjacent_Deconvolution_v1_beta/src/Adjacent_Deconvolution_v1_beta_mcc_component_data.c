/*
 * MATLAB Compiler: 4.9 (R2008b)
 * Date: Tue Feb 01 18:33:22 2011
 * Arguments: "-B" "macro_default" "-o" "Adjacent_Deconvolution_v1_beta" "-W"
 * "main" "-d"
 * "C:\Users\Paul\BiRG\Research\Toxicology\omics_analysis\deconvolution\Adjacent
 * _Deconvolution_v1_beta\src" "-T" "link:exe" "-v"
 * "C:\Users\Paul\BiRG\Research\Toxicology\omics_analysis\deconvolution\main.m"
 * "-a"
 * "C:\Users\Paul\BiRG\Research\Toxicology\omics_analysis\deconvolution\main.fig
 * " "-a"
 * "C:\Users\Paul\BiRG\Research\Toxicology\omics_analysis\deconvolution\example_
 * collections\collection_2,control_630.zip" "-a"
 * "C:\Users\Paul\BiRG\Research\Toxicology\omics_analysis\deconvolution\example_
 * collections\collection_2,DFP,cerebellum_4322.zip" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_Adjacent_Deconvolution_v1_beta_session_key[] = {
    '7', '0', '7', 'F', 'C', '6', 'B', '2', 'C', '2', '6', '7', 'B', '5', 'F',
    'F', 'D', 'A', '6', '5', '8', 'B', '9', '9', '0', '8', '8', '0', '1', '8',
    'E', '7', '5', '6', 'C', '8', 'A', 'A', '5', '3', 'B', 'E', 'C', 'A', 'C',
    'D', 'F', '0', '6', 'D', '5', 'A', '8', '7', '8', 'C', 'B', 'E', 'E', '0',
    '5', 'F', 'F', '3', '3', 'A', 'E', '7', 'B', 'F', '6', '7', 'E', '2', '5',
    '0', '5', '4', 'E', '9', '5', 'F', 'C', '2', '5', 'B', 'B', '2', 'E', '1',
    '7', '0', 'E', 'A', '4', '2', '0', 'E', 'C', '0', '2', '8', '6', '6', 'C',
    '5', '6', '9', 'B', '2', 'C', '1', 'E', '3', 'D', '3', '1', '5', '8', 'E',
    'E', '5', 'D', 'D', '5', 'E', '7', '4', '9', '2', '1', '6', '5', '4', '3',
    'E', '1', '4', '3', 'C', '6', 'D', 'E', '3', '9', 'E', 'C', '1', 'F', '6',
    'A', '3', '7', '4', '1', '4', '2', '3', '9', 'C', 'C', '8', '2', 'E', '7',
    '5', 'A', '6', 'E', '9', '2', '1', '6', 'F', '3', '6', '3', '4', 'E', '0',
    '9', 'D', '0', '4', '3', '6', '0', '5', 'D', '0', 'F', '8', '0', '8', '4',
    '4', 'C', '4', 'D', '0', '0', 'A', 'B', '9', 'E', '5', '8', '7', 'D', '5',
    '4', '7', '8', '7', 'C', '9', '0', 'C', '4', '1', '4', '8', '5', '9', 'C',
    'B', 'D', 'F', 'B', 'D', '5', 'B', '7', '6', '8', '1', '4', '4', '0', '0',
    '7', 'C', '6', 'C', '0', 'A', 'D', 'B', 'C', '3', '4', '2', '9', 'F', 'D',
    '4', '\0'};

const unsigned char __MCC_Adjacent_Deconvolution_v1_beta_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_Adjacent_Deconvolution_v1_beta_matlabpath_data[] = 
  { "Adjacent_Dec/", "$TOOLBOXDEPLOYDIR/", "example_collections/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/randfun/", "$TOOLBOXMATLABDIR/elfun/",
    "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/matfun/",
    "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/polyfun/",
    "$TOOLBOXMATLABDIR/funfun/", "$TOOLBOXMATLABDIR/sparfun/",
    "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/graph2d/",
    "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/specgraph/",
    "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/uitools/",
    "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
    "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/audiovideo/",
    "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
    "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
    "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/winfun/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "toolbox/shared/dastudio/", "$TOOLBOXMATLABDIR/datamanager/",
    "toolbox/compiler/", "toolbox/shared/optimlib/",
    "toolbox/distcomp/", "toolbox/distcomp/mpi/",
    "toolbox/distcomp/parallel/", "toolbox/distcomp/parallel/util/",
    "toolbox/distcomp/lang/", "toolbox/optim/optim/",
    "toolbox/wavelet/wavelet/", "toolbox/wavelet/wavedemo/" };

static const char * MCC_Adjacent_Deconvolution_v1_beta_classpath_data[] = 
  { "" };

static const char * MCC_Adjacent_Deconvolution_v1_beta_libpath_data[] = 
  { "" };

static const char * MCC_Adjacent_Deconvolution_v1_beta_app_opts_data[] = 
  { "" };

static const char * MCC_Adjacent_Deconvolution_v1_beta_run_opts_data[] = 
  { "" };

static const char * MCC_Adjacent_Deconvolution_v1_beta_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_Adjacent_Deconvolution_v1_beta_component_data = { 

  /* Public key data */
  __MCC_Adjacent_Deconvolution_v1_beta_public_key,

  /* Component name */
  "Adjacent_Deconvolution_v1_beta",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_Adjacent_Deconvolution_v1_beta_session_key,

  /* Component's MATLAB Path */
  MCC_Adjacent_Deconvolution_v1_beta_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  49,

  /* Component's Java class path */
  MCC_Adjacent_Deconvolution_v1_beta_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_Adjacent_Deconvolution_v1_beta_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_Adjacent_Deconvolution_v1_beta_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_Adjacent_Deconvolution_v1_beta_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "Adjacent_Dec_E0F9DC8C63B5670BA444292B4D5EEC01",

  /* MCR warning status data */
  MCC_Adjacent_Deconvolution_v1_beta_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif



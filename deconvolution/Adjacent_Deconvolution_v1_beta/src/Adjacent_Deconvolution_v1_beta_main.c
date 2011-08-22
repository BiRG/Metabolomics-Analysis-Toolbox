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

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_Adjacent_Deconvolution_v1_beta_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;


#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_Adjacent_Deconvolution_v1_beta_C_API 
#define LIB_Adjacent_Deconvolution_v1_beta_C_API /* No special import/export declaration */
#endif

LIB_Adjacent_Deconvolution_v1_beta_C_API 
bool MW_CALL_CONV Adjacent_Deconvolution_v1_betaInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_Adjacent_Deconvolution_v1_beta_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 1890306, NULL))
    return false;
  return true;
}

LIB_Adjacent_Deconvolution_v1_beta_C_API 
bool MW_CALL_CONV Adjacent_Deconvolution_v1_betaInitialize(void)
{
  return Adjacent_Deconvolution_v1_betaInitializeWithHandlers(mclDefaultErrorHandler,
                                                              mclDefaultPrintHandler);
}

LIB_Adjacent_Deconvolution_v1_beta_C_API 
void MW_CALL_CONV Adjacent_Deconvolution_v1_betaTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
  int _retval;
  /* Generate and populate the path_to_component. */
  char path_to_component[(PATH_MAX*2)+1];
  separatePathName(argv[0], path_to_component, (PATH_MAX*2)+1);
  __MCC_Adjacent_Deconvolution_v1_beta_component_data.path_to_component = path_to_component; 
  if (!Adjacent_Deconvolution_v1_betaInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "main", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  Adjacent_Deconvolution_v1_betaTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_Adjacent_Deconvolution_v1_beta_component_data.runtime_options,
    __MCC_Adjacent_Deconvolution_v1_beta_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}

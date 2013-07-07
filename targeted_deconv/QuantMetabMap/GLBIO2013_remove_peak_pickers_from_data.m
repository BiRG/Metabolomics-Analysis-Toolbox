function edited_data = GLBIO2013_remove_peak_pickers_from_data( peak_pickers, data )
% Return data without any deconvolutions that involved the peak pickers in peak_pickers
%
% Usage: edited_data = GLBIO2013_remove_peak_pickers_from_data( peak_pickers, data )
%
% For each element in data (data(i)), returns an edited version in
% edited_data(i) that is identical except that it does not contain any 
% members of data(i).deconvolutions which had a peak picker in peak_pickers 
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% peak_pickers - (cell array of string) The peak pickers to remove. 
%     Contents are a subset of GLBIO2013Deconv.peak_picking_method_names
%
% data - (vector of GLBIO2013Datum) the datum objects to edit
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% edited_data - the GLBIODatum objects in data without any deconvolutions
%     that involved peak picking methods listed in peak_pickers
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) June 2013



end


function edited_data = remove_peak_pickers_from_data( peak_pickers, data )
% Return data without any deconvolutions that involved the peak pickers in peak_pickers
%
% Usage: edited_data = remove_peak_pickers_from_data( peak_pickers, data )
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
%     Contents are a subset of ExpDeconv.peak_picking_method_names
%
% data - (vector of ExpDatum) the datum objects to edit. Must 
%     contain at least one object.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% edited_data - the ExpDatum objects in data without any deconvolutions
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
% Eric Moyer (eric_moyer@yahoo.com) July 2013

invalid_picker = cellfun(@(p) ~any(strcmp(p, ExpDeconv.peak_picking_method_names)), peak_pickers);
if any(invalid_picker)
    error('TestSummitDeconv2013:unknown_pp_method', ...
        'Unknown peak picking method "%s" specified.',...
        peak_pickers{find(invalid_picker,1,'first')});
end


edited_data(length(data)) = data(length(data));
for datum_idx = 1:length(data)
    datum = data(datum_idx);
    deconv = datum.deconvolutions;
    doesnt_match = arrayfun(@(d) ~any(strcmp(d.peak_picker_name, peak_pickers)), deconv);
    edited_data(datum_idx) = ExpDatum.dangerous_constructor( ...
        datum.spectrum_peaks, datum.spectrum_width, ...
        deconv(doesnt_match), datum.resolution, ...
        datum.spectrum_interval, datum.spectrum, ...
        datum.spectrum_snr, datum.id);
end


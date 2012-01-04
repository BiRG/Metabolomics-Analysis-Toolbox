function [ peaks ] = peaks_in_session_file( filename )
%Usage: peaks=peaks_in_session_file(filename)
%
%loads a session file and extracts the deconvolved peaks from that file,
%ignoring the bin - the session should have all the peaks in all bins
%deconvolved

load(filename,'-mat');
cached_values = [session_data.deconvolutions];
region_decs = [cached_values.value];
peaks = [region_decs.peaks];
end


classdef GLBIO2013Datum
% Represents a raw data point from my experiment for the GLBIO 2013 paper
% 

    
    properties (SetAccess=private)
        % The peaks generated from the nssd distribution (vector of
        % GaussLorentzPeak objects)
        spectrum_peaks
        
        % The width of the generated spectrum in ppm (scalar)
        spectrum_width
        
        % The deconvolutions generated by the
        % peak-picking/deconvolution method hybrids (vector of
        % GLBIO2013Deconv objects)
        deconvolutions
        
        % Resolution of the generated spectra in samples/ppm (scalar)
        resolution
        
        % ClosedInterval object representing the ppm used in
        % generating the spectra
        spectrum_interval
        
        % The generated spectrum object that was deconvolved
        spectrum
        
        % The signal-to-noise ratio used in generating the spectrum
        spectrum_snr
        
        % An ID string unique to this datum to allow referring to it in
        % publications etc. This is generated probabilistically and
        % represents 45 bits of entropy - which, in a database of 1000
        % records, will have a collision 1 in 3e10 times. And if we
        % update that to 1000000 records, the risk of a collision is
        % still 1 in 3e7 (less than 1 in 10 million).
        id
    end
    
    properties (Dependent)

    end
    
    methods(Static)
        function obj = dangerous_constructor(spectrum_peaks, ...
            spectrum_width, deconvolutions, resolution, ...
            spectrum_interval, spectrum, spectrum_snr, id)
        % Return a GLBIO2013Datum with the properties set to the values passed in.
        %
        % NO ERROR CHECKING IS DONE. This method is intended for use in
        % testing. Don't use it unless you are testing. 
        %
        % Usage: obj = dangerous_constructor(spectrum_peaks, ...
        %    spectrum_width, deconvolutions, resolution, ...
        %    spectrum_interval, spectrum, spectrum_snr, id)
        %
        % Example:
        %
        % >> g = GLBIO2013Datum.dangerous_constructor([],2,3,4,5,6,7,'my id')
        %
        % Produces a completely unusable GLBIO2013Datum object
            obj = GLBIO2013Datum;
            obj.spectrum_peaks = spectrum_peaks;
            obj.spectrum_width = spectrum_width;
            obj.deconvolutions = deconvolutions;
            obj.resolution = resolution;
            obj.spectrum_interval = spectrum_interval;
            obj.spectrum = spectrum;
            obj.spectrum_snr = spectrum_snr;
            obj.id = id;
        end

    end
    
    methods
        function obj=GLBIO2013Datum(spectrum_width)
        % Generate a random data point for the given spectrum width
        %
        % Usage: GLBIO2013Datum(spectrum_width)
        %
        % spectrum_width - (scalar) the width of the generated
        %                  spectrum in ppm. Must be positive
        %
        % Generate and deconvolve one random datum using the system random
        % number generator for 7 peaks in a spectrum spectrum_width ppm wide
        % with peaks drawn from the nssd-derived distribution. The spectrum
        % passed to the deconvolution will have a 1000:1 signal-to-noise
        % ratio. They have a resolution of 25 samples per
        % 0.00453630122481774988 ppm (that is per mean width at
        % half-height of the nssd-derived peaks) or 5511.097866082 samples per
        % ppm. I chose that number because it was the number I used in doing
        % my resolution experiments. It turns out to be close to the normal
        % 65536 samples/12 ppm used in standard 1H NMR experiments. I carried
        % out these experiments originally in mean-width units because I
        % thought I might see a nice relationship between mean width and
        % probability of having all peaks generate local maxima.
        %
        % 
        % ----------------------------------------------------------------
        % Examples 
        % ---------------------------------------------------------------
        %
        % >> g = GLBIO2013Datum(0.5)
        %
        % Generates and deconvolves peaks in a spectrum 0.5 ppm wide
            if nargin > 0
                assert(nargin == 1);
                assert(isscalar(spectrum_width));
                assert(spectrum_width > 0);
                
                obj.resolution = 25/0.00453630122481774988;
                
                obj.id = random_human_readable_id_string(45, true);
                obj.spectrum_width = spectrum_width;
                obj.spectrum_interval = ClosedInterval(1, 1+ spectrum_width);
                obj.spectrum_snr = 1000;
                [obj.spectrum, obj.spectrum_peaks] = ...
                    random_spec_from_nssd_data( ...
                        7, obj.spectrum_interval.min, ...
                        obj.spectrum_interval.max, ...
                        spectrum_width*obj.resolution, ...
                        1/obj.spectrum_snr);
                
                pickers = GLBIO2013Deconv.peak_picking_method_names;
                deconvolvers = ...
                    GLBIO2013Deconv.deconvolution_starting_point_method_names;
                picked_locs = pick_peaks(obj.spectrum, ...
                    obj.spectrum_peaks, 1/obj.spectrum_snr);
                for p = 1:length(pickers)
                    for d = 1:length(deconvolvers)
                        tmp = GLBIO2013Deconv(obj.id, obj.spectrum, ...
                            obj.spectrum_peaks, pickers{p}, ...
                            picked_locs{p}, deconvolvers{d});
                        if isempty(obj.deconvolutions)
                            obj.deconvolutions = tmp;
                        else
                            obj.deconvolutions(end+1) = tmp;
                        end
                    end
                end
            end
        end
	

        function updated = updateDeconvolutions(obj)
        % Return an updated datum containing all the deconvolutions that
        % would be produced if the Datum had been generated using the
        % current set of peak pickers and starting points. The new entries
        % will be in the current order. 
        %
        % If there are no new peak pickers and the new deconvolutions
        % don't involve random numbers, the results will be the same as if
        % the new deconvolutions had been part of the Datum from the
        % beginning.
        %
        % Usage: updated = updateDeconvolutions(obj)
        %
        % ----------------------------------------------------------------
        % Input parameters
        % ----------------------------------------------------------------
        %
        % obj - a single GLBIO2013Datum object. Must have id,
        %     spectrum_width, spectrum_interval, spectrum_snr, spectrum,
        %     and spectrum_peaks fields already initialized.
            updated = obj;
            pickers = GLBIO2013Deconv.peak_picking_method_names;
            deconvolvers = ...
                GLBIO2013Deconv.deconvolution_starting_point_method_names;
            
            old_deconvs = updated.deconvolutions;
            
            % Initialize list of picked locations to nan
            picked_locs = cell(1,length(pickers));
            for i = 1:length(picked_locs)
                picked_locs{i} = nan;
            end
            
            % Extract extant picked locations from the current list of
            % deconvolutions (overwriting nans with valid values)
            for i = 1:length(old_deconvs)
                picker_name = old_deconvs(i).peak_picker_name;
                name_loc = strcmp(picker_name, pickers);
                picked_locs{name_loc} = old_deconvs(i).picked_locations;
            end
            
            % If any pickers need to be generated, generate 
            is_new_picker = cellfun(@(x) isscalar(x) && isnan(x), picked_locs);
            if any(is_new_picker)
                % Fresh_picked_locs contains the locations that will be used if
                % a particular peak picker is not present in the originals
                fresh_picked_locs = pick_peaks(updated.spectrum, ...
                    updated.spectrum_peaks, 1/updated.spectrum_snr);
                picked_locs(is_new_picker) = fresh_picked_locs(is_new_picker);
            end
        
            % Find out where each picker/starting point combination is in
            % the original deconvolutions
            index_of_deconv = nan(length(pickers), length(deconvolvers));
            for orig_idx = 1:length(old_deconvs)
                dec = old_deconvs(orig_idx);
                p = find(strcmp(dec.peak_picker_name, pickers),1,'first');
                sp = find(strcmp(dec.starting_point_name, deconvolvers),...
                    1,'first');
                index_of_deconv(p, sp) = orig_idx;
            end
            
            % Merge existing deconvolutions with newly created
            % deconvolutions
            updated.deconvolutions = [];
            for p = 1:length(pickers)
                for d = 1:length(deconvolvers)
                    % If we've already calculated the current
                    % picker/deconvolver pair, use that, otherwise,
                    % calculate the new one.
                    idx = index_of_deconv(p, d);
                    if isnan(idx)
                        tmp = GLBIO2013Deconv(updated.id, ...
                            updated.spectrum, updated.spectrum_peaks, ...
                            pickers{p}, picked_locs{p}, deconvolvers{d});
                    else
                        tmp = old_deconvs(idx);
                    end

                    % Put the deconvolution for the picker/deconvolver 
                    % pair in its proper place
                    if isempty(updated.deconvolutions)
                        updated.deconvolutions = tmp;
                    else
                        updated.deconvolutions(end+1) = tmp;
                    end
                end
            end
        end
        
        function str=char(objs)
        % Return a human-readable string representation of this
        % object. (Matlab's version of toString, however, Matlab
        % doesn't call it automatically). Remember that it can be passed a
        % matrix of objects.
            strs = cell(length(objs),1);
            separator = '';
            for i = 1:length(objs)
                strs{i} =sprintf([separator,'GLBIO2013Datum(%g, %s)'], objs(i).spectrum_width, objs(i).id);
                separator = '\n';
            end
            str = sprintf('%s',strs{:});
        end
        
        function display(objs)
        % Display this object to a console. (Called by Matlab
        % whenever an object of this class is assigned to a
        % variable without a semicolon to suppress the display).
            fprintf('%s\n',objs.char);
        end
    end
end


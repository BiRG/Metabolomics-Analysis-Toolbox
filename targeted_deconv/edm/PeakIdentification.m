classdef PeakIdentification
    %PEAKIDENTIFICATION A manual identification of a peak within a CompoundBin
    %   A user identifies a peak within a bin and that identification is
    %   saved in this data-structure for future data analysis
    
    properties
        %The ppm identified as the peak
        ppm
        
        %The 1-based index of the height value in the spectrum
        height_index
        
        %The (1-based) index of the spectrum in the spectrum collection in which this
        %identification was made
        spectrum_index
        
        %The compound bin object within which the peak was found - the bin
        %index is not needed because each bin has a unique identifier
        compound_bin
    end
    
    methods
        function obj=PeakIdentification(ppm, height_index, spectrum_index, ...
                compound_bin)
            if nargin > 0 %Default constructor will not initialize
                obj.ppm = ppm;
                obj.height_index = height_index;
                obj.spectrum_index = spectrum_index;
                obj.compound_bin = compound_bin;
            end
        end
    end
    
end


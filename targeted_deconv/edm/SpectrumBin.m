classdef SpectrumBin
    %SPECTRUMBIN A bin in a spectrum
    
    properties
        %Left hand of bin (higher ppm)
        left
        %Right hand of bin (lower ppm - but can be equal)
        right
    end
    
    methods
        function obj=SpectrumBin(left,right)
            obj.left = left;
            obj.right = right;
        end
    end
    
end


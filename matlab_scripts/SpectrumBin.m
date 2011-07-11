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
            if nargin>0 %Make a default constructor that doesn't initialize
                obj.left = left;
                obj.right = right;
            end
        end
    end
    
end


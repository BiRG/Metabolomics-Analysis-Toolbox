classdef CompoundBin
    %COMPOUNDBIN A bin that should contain certain peaks from the given
    %compound(s)
    %   Both a a bin object as description of the compound(s) 
    
    properties (SetAccess=private)
        %Our id of the compound/bin combination - a number
        id
        %String description of compound
        compound_descr
        %Bin object
        bin
        %Multiplicity of bin (as described in binmap file)
        multiplicity
        %True if bin is expected to be clean of other compounds
        is_clean
        %Id of protons in bin
        proton_id
        % Source of id information
        id_source
    end
    
    properties (Dependent)
        %The number of peaks expected in this compound bin
        num_peaks
    end
    
    methods
        %bin_map_line is an array containing the result of parsing the csv
        %line in the binmap file
        function obj=CompoundBin(bin_map_line)
            obj.id = bin_map_line{1};
            obj.compound_descr = bin_map_line{2};
            obj.bin = SpectrumBin(bin_map_line{3}, bin_map_line{4});
            obj.multiplicity = bin_map_line{5};
            obj.is_clean = (isequal(lower(bin_map_line{6}),'clean'));
            obj.proton_id=bin_map_line{7};
            obj.id_source=bin_map_line{8};
        end
        %Getter method calculating the number of peaks from the
        %multiplicity variable
        function num_peaks=get.num_peaks(obj)
            switch lower(obj.multiplicity)
                case 's'
                    num_peaks=1; return;
                case 'd'
                    num_peaks=2; return;
                case 't'
                    num_peaks=3; return;
                case 'q'
                    num_peaks=4; return;
                case 'dd'
                    num_peaks=4; return;
                case 'half of ab d'
                    num_peaks=2; return;
            end
        end
    end
    
end


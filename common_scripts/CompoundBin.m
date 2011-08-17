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
        
        %A nicely formatted version of the multiplicity
        readable_multiplicity
    end
    
    methods
        %bin_map_line is an array containing the result of parsing the csv
        %line in the binmap file
        function obj=CompoundBin(bin_map_line)
            if nargin>0 %Make a default constructor that doesn't initialize
                obj.id = bin_map_line{1};   
                obj.compound_descr = bin_map_line{2};
                obj.bin = SpectrumBin(bin_map_line{3}, bin_map_line{4});
                obj.multiplicity = bin_map_line{5};
                obj.is_clean = (isequal(lower(bin_map_line{6}),'clean'));
                obj.proton_id=bin_map_line{7};
                obj.id_source=bin_map_line{8};
            end
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
        %Getter method calculating a readable version of the multiplicity
        %from the multiplicity variable
        function str=get.readable_multiplicity(obj)
            switch lower(obj.multiplicity)
                case 's'
                    str='singlet'; return;
                case 'd'
                    str='doublet'; return;
                case 't'
                    str='triplet'; return;
                case 'q'
                    str='quartet'; return;
                case 'dd'
                    str='doublet of doublets'; return;
                case 'half of ab d'
                    str='half of AB doublet'; return;
            end
        end
        
        %Equality testing (called by operator ==)
        function r = eq(a,b)
            i = [a.id] == [b.id];
            cd = strcmp({a.compound_descr},{b.compound_descr});
            bn = [a.bin] == [b.bin];
            mu = strcmpi({a.multiplicity},{b.multiplicity});
            ic = [a.is_clean] == [b.is_clean];
            pi = strcmp({a.proton_id}, {b.proton_id});
            is = strcmp({a.id_source}, {b.id_source});
            
            r = i & cd & bn & mu & ic & pi & is;
        end

    end
    
end


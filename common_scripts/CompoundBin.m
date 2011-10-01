classdef CompoundBin
    %COMPOUNDBIN A bin that should contain certain peaks from the given
    %compound(s)
    %   Both a a bin object as description of the compound(s) 
    
    properties (SetAccess=private)        
        % Our id of the compound/bin combination - a number
        id
        
        % True if this bin was deleted, false otherwise
        was_deleted
        
        % The BIRG id number for this metabolite (will be greater than 0)
        metabolite_id
        
        % String description of compound
        compound_descr
        
        % True if this bin is for a known metabolite, false if for peaks
        % from an unknown metabolite
        is_known_metabolite
        
        % Bin object
        bin
        
        % Multiplicity of bin (as described in binmap file)
        multiplicity
        
        % The number of peaks to be clicked on in this compound bin
        num_peaks
        
        % For a multiplet, this contains a list of the j values for the
        % multiplet's components if they are known.  If the bin contains a
        % singlet, then this will be empty
        j_values
        
        % Id of protons in bin - the hydrogen assignment
        proton_id
        
        % The HMDB acession number without the HMDB prefix
        hmdb_id
        
        % True if some information was verified with Chenomx
        chenomix_was_used
        
        % Source of id information - literature
        id_source
        
        % The isotope to which the bin applies - 1H, 13C, 31P, 14N, 15N,
        % etc
        nmr_isotope
        
        % Human-readable notes for the compound bin
        notes
    end
    
    properties (Dependent)
        % A nicely formatted version of the multiplicity
        readable_multiplicity
        
        % A string that represents this bin as a line in a csv file (the
        % csv header is given by csv_file_header_string)
        as_csv_string
    end
    
    methods (Static)
        function str=csv_file_header_string()
        % A string that represents the header for a csv file containing
        % CompoundBin objects
            str=['"Bin ID","Deleted","Metabolite ID","Metabolite",'...
                '"Known Metabolite","Bin (Lt)","Bin (Rt)",'...
                '"Multiplicity","Peaks to Select","J (Hz)",'...
                '"1H Assignment","HMDB No.","Chenomx","Literature",'...
                '"NMR Nucleus","Notes"'];
        end
    end
    
    methods
        function obj=CompoundBin(bin_map_line)
        % bin_map_line is an array containing the result of parsing the csv
        % line in the binmap file
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
        
        function num_peaks=get.num_peaks(obj)
        % Getter method calculating the number of peaks from the
        % multiplicity variable
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
        
        function str=get.readable_multiplicity(obj)
        % Getter method calculating a readable version of the multiplicity
        % from the multiplicity variable
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
        
        function str=get.as_csv_string(obj)
        % Getter method returning the value of as_csv_string
            if obj.is_clean
                clean_str = 'clean';
            else
                clean_str = 'overlap';
            end
            
            str = sprintf('%d,"%s",%f,%f,"%s","%s","%s","%s"', ...
                obj.id, obj.compound_descr, ...
                obj.bin.left, obj.bin.right, obj.multiplicity, ...
                clean_str, obj.proton_id, obj.id_source);
        end
        
        function r = eq(a,b)
        % Equality testing (called by operator ==)
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


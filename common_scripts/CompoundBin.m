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
        
        function trueorfalse=parse_csv_bool(str, value_destination)
        % Turns str (a field from the input csv) from 'X','' to 1,0
        %
        % If str is 'X' or 'x' returns 1
        % if str is '' or white-space returns 0
        %
        % Otherwise throws an exception with the text: 
        %
        % ------------
        % - Usage
        % ------------
        %
        % trueorfalse=parse_csv_bool(str, value_destination)
        %
        % ------------
        % - Input Arguments
        % ------------
        %
        % str               The string to parse
        % value_destination The destination where the value will be put -- 
        %                   will be used in the error message
        % ------------
        % - Output Parameters
        % ------------
        %
        % trueorfalse   the result of parsing str into a true or a false value
        %
        %
        % ------------
        % - Examples
        % ------------
        %
        % >> parse_csv_bool('X', 'foobar')
        %
        % 1
        %
        % >> parse_csv_bool('', 'foobar')
        %
        % 0
        %
        % >> parse_csv_bool(' ', 'foobar')
        %
        % 0
        %
        % >> parse_csv_bool('something', 'foobar')
        %
        % (exception thrown here)


        if     ~isempty(regexp(str, '^[Xx]$', 'once'))
            trueorfalse = 1==1;
        elseif isempty(str) || ~isempty(regexp(str, '^\s*$', 'once')) 
            trueorfalse = 0==1;
        else
            error('CompoundBin:bad_bool',['The input for "%s" should have been '...
                'an "X" for true or a blank "" for false.  Instead '...
                '"%s" was passed.'], value_destination, str);
        end
        end
    end
    
    methods
        function obj=CompoundBin(metab_map_line)
        % metab_map_line is an array containing the result of parsing the csv
        % line in the metabmap file
        %
        % Throws readable exceptions that can be used for input validation
        % if you just throw user-input into the appropriate boxes.
        % However, it is assumed that the caller will translate checkboxes
        % into 'X' and '' for boolean true and false respectively
        
            if nargin>0 %Make a default constructor that doesn't initialize
                obj.id=metab_map_line{1};
                obj.was_deleted=CompoundBin.parse_csv_bool(...
                    metab_map_line{2}, 'was deleted');
                obj.metabolite_id=metab_map_line{3};
                obj.compound_descr=metab_map_line{4};
                obj.is_known_metabolite=CompoundBin.parse_csv_bool(...
                    metab_map_line{5}, 'is known metabolite');
                obj.bin=SpectrumBin(metab_map_line{6}, metab_map_line{7});
                obj.multiplicity=metab_map_line{8};
                obj.num_peaks=metab_map_line{9};
                if isnumeric(metab_map_line{10})
                    obj.j_values=metab_map_line{10};
                else
                    obj.j_values=str2double(regexp(metab_map_line{10},...
                        '\s*,\s*','split'));
                end
                obj.proton_id=metab_map_line{11};
                obj.hmdb_id=metab_map_line{12};
                obj.chenomix_was_used=CompoundBin.parse_csv_bool(...
                    metab_map_line{13}, 'chenomix was used');
                obj.id_source=metab_map_line{14};
                obj.nmr_isotope=metab_map_line{15};
                obj.notes=metab_map_line{16};
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



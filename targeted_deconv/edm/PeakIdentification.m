classdef PeakIdentification
    %PEAKIDENTIFICATION A manual or automatic identification of a peak within a CompoundBin
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
        
        %True if the identification was automatic, done by the computer for
        %a clean bin and merely looked over by the user rather than
        %actively entered by the user.  This is a manual identification if
        %was_automatic is false.
        was_automatic
        
        %The name of the user who made the manual identification or 
        %reviewed an automatic identification
        user_name
        
        %The account uuid on which this identification was performed.
        %This distinguishes between when the same user worked on different
        %computers (or at least different accounts on the same computer or 
        %the same account after resetting the matlab preferences, but both
        %exceptions are rare, so one can use the account uuid as a proxy
        %for a computer id)
        account_uuid
        
        %The date string for the date and time when the identification
        %was made - based on the system clock at that time.  In the 
        %default format returned by datestr
        date_string
    end
    
    methods
        function obj=PeakIdentification(ppm, height_index, spectrum_index, ...
                compound_bin, was_automatic, user_name, account_uuid, ...
                date_string)
        %Construct a PeakIdentification object by assigning the arguments
        %to the correspondingly named fields
        %
        %Syntax
        %
        % obj=PeakIdentification(ppm, height_index, spectrum_index, ...
        %       compound_bin, was_automatic, user_name, account_uuid, ...
        %       date_string)
            if nargin > 0 %Default constructor will not initialize
                obj.ppm = ppm;
                obj.height_index = height_index;
                obj.spectrum_index = spectrum_index;
                obj.compound_bin = compound_bin;
                obj.was_automatic = was_automatic;
                obj.user_name = user_name;
                obj.account_uuid = account_uuid;
                obj.date_string = date_string;
            end
        end
        
        function ret=eq(a,b)
        % Implements == operator: compare two PeakIdentification objects 
        % or arrays of the same for equality.  
        %
        % Objects are equal if their fields are all equal.
        % Arrays are equal if they have the same size and their
        % corresponding elements are all equal.
            if length(a) == length(b)
                if isempty(a)
                    ret = 0;
                else
                    pp = [a.ppm] == [b.ppm];
                    hi = [a.height_index] == [b.height_index];
                    si = [a.spectrum_index] == [b.spectrum_index];
                    cb = [a.compound_bin] == [b.compound_bin];
                    wa = [a.was_automatic] == [b.was_automatic];
                    un = [a.user_name] == [b.user_name];
                    au = [a.account_uuid] == [b.account_uuid];
                    ds = [a.date_string] == [b.date_string];
                    ret = pp & hi & si & cb & wa & un & au & ds;
                end
            else
                ret = 0;
            end
        end
    end
    
end


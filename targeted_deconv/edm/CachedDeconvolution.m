classdef CachedDeconvolution < handle
    %Stores the most recently calculated RegionDeconvolution and whether it is up-to-date
    %   Note that this is a handle class because of the model of an
    %   internal state being changed my mutators
    
    properties (SetAccess=private)
        %True if the stored deconvolution exists and is up-to-date. 
        %False otherwise.
        is_updated
        
        %Either a region deconvolution or [] (if none has been calculated).
        deconv
    end
    
    properties (Dependent)
        %True if there has been a deconvolution calculated
        exists
    end
    
    methods
        function obj=CachedDeconvolution()
        %Create an empty CachedDeconvolutionObject
            obj.is_updated = 0;
            obj.deconv = [];
        end
        
        function update_to(obj, deconv)
        %Sets obj.deconv to deconv and is_updated to true.  Special case: deconv==[] means is_updated=0.
        %
            obj.deconv = deconv;
            obj.is_updated = ~isempty(deconv);
            if length(deconv) > 1
                error(['CachedDeconvolution objects can hold at '...
                    'most one RegionDeconvolution object.']);
            end
        end
        
        function invalidate(obj)
        %Marks the currently stored deconvolution as not up-to-date
            obj.is_updated = 0;
        end
        
        function exists=get.exists(obj)
        %Calculate exists
            exists = ~isempty(obj.deconv);
        end
    end
    
end


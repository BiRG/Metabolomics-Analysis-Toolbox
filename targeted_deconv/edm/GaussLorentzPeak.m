classdef GaussLorentzPeak
    %GAUSSLORENTZPEAK Represents a Gaussian Lorentzian Peak
    % The parameters are the parameters of a Gaussian-Lorentzian peak
    % from Paul Anderson's Dissertation p. 28.   It should be noted that
    % the Lorentzian sub-component differs from the standard Lorentzian in
    % that it has been scaled by G.  This does not affect the half-height
    % width or other parameters, however, and it allows M to parameterize 
    % the height directly.  Note that G is also not the standard gamma 
    % parameter - it is twice the standard gamma.  The standard gamma is
    % half the width at half height.  The equations are:
    %
    % GL(x)=M(P L(x) + (1-P) N(x))
    %
    % L(x) = G^2 / (4(x-x0)^2 + G^2)
    %
    % N(x) = Exp(-(x-x0)^2 / (2 s^2) )
    %
    % s = G/2 Sqrt(2 Ln(2))
    %
    % The area under such a peak is given by 
    %
    % 1/2 M G (P Pi + (1 - P) Sqrt(Pi/Ln(2)))
    %
    % M  is the amplitude (that is, height) of the peak
    % G  is the width of the peak at half-height
    % P  is the proportion of Lorentzianness
    %       P=1: completely Lorentzian
    %       P=0: completely Gaussian
    % x0 The location of the peak 
    %
    % Note: these properties have other, more readable names.  The more
    % readable names are the ones with the faster access.
    %
    %
    % ---------------------------------------------------------------------
    % Examples
    % ---------------------------------------------------------------------
    % % A standard Gaussian
    % >> g=GaussLorentzPeak([1/sqrt(2*pi),2*sqrt(2*log(2)),0,0])
    %
    % g = 
    % 
    %   GaussLorentzPeak
    % 
    %   Properties:
    %                height: 0.3989
    %     half_height_width: 2.3548
    %        lorentzianness: 0
    %              location: 0
    %                     M: 0.3989
    %                     G: 2.3548
    %                     P: 0
    %                    x0: 0
    %                 sigma: 1
    %                  area: 1
    % 
    %   Methods
    %
    %
    %
    % % A standard Lorentzian
    % >> g=GaussLorentzPeak([1/pi,2,1,0])
    % 
    % g = 
    % 
    %   GaussLorentzPeak
    % 
    %   Properties:
    %                height: 0.3183
    %     half_height_width: 2
    %        lorentzianness: 1
    %              location: 0
    %                     M: 0.3183
    %                     G: 2
    %                     P: 1
    %                    x0: 0
    %                 sigma: 0.8493
    %                  area: 1
    % 
    %   Methods
    %
    % % Plot using at function
    % >> g=GaussLorentzPeak([1,1,0.5,0]); x=-3:0.1:3; plot(x,g.at(x))
    %
    %
    % % Plot a vector of peaks using the at function (note the syntax for
    % % creating a vector of peaks from a vector of parameters)
    % >> g = GaussLorentzPeak([1,1,1,0,1,1,0,0]); x=[-3:0.1:3];plot(x,[g.at(x)]) 
    
    properties (SetAccess=private)
        % The height of the maximum of the peak.  A scalar.
        height
        
        % The width of the peak at half-height.  A scalar.
        half_height_width
        
        % A Gauss-Lorentz peak is a linear interpolation between a Gaussian
        % and a Lorentzian peak.  This is the proportion of Lorentzianness.
        % It is a saclar that ranges from 0..1 inclusive where 0=Gaussian 
        % peak and 1 = Lorentzian peak.
        lorentzianness
        
        % The x-value at which the maximum occurs, the location of the
        % peak.  A scalar.
        location
    end
    
    properties (Dependent)
        % Less readable name for height
        M
        
        % Less readable name for half_height_width
        %
        % The width of the peak at half-height.
        G
        
        % Less readable name for lorentzianness 
        %
        % The proportion of the Lorentzian in the linear combination of
        % Gaussian and Lorentzian
        P
        
        % Less readable name for location
        %
        % The x-value at which the maximum occurs, the location of the peak
        x0
        
        % The standard deviation parameter given to the Gaussian
        sigma
        
        % The area under this peak.  A scalar.
        area
    end
    
    methods
        function objs=GaussLorentzPeak(array)
        % GaussLorentzPeak(array): [M,G,P,x0]=array
        %
        % The components of array are (in order) assigned to height,
        % half_height_width, lorentzianness, location.
        %
        % If there are more than 4 elements of array, then each group of 4 is
        % assigned to a new peak and the array of those peaks is returned.
        %
        % If an empty array is passed, an empty array is returned
        % 
        % If no arguments are given, creates an uninitialized
        % GaussLorentzPeak
            if nargin > 0 %If 0 args, don't initialize - default constructor
                if length(array) == 4
                    objs.height = abs(array(1));
                    objs.half_height_width = abs(array(2));
                    objs.lorentzianness = abs(array(3));
                    if objs.lorentzianness > 1
                        objs.lorentzianness = 1; 
                    end
                    objs.location = array(4);
                elseif mod(length(array),4) == 0 && ~isempty(array)
                    num_objs = length(array)/4;
                    objs(num_objs) = GaussLorentzPeak();
                    for i = 1:num_objs
                        i4=4*i;
                        objs(i)=GaussLorentzPeak(array((i4-3):i4));
                    end
                elseif isempty(array)
                    % Leave objs empty
                    objs(1)=[];
                else
                    error(['The array passed to the GaussLorentzPeak ', ...
                        'constructor must have a length that is a ', ...
                        'multiple of 4']);
                end
            end
        end
        
        function M=get.M(obj)
        % Getter method calculating M
            M=obj.height;
        end
        
        function G=get.G(obj)
        %Getter method calculating G
            G=obj.half_height_width;
        end
        
        function P=get.P(obj)
        %Getter method calculating P
            P=obj.lorentzianness;
        end
        
        function x0=get.x0(obj)
        %Getter method calculating x0
            x0=obj.location;
        end
        
        function area=get.area(obj)
        %Calculates the area under this peak
            area = 0.5 * obj.height * obj.half_height_width * ...
                (obj.lorentzianness * pi + ...
                 (1-obj.lorentzianness) * sqrt(pi/log(2)) );
        end
        
        function sigma = get.sigma(obj)
        %Calculates the sigma value for the Gaussian portion of the
        %Gaussian-Lorentzian curve
            sigma = obj.half_height_width ./ (2 * sqrt(2*log(2)));
        end
        
        function h=at(obj, x)
        %Calculates the heights of this peak at the x values in x
            if length(obj) == 1
                dx2=(x-obj.location).^2; % Squared distance to peak location
                G2=obj.half_height_width^2; %Squared half-height width
                L = G2 ./ (4*dx2 + G2);  % Lorentzian height
                s22 = -G2/(4*log(2));    % Negative twice Gaussian sigma
                N = exp(dx2 ./ s22);     % Gaussian height
                h=obj.height*(obj.lorentzianness*L + (1-obj.lorentzianness)*N);
            else
                %If speed is an issue, we can fully vectorize everything
                %here
                h=zeros(length(obj),length(x));
                for i=1:length(obj)
                    h(i,:)=obj(i).at(x);
                end
            end
        end
    end
    
end


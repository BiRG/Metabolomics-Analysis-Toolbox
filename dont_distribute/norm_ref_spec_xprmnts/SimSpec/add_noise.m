function collections = add_noise( collections, std_dev )
% Adds zero-mean gaussian noise with the given standard deviation to each spectrum in collections
%
% The noise is generated from the default random number stream.
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collections - a cell array of strucs, each of which has a Y field that is
%               a numeric array.
%
% std_dev     - a scalar giving the standard deviation of the noise. Must 
%               be non-negative
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% collections - the original cell array with gaussian noise added to each 
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> f.Y=0; ff=add_noise( {f}, 4 );
%
% f{1}.Y is set to same as 4*randn(1)
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%
for c=1:length(collections)
    n=randn(size(collections{c}.Y))*std_dev;
    collections{c}.Y = collections{c}.Y + n;
end

end


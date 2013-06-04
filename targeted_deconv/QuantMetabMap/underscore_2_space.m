function str = underscore_2_space( str )
% Given a string, returns the same string with underscores converted to spaces
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% str - (string)
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% str - (string) the input string with all underscores replaced by spaces
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> s = underscore_2_space( 'str' )
% s == 'str'
%
% >> s = underscore_2_space( '' )
% s == ''
%
% >> s = underscore_2_space( '_str_' )
% s == ' str '
%
% >> s = underscore_2_space( '._.' )
% s == '. .'
str(str == '_') = ' ';
end


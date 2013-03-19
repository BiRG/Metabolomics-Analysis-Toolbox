function with_initial_cap = capitalize(str)
% Return a copy of str with the first character capitalized by 'upper'
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% str - a string
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% with_initial_cap - the string with the first letter capitalized
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> s = capitalize('foo')
% 
% s = 'Foo'
%
% >> s = capitalize('Bar')
% 
% s = 'Bar'
%
% >> s = capitalize(' woo')
% 
% s = ' woo'
%
% >> s = capitalize('')
% 
% s = ''
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%

if isempty(str)
  with_initial_cap = str;
  return;
else
  with_initial_cap = [upper(str(1)), str(2:end)];
end

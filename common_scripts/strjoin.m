function str = strjoin( C, delimiter )
% Intersperse strings in cell array with delimiter making single string
%
% Usage: str = strjoin(C,delimiter)
% Usage: str = strjoin(C) 
%        - same as strjoin(C, ' ')
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% C - (a cell array of strings) The strings to be pasted together
%
% delimiter - (optional string) the string pasted between each pair of
%      cells.  Defaults to a single space.
%
%      Can also be a cell array of strings of length one less than the
%      length of C. In that case the resulting string alternates between
%      elements of C and elements of delimiter
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% str - the string
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> strjoin({})
% ''
% >> strjoin({},'asdf')
% ''
%
% % You can use a single delimiter between all strings - defaults to space
%
% >> strjoin({'Foo'},', ')
% 'Foo'
%
% >> strjoin({'Foo','Bar'})
% 'Foo Bar'
%
% >> strjoin({'Foo','Bar'},', ')
% 'Foo, Bar'
%
% >> strjoin({'Foo','Bar','Baz},', ')
% 'Foo, Bar, Baz'
%
% % You can specify each delimiter individually in a cell array
%
% >> strjoin({'Foo','Bar'},{', '})
% 'Foo, Bar'
%
% >> strjoin({'Foo','Bar','Baz'},{', ',': '})
% 'Foo, Bar: Baz'
%
% >> strjoin({'Foo','Bar','Baz'},{', '})
% Error: strjoin:wrong_length_delim_array
%
% >> strjoin({'Foo','Bar'},{', ',': '})
% Error: strjoin:wrong_length_delim_array
%
% >> strjoin({'Foo','Bar','Baz'},92)
% Error: 'strjoin:delimiter_type'
%
% >> strjoin({'Foo','Bar','Baz'},', ',': ')
% Error: 'strjoin:wrong_num_arg'
%
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2013) eric_moyer@yahoo.com
%

C = reshape(C, 1, []);
if isempty(C)
    str = '';
    return;
end 

% Check arguments
if nargin == 1
    delimiter = ' ';
elseif nargin == 2
    if iscell(delimiter)
        delimiter = reshape(delimiter, 1, []);
        if length(delimiter)+1 ~= length(C)
            error('strjoin:wrong_length_delim_array', ['The delimiter '...
                'array must contain exactly one less element than the '...
                'main string array.']);
        end
    elseif ~ischar(delimiter)
        error('strjoin:delimiter_type',['The delimiter must be either a '...
            'string or a cell array of strings.']);
    end
else
    error('strjoin:wrong_num_arg','Error: strjoin takes 1 or 2 arguments');
end

% Do the string concatenation
with_spaces = cell(1, size(C,2)*2-1);
if ischar(delimiter)
    with_spaces(1,2:2:end) = {delimiter};
else
    with_spaces(1,2:2:end) = reshape(delimiter,1,[]);
end
with_spaces(1,1:2:end) = C;
str = strcat(with_spaces);
str = str{1};

end


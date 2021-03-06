function str = to_str( in, extra_precision )
% To str returns a string that if entered as code would evaluate to in.
%
% Note that floats are rounded, so the 'eval to in' is not complete, but
% almost so.
%
% Also, objects are not supported as input - if you use an object, you
% should be writing your own toString method ;)  (Maybe this routine should
% check for objects with toString methods, but there is no guarantee that
% those would meet the semantics of "evaluate to recreate the original
% input'
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% in - a matlab variable
%
% extra_precision - (optional) a logical that is true if scalar matrices 
% should be printed with extra precision (18 decimal places). If omitted,
% treated as false.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% out - a string that if typed in matlab would evaluate to in.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% %% Structs %%
%
% >> foo.a = 12; foo.b = {'up', 'down'}; str = to_str(foo)
%
% str = 'cell2struct({[12];{''up'', ''down''}},{''a'',''b''}, 1)'
%
%
% %% Matrices %%
%
% >> str = to_str([1 2; 3 0])
%
% str = '[1, 2; 3, 0]'
%
%
% %% Multidimensional arrays %%
%
% >> foo=zeros(2,2,2); for i=1:8; foo(i)=i; end; str = to_str(foo)
%
% str = 'reshape([1; 2; 3; 4; 5; 6; 7; 8], 2, 2, 2)'
%
%
% %% Cell arrays %%
%
% >> str = to_str({12, 'twelve', [2, 2, 3]})
%
% str = '{[12], ''twelve'', [2, 2, 3]}'
%
%
% %% Multidimensional cell arrays %%
%
% >> foo=cell(2,2,3); for i=1:12; foo{i}={i}; end; str = to_str(foo)
%
% str = 'reshape({{[1]}; {[2]}; {[3]}; {[4]}; {[5]}; {[6]}; {[7]}; {[8]}; {[9]}; {[10]}; {[11]}; {[12]}}, [2,2,3])'
%
%
% %% Strings %%
%
% >> str = to_str('foo')
%
% str = '''foo'''
%
% >> str = to_str('')
%
% str = ['''','''']
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%
if ~exist('extra_precision', 'var')
    extra_precision = false;
end

if iscell(in) && is_matrix(in)
    % Cell matrices and vectors
    rows = size(in,1);
    cols = size(in,2);
    str = '{';
    for j = 1:cols
        if j == 1
            str = sprintf('%s%s', str, to_str(in{1,j}, extra_precision));
        else
            str = sprintf('%s, %s', str, to_str(in{1,j}, extra_precision));
        end
    end
    for i = 2:rows
        str = [str, '; ']; %#ok<AGROW>
        for j = 1:cols
            if j == 1
                str = sprintf('%s%s', str, to_str(in{i,j}, extra_precision));
            else
                str = sprintf('%s, %s', str, to_str(in{i,j}, extra_precision));
            end
        end        
    end
    str = [str, '}'];
elseif iscell(in) && ~is_matrix(in)
    % Muldidimensional cell arrays
    str=sprintf('reshape(%s,%s)',to_str(reshape(in, [], 1), extra_precision), to_str(size(in), extra_precision));    
elseif isstruct(in)
    % Structs and struct arrays
    str=sprintf('cell2struct(%s, %s, 1)',to_str(struct2cell(in), extra_precision), ...
        to_str(fieldnames(in), extra_precision));
elseif ischar(in)
    % Strings and string matrices
    rows = size(in,1);
    if rows == 1
        str = ['''',in,''''];
    elseif rows == 0
        str = ['''',''''];
    else
        str = ['[''', in(1,:), ''''];
        for i=2:rows
            str = [str,'; ''', in(i,:), '''']; %#ok<AGROW>
        end
        str = [str,']'];
    end
elseif is_matrix(in)
    % Scalar matrices
    rows = size(in,1);
    cols = size(in,2);
    str = '[';
    for j = 1:cols
        if j == 1
            if extra_precision
                str = sprintf('%s%.18g', str, in(1,j));
            else
                str = sprintf('%s%g', str, in(1,j));
            end
        else
            if extra_precision
                str = sprintf('%s, %.18g', str, in(1,j));
            else
                str = sprintf('%s, %g', str, in(1,j));
            end
        end
    end
    for i = 2:rows
        str = [str, '; ']; %#ok<AGROW>
        for j = 1:cols
            if j == 1
                if extra_precision
                    str = sprintf('%s%.18g', str, in(i,j));
                else
                    str = sprintf('%s%g', str, in(i,j));
                end
            else
                if extra_precision
                    str = sprintf('%s, %.18g', str, in(i,j));
                else
                    str = sprintf('%s, %g', str, in(i,j));
                end
            end
        end        
    end
    str = [str, ']'];
elseif length(size(in)) > 2
    % Multidimensional arrays
    str=sprintf('reshape(%s,%s)',to_str(reshape(in, [], 1), extra_precision), to_str(size(in), extra_precision));
else
    % Unknown type (probably object)
    error('to_str:unknown_type',['Variable of unanticipated type ', ...
        'passed to to_str']);
end

end


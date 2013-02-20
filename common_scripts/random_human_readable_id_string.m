function str = random_human_readable_id_string(num_bits, ...
                                               try_random_org)
% Return a string containing English words representing the given number of random bits of entropy
%
% Usage: str = random_human_readable_id_string(num_bits, use_random_org)
%
% num_bits - (scalar) the number of random bits to generate and
%            then represent. Must be a multiple of 15 and canot be 0.
%
% try_random_org - (logical) if true, attempts to get the random
%            values from random.org (if it cannot - either because
%            of no internet connection or not enough quota - it
%            falls back on the system random number generator. if
%            false, uses the system random number generator
% --------------------
% Example
% --------------------
%
% >> random_human_readable_id_string(45, false)
%
% Returns a 3 word string drawn from the system random number generator
%
% ans = 'alb emotive hugely'

assert(isscalar(num_bits));
assert(num_bits > 0);
assert(mod(num_bits,15) == 0);
assert(islogical(try_random_org));

num_ints = num_bits / 15;
ints = [];

% Try to get the integers from random.org if we should and if we can
if try_random_org
    bits_remaining = randorg;
    if bits_remaining >= num_bits
        ints = randorg(num_ints,[1,32768]); % returns a column vector
    end
end

% If we haven't gotten the ints from random.org, get them from the
% system random number generator
if isempty(ints)
    ints = randi(32768, num_ints, 1); % return a column vector
end

% Now, we've gotten the ints, convert each into a word and join
% them together using spaces to make the final string
assert(length(ints)==num_ints);
assert(all(ints >= 1 & ints <= 32768));
words = wordlist_32k;
words = words(ints);
if num_ints > 1
    str = sprintf('%s ',words{1:end-1});
    str = [str, words{end}];
else
    str = words{end};
end

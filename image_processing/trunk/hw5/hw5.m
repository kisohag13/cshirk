% Homework #5
% Chris Shirk
% Image Processing / Packet Video
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Source sequence: aacbaabaabaaaabcd

function hw5(src_seq)

    format long;

    % Detect whether we're overriding the default source sequence
    if (nargin ~= 1)
        disp 'Defaulting to src_seq = aacbaabaabaaaabcd'
        
        src_seq = ['a', 'a', 'c', 'b', 'a', 'a', 'b', 'a', 'a', 'b', ...
            'a', 'a', 'a', 'a', 'b', 'c', 'd'];
    end
    
    % Determine the symbol alphabet
    % Valid symbols are a-z
    prob('z') = 0;   % Implicitly get matrix dimensions set
    for i=1:length(src_seq)
        
        if (src_seq(i) < 'a') || (src_seq(i) > 'z')
            error 'Invalid symbol... valid symbols are a..z'
        end
        
        prob(src_seq(i)) = prob(src_seq(i)) + 1;
    end
    
    % Display alphabet probabilities
    %disp 'Source Symbol Probabilities:'
    %for i=1:length(prob)
        
    %    if (prob(i) == 0) continue; end
        
    %    disp(sprintf('%c = %.1f%%', i, prob(i) * 100 / length(src_seq)))
        
    %end
    
    
    %%% Need to define regions for each symbol...
    region_lower('z') = 0; % Implicitly set matrix dimensions
    region_upper('z') = 0;
    last = 0;
    src_seq_sorted = unique(sort(src_seq));
    for i=1:length(src_seq_sorted)
        
        tmp = prob(src_seq_sorted(i)) / length(src_seq);
        
        region_lower(src_seq_sorted(i)) = last;
        region_upper(src_seq_sorted(i)) = last + tmp;
        last = last + tmp;
        
    end
    
    
    %%% Display regions
    for i=1:length(src_seq_sorted)
        disp(sprintf('Symbol: %c = %.2f to %.2f', src_seq_sorted(i), ...
            region_lower(src_seq_sorted(i)), ...
            region_upper(src_seq_sorted(i))));
        
     
        
    end % uniqified symbols
    
    
    %%% Hmm
    lower = 0;
    upper = 1;
    for i=1:length(src_seq)
        lower_orig = lower;
        lower = lower_orig + (upper - lower_orig) * region_lower(src_seq(i));
        upper = lower_orig + (upper - lower_orig) * region_upper(src_seq(i));
        
        %upper - lower
        %region_upper(src_seq(i))
        
        disp(sprintf('Symbol: %c, Interval %.9f .. %.9f', src_seq(i), lower, upper));
    end
    
    halfway_pt = lower + (upper - lower) / 2;
    disp(sprintf('halfway point for final region = %.9f', halfway_pt));
    
    % Shift off least significant bits while we are still within the
    % lower..upper range
    shift = 1;
    while(1)
        
        test = floor(halfway_pt * 2^shift) / 2^shift;
        
        if (test >= lower) && (test <= upper) break; end
        
        shift = shift + 1;
    end
    
    disp 'Sadly, the dotrim argument does not seem to work on this Matlab'
    disp(sprintf('Dec value = %d\nBinary = %s\nLength = %d (excluding trailing zeros)', test, num2bin(test), shift));
    
    
    

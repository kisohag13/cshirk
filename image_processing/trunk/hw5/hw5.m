% Homework #5
% Chris Shirk
% Image Processing / Packet Video
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Source sequence: aacbaabaabaaaabcd

function hw5(src_seq)

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
    disp 'Source Symbol Probabilities:'
    for i=1:length(prob)
        
        if (prob(i) == 0) continue; end
        
        disp(sprintf('%c = %.1f%%', i, prob(i) * 100 / length(src_seq)))
        
        
    end
    
    
    % Need to define regions for each symbol...
    region_lower('z') = 0; % Implicitly set matrix dimensions
    region_upper('z') = 0;
    
    
    % Iteriate through source sequence and do the coding
    % Do the coding by determining if the given bit sequence
    % we build maps to only one region
    for i=1:length(src_seq)
        
        if (src_seq(i)
        
    end

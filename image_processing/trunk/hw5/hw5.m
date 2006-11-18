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
    


% sequence_length = 17
% p(a) = 10/17
% p(b) = 4/17
% p(c) = 2/17
% p(d) = 1/17


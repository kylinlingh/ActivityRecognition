function [realSwitchedPos] = getRealSwitchedPos(rawLabel)
    t_array = zeros(length(rawLabel),1);
    k = 1;
    for i = 2 : length(rawLabel)
        if rawLabel(i) - rawLabel(i-1) ~= 0
           t_array(k) = i;
           k = k + 1;
        end
    end
    realSwitchedPos = t_array(1:k-1);
end
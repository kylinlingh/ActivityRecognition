a = [1,2,3,5,6,8,10,11,13];
mergeCandidatePos(a);

function res = mergeCandidatePos(locs)
    res = zeros(length(locs), 1);
    pre_data = locs(1);
    res(1) = pre_data;
    k = 2;
    i = 2;
    while i <= length(locs)
        while i <= length(locs) && locs(i) == pre_data + 1
            pre_data = locs(i);
            i = i + 1;
        end
        if i <= length(locs)
            pre_data = locs(i);
            res(k) = locs(i);
            k = k + 1; 
            i = i + 1;
        end
        
    end
    res = res(1:k-1);
end
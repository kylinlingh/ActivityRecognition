function res = screenValidPos(inputArray, threshold)
   res = inputArray(1);
   j = 1;
   for i = 2 : length(inputArray)
       if inputArray(i) - res(j) < threshold
            res(j) = ceil((inputArray(i) + res(j)) / 2);
       else
           j = j + 1;
           res = [res, inputArray(i)];
       end   
   end
end
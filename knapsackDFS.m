function retvalue = knapsackDFS(WeightLim, Weight, Value, data)
%KNAPSACKDFS Summary of this function goes here
%   Detailed explanation goes here
    if Weight > WeightLim
        retvalue = 0;
        return;
    end
    if isempty(data)
        retvalue = Value;
        return;
    end
    withItem = knapsackDFS(WeightLim, Weight+data(end,2), Value+data(end,1), data(1:end-1,1:2));
    wOutItem = knapsackDFS(WeightLim, Weight, Value, data(1:end-1,1:2));
    
    retvalue = max(withItem,wOutItem);
    return;
end


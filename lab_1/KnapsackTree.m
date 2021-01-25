classdef KnapsackTree < handle
    %KNAPSACKTREE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Left
        Right
        Array
    end
    
    methods
        function obj = KnapsackTree(arr, idx, lim)
            if idx == lim+1
                obj.Array = arr;
                return;
            end
            arr(idx) = 0;
            obj.Left = KnapsackTree(arr, idx + 1, lim);
            arr(idx) = 1;
            obj.Right = KnapsackTree(arr, idx + 1, lim);
        end
    end
end


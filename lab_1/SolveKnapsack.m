dfs = Solve('dfs')
bfs = Solve('bfs')


function res = Solve(algo)
%SOLVEKNAPSACK Summary of this function goes here
%   Detailed explanation goes here
bw   = [    20 15
            40 32
            50 60
            36 80
            26 43
            64 120
            54 77
            18 6
            46 93
            28 35
            25 37];

len = length(bw);
tree = KnapsackTree(zeros(1,len), 1, len); % Build the tree
maxWeight = 420;

if strcmp(algo, 'dfs')
    s = CStack();
    s.push(tree);
    maxVal = 0;
    
    % Arrays are only saved in the leaves.
    while s.size > 0
        node = s.pop();

        if isempty(node.Array) % isempty indicates it's not a leaf.
            s.push(node.Right);
            s.push(node.Left);
            continue;
        end
        % Is a leaf
        [value, weight] = calculateValueWeight(node.Array, bw);
        if  weight <= maxWeight && value > maxVal
            maxVal = value;
            maxArr = node.Array;
%             disp(weight);
        end
    end
    
    res = maxArr;
    
elseif strcmp(algo, 'bfs')
    q = CQueue(); % q.push = enqueue | q.pop = dequeue
    q.push(tree); 
    maxVal = 0;
    
    % Arrays are only saved in the leaves.
    while q.size > 0
        node = q.pop();
        
        if isempty(node.Array)
            q.push(node.Left);
            q.push(node.Right);
            continue;
        end
        [value, weight] = calculateValueWeight(node.Array, bw);
        if  weight <= maxWeight && value > maxVal
            maxVal = value;
            maxArr = node.Array;
        end
    end
    
    res = maxArr;    
end
end
    

function [value, weight] = calculateValueWeight(Items, bw)
    value = 0;
    weight = 0;
    for i = 1:length(Items)
        if Items(i) == 1
            value = value + bw(i:i, 1);
            weight = weight + bw(i:i, 2);
        end
    end
end

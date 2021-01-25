runDFSTree()
% bw
% createTableNode([0 1 0 0 0], 1, bw, 0, 0)


function t = createTableNode(Items, Index)
    Name = {[binArr2decStr(Items) ' ' int2str(Index)]};
    t = table(Name, Items, Index);
end

function value = calculateValue(Items, bw)
    value = 0;
    for i = 1:length(Items)
        if Items(i) == 1
            value = value + bw(i:i, 1);
        end
    end
end
% function weight = calculateWeight(Items, bw)
%     weight = 0;
%     for i = 1:length(Items)
%         if Items(i) == 1
%             weight = weight + bw(i:i, 2);
%         end
%     end
% end

function res = runDFSTree()
%KNAPSACKDFSTREE Summary of this function goes here
%   Detailed explanation goes here
    import containers.Map
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
    weightLim = 420;
    maxItems = length(bw);
    g = graph();
    s = CStack();
    maxVal = 0;
    highestWeight = 0;
    
    % Add the initial empty selection (no items)
    Items = zeros(1,11);
    Name = ['-1' ' 1']; % BinaryNum + ArrIdx
%     s.push(Name);

    
    Name = {Name};
    Index = 1;
    t = table(Name, Items, Index);
%     res = t;
%     return;
    s.push(t);
    g = addnode(g, t);
    
    while s.size > 0
        top = s.pop();
%         res = top;
%         return;
%         disp(top);
        Name   = top{1:1, 'Name'};
        Items  = top{1:1, 'Items'};
        Index  = top{1:1, 'Index'};
        

        
%         len = length(Items) + 1;
        if Index == maxItems
            Value = calculateValue(Items, bw);
            if  Value > maxVal
                maxVal = Value;
%                 highestWeight = Weight;
    %             disp(Name);
            end
            continue;
        end
         
        
        % Right
        Items(Index) = 1;
        rightTable = createTableNode(Items, Index + 1); 
        rname = rightTable{1:1, 'Name'}{1};
        s.push(rightTable);
        g = addnode(g, rightTable);
        g = addedge(g, Name, rname);
        
        
        % Left
        Items(Index) = 0;
        leftTable = createTableNode(Items, Index + 1); 
        lname = leftTable{1:1, 'Name'}{1};
        s.push(leftTable);
        g = addnode(g, leftTable);
        g = addedge(g, Name, lname);
        
    end
    
    
    res = g;
end


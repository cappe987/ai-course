runDFSTree()
% bw
% createTableNode([0 1 0 0 0], 1, bw, 0, 0)


function t = createTableNode(Items, Index, bw, prevW, prevVal)
    Name = {[binArr2decStr(Items) ' ' int2str(Index)]};
    Value = prevVal;
    Weight = prevW;
    if Items(Index) == 1
        Value = Value + bw(Index:Index,1);
        Weight = Weight + bw(Index:Index,2);
    end
    t = table(Name, Items, Weight, Value, Index);
end

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
    g = graph();
    s = CStack();
    maxVal = 0;
    highestWeight = 0;
    
    % Add the initial empty selection (no items)
    Items = zeros(1, length(bw));
    Name = [binArr2decStr(Items) ' 1']; % BinaryNum + ArrIdx
%     s.push(Name);
    
    Name = {Name};
    Weight = 0;
    Value = 0;
    Index = 1;
    t = table(Name, Items, Weight, Value, Index);
    s.push(t);
    g = addnode(g, t);
    
    while s.size > 0
        top = s.pop();
%         res = top;
%         return;
        Name   = top{1:1, 'Name'};
        Items  = top{1:1, 'Items'};
        Weight = top{1:1, 'Weight'};
        Index  = top{1:1, 'Index'};
        Value  = top{1:1, 'Value'};

%         idx = findnode(g, top);
%         Name   = g.Nodes{idx:idx, 'Name'};
%         Items  = g.Nodes{idx:idx, 'Items'};
%         Weight = g.Nodes{idx:idx, 'Weight'};
%         Index = g.Nodes{idx:idx, 'Index'};
%         Value  = g.Nodes{idx:idx, 'Value'};
        
        if Value > maxVal
            maxVal = Value;
            highestWeight = Weight;
%             disp(Name);
        end
        
        Index = Index + 1;
        if Index > 11
            continue;
        end
         
        
        % Right
        Items(Index) = 1;
        rightTable = createTableNode(Items, Index, bw, Weight, Value); 
        rname = rightTable{1:1, 'Name'}{1};
        if rightTable{1:1, 'Weight'} <= weightLim  
%             s.push(rname);
            s.push(rightTable);
            g = addnode(g, rightTable);
            g = addedge(g, Name, rname);
        end
        
        % Left
        Items(Index) = 0;
        leftTable = createTableNode(Items, Index, bw, Weight, Value); 
        lname = leftTable{1:1, 'Name'}{1};
        if leftTable{1:1, 'Weight'} <= weightLim && ~(maxVal > leftTable{1:1, 'Value'} && highestWeight < leftTable{1:1, 'Weight'})
%             s.push(lname);
            s.push(leftTable);
            g = addnode(g, leftTable);
            g = addedge(g, Name, lname);
        end
    end
    
    
    res = g;
end


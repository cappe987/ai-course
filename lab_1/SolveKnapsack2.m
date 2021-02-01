
[val, arr] = SolveDFS()
% SolveBFS()

function [maxVal, maxArr] = SolveDFS()
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
maxWeight = 420;
s = CStack();
lim = len;
maxVal = 0;

init.arr = zeros(1,len);
init.idx = 1;
s.push(init);

while s.size > 0
    curr = s.pop();
    if curr.idx > lim
        [value, weight] = calculateValueWeight(curr.arr, bw);
        if value > maxVal && weight <= maxWeight
            maxVal = value;
            maxArr = curr.arr;
        end
        continue;
    end
    
    right.arr = curr.arr;
    right.arr(curr.idx) = 1;
    right.idx = curr.idx + 1;
    
    left.arr = curr.arr;
    left.arr(curr.idx) = 0;
    left.idx = curr.idx + 1;
    
    s.push(right);
    s.push(left);
end
end

function [maxVal, maxArr] = SolveBFS()
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
maxWeight = 420;
q = CQueue();
lim = len;
maxVal = 0;

init.arr = zeros(1,len);
init.idx = 1;
q.push(init);

while q.size > 0
    curr = q.pop();
    if curr.idx > lim
        [value, weight] = calculateValueWeight(curr.arr, bw);
        if value > maxVal && weight <= maxWeight
            maxVal = value;
            maxArr = curr.arr;
        end
        continue;
    end
    
    right.arr = curr.arr;
    right.arr(curr.idx) = 1;
    right.idx = curr.idx + 1;
    
    left.arr = curr.arr;
    left.arr(curr.idx) = 0;
    left.idx = curr.idx + 1;
    
    q.push(left);
    q.push(right);
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

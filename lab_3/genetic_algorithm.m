% NAME: berlin52
% TYPE: TSP
% COMMENT: 52 locations in Berlin (Groetschel)
% DIMENSION: 52
% EDGE_WEIGHT_TYPE: EUC_2D
% NODE_COORD_SECTION

% X = {X_1, ... , X_n}
% D = {1..n}
%
% Every variable must be unique.
% C = X_i != X_j. Forall i,j. (i != j) 
%
% Let E(X_i, X_j) be the euclidean distance between city i and j.
% Minimize sum_{1}^{n-1}{E(X_i, X_{i+1)}


% nodes = createNodes(52);
% plot([nodes.X], [nodes.Y], '-o');
% g = graph();
% g = addnode(g, 52);
% 
% for i = 1:51
%     g = addedge(g, i, i+1);
% end
% plot(g);
% arr = zeros(2,52);
% arr(1:52) = [nodes.X];
% arr(53:104) = [nodes.Y]; 
% scatter([nodes.X], [nodes.Y])
% arr(1) = [nodes.X];
% arr(2) = [nodes.Y];

% createNodes(52)

tic
res = Run();
fitness(res{1})
toc
plot([res{1}.X], [res{1}.Y], '-o');
% temp = res;

% new = cell(50,2);

% for i = 1:50
%     new(i,1) = temp(i);
%     new(i,2) = {fitness(temp{i})};
% end
% sorted = sortrows(new, 2);

function population = generation(population, PS, genlimit, CR, MR, k, nodecount)
selectedcount = PS/k;
selected = cell(1,selectedcount);
while genlimit ~= 0
    
    % Tournament Selection
    population = population(randperm(PS, PS)); % Randomize order.

    best = Inf;
    partition = reshape(population, k, []); % Partition into groups
    for i = 1:PS/k
        currBest = Inf;
        for j = 1:k
            value = fitness(partition{j,i});
            if value < currBest
                currBest = value;
                bestIdx = j;
            end
        end
        selected{i} = partition{bestIdx,i};
        if currBest < best
            best = currBest;
            bestIndex = [bestIdx i];
        end
    end
    
%     if best < 9000
%         res = population;
%         return
%     end
        
    % Crossover
%     population = cell(1,PS);
    idx = 1;
    for i = 1:PS/2
        p1 = selected{randsample(selectedcount, 1)};
        p2 = selected{randsample(selectedcount, 1)};
        if rand() < CR
            from = randsample(nodecount-2, 1)+1;
            to   = randsample(nodecount-2, 1)+1;
            if from > to
                temp = to;
                to = from;
                from = temp;
            end
            child1 = crossover(p1, p2, from, to, nodecount);
            child2 = crossover(p2, p1, from, to, nodecount);
            population{idx} = child1;
            population{idx + 1} = child2;
        else
            population{idx} = p1;
            population{idx + 1} = p2;
        end
        idx = idx + 2;
    end

    
    % Mutation
    for i = 1:PS
        if rand() < MR
            i1 = randsample(nodecount-2, 1) + 1;
            i2 = randsample(nodecount-2, 1) + 1;
            temp = population{i}(i1);
            population{i}(i1) = population{i}(i2);
            population{i}(i2) = temp;
        end
    end
    
    
    % Replacement
    % Using best individual that we calculated earlier.
    population{1} = partition{bestIndex(1), bestIndex(2)};
    
    genlimit = genlimit - 1;
%     res = generation(new_population, PS, genlimit - 1, CR, MR, k, nodecount);
end % While Loop

end


function child = crossover(p1, p2, from, to, nodecount)
    child = Node.empty(0,nodecount);  
    child(1) = p1(1); % Set city 1 first
    taken = p1(from:to);
    [~, ia] = setdiff([p2.ID], [1 taken.ID], 'stable');
    p2noP1 = p2(ia);
    
    child(2:from-1) = p2noP1(1:from-2);
    child(from:to) = taken; 
%     if to ~= nodecount
    

    child(to+1:nodecount-1) = p2noP1(from-1:end);
%     end
    child(nodecount) = p1(1); % Set city 1 last.
end

function child = crossover2(p1, p2, from, to, nodecount)
    % Old crossover method. New version is a bit faster and much shorter.

    child = Node.empty(0,nodecount);  
    taken = zeros(1, to-from+1);
    for i = from:to
        taken(i) = p1(i).ID;
    end
    p2idx = 1;
    i = 1;
    while i < from
       if ~ismember(p2(p2idx).ID, taken)
           child(i) = p2(p2idx);
           p2idx = p2idx + 1;
           i = i + 1;
       else
           p2idx = p2idx + 1;
       end
    end
    for i = from:to
        child(i) = p1(i);
    end
    
    i = to + 1;
    while p2idx <= nodecount
       if ~ismember(p2(p2idx).ID, taken)
           child(i) = p2(p2idx);
           p2idx = p2idx + 1;
           i = i + 1;
       else
           p2idx = p2idx + 1;
       end
    end
end

function value = fitness(indv)
    value = 0;
    for i = 1:length(indv)-1
        % Not using a function for the euclid calculations took off ~30s.
        value = value + sqrt((indv(i+1).X - indv(i).X)^2 + (indv(i+1).Y - indv(i).Y)^2);
    end
end

function nodes = createNodes(nodecount)
    fid = fopen('berlin52.txt', 'r');
    
    format = '%d %f %f';
    data = transpose(fscanf(fid, format, [3 nodecount]));    
    nodes = Node.empty(0,nodecount);
    for i = 1:nodecount
        nodes(i) = Node(data(i,1), data(i,2), data(i,3));
    end
end

function res = Run()
    nodecount = 52;
    nodes = createNodes(nodecount);
    
    RNG = 1;
    rng(RNG);
    PS = 500;
    GEN = 500;
    CR = 0.8;
    MR = 0.5;
    k = 10;
    disp(strcat("RNG: ", num2str(RNG)));
    disp(strcat("PS: ", num2str(PS)));
    disp(strcat("GEN: ", num2str(GEN)));
    disp(strcat("CR: ", num2str(CR)));
    disp(strcat("MR: ", num2str(MR)));
    disp(strcat("k: ", num2str(k)));
    
    initial = cell(1,PS);
    
    for i = 1:PS
        n = Node.empty(0,53);
        n(1) = nodes(1);
        n(2:nodecount) = nodes(randperm(nodecount-1, nodecount-1)+1);
        n(nodecount+1) = nodes(1);
        initial{i} = n;
    end
%     res = initial;
    population = generation(initial, PS, GEN, CR, MR, k, nodecount+1);
    res = population; % fitness(population{1});
%     for i = 1:nodecount+1
%         disp(res{1,1}(1,i).ID);
%     end
end










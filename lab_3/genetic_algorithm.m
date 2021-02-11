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

% tic
% res = Run();
% fitness(res{1})
% toc
% plot([res{1}.X], [res{1}.Y], '-o');

% case1.RNG = 1;
% case1.PS = 500;
% case1.GEN = 500;
% case1.CR = 0.8;
% case1.MR = 0.01;
% case1.k = 10;

c.RNG = 2;
c.PS = 1000;
c.GEN = 200;
c.CR = 0.8;
c.MR = 0.01;
c.k = 10;
% cs = [case2 case3 case4 case5];
% cs = [c];
% function Run(Case, RNG, PS, GEN, CR, MR, k)

% for i = 1:length(cs)
%     c = cs(i);
[pop, gens] = Run(1, c.RNG, c.PS, c.GEN, c.CR, c.MR, c.k);
plot(gens);
% nodes = createNodes(52);
% plot([nodes(pop(1,:)).X], [nodes(pop(1,:)).Y], '-o');

% end

% temp = res;

% new = cell(50,2);

% for i = 1:50
%     new(i,1) = temp(i);
%     new(i,2) = {fitness(temp{i})};
% end
% sorted = sortrows(new, 2);

function [population, bestPerGen] = generation(population, PS, genlimit, CR, MR, k, nodecount, distmat)
selectedcount = PS/k;
selected = zeros(selectedcount, nodecount);
% fitnessArr = zeros(1,PS);
gen = 1;
bestPerGen = zeros(1,genlimit);
while genlimit ~= 0
%     % Roulette selection
%     sum = 0;
%     best = Inf;
%     for i = 1:PS
%         val = fitness(population{i});
%         sum = sum + val;
%         fitnessArr(i) = val;
%         if val < best
%             best = val;
%             bestIndividual = population{i};
%         end
%     end
% 
%     for i = 1:PS
%         fitnessArr(i) = fitnessArr(i)/sum;
%     end
    
%     for i = 1:PS
%         population{i} = pickOne(population, fitnessArr);
%     end
    
    
%     Tournament Selection
%     population = population(randperm(PS, PS), :); % Randomize order.

    best = Inf;
%     partition = reshape(population, k, []); % Partition into groups
    rowsToTake = randperm(PS, PS); % Generate a permutation for indices
    rowIdx = 1;
    for i = 1:PS/k
        currBest = Inf;
        for j = 1:k
            idx = rowsToTake(rowIdx);
            value = fitness(population(idx, :), distmat);
            rowIdx = rowIdx + 1;
            if value < currBest
                currBest = value;
                bestIdx = idx;
            end
        end
        selected(i,:) = population(bestIdx, :);
        if currBest < best
            best = currBest;
            bestIndividual = selected(i,:);
        end
    end
    bestPerGen(gen) = best;
    gen = gen + 1;

        
    % Crossover
%     population = cell(1,PS);
    idx = 1;
    for i = 1:PS
        p1 = selected(randsample(selectedcount, 1), :);
        p2 = selected(randsample(selectedcount, 1), :);
%         p1 = pickOne(population, fitnessArr);
%         p2 = pickOne(population, fitnessArr);
        if rand() < CR
            from = randsample(nodecount-1, 1)+1;
            to   = randsample(nodecount-1, 1)+1;
            if from > to
                temp = to;
                to = from;
                from = temp;
            end
            child1 = crossover(p1, p2, from, to, nodecount);
%             child2 = crossover(p2, p1, from, to, nodecount);
            population(i,:) = child1;
%             population{idx} = child1;
%             population{idx + 1} = child2;
        else
            population(i,:) = p1;
%             population{idx} = p1;
%             population{idx + 1} = p2;
        end
%         idx = idx + 2;
    end

    
    % Mutation
    for i = 1:PS
        for j = 1:nodecount
            if rand() < MR
                i1 = randsample(nodecount-1, 1) + 1;
                i2 = randsample(nodecount-1, 1) + 1;
%                 if i1 == nodecount-1
%                     i2 = i1-1;
%                 else
%                     i2 = i1+1;
%                 end
                if i2 < i1
                    temp = i1;
                    i1 = i2;
                    i2 = temp;
                end
                population(i,i1:i2) = flip(population(i,i1:i2));
                  
%                 temp = population(i,i1);
%                 population(i,i1) = population(i,i2);
%                 population(i,i2) = temp;
            end
        end
    end
    
    
    % Replacement
    % Using best individual that we calculated earlier.
%     population{1} = partition{bestIndex(1), bestIndex(2)};
    population(1,:) = bestIndividual;
    genlimit = genlimit - 1;
%     res = generation(new_population, PS, genlimit - 1, CR, MR, k, nodecount);
end % While Loop

end

function res = pickOne(pop, probabilities)
   idx = 1;
   r = rand();
   while r > 0
       r = r - probabilities(idx);
       idx = idx + 1;
   end
   res = pop{idx - 1};
end

function child = crossover(p1, p2, from, to, nodecount)
    child = zeros(1,nodecount);  
    child(1) = 1; % Set city 1 first
    taken = p1(from:to);
    [~, ia] = setdiff(p2, [1 taken], 'stable');
    p2noP1 = p2(ia);
    
    child(2:from-1) = p2noP1(1:from-2);
    child(from:to) = taken; 
%     if to ~= nodecount
    

    child(to+1:nodecount) = p2noP1(from-1:end);
%     end
%     child(nodecount) = p1(1); % Set city 1 last.
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

function value = fitness(indv, distmat)
    value = 0;
    for i = 1:length(indv)-1
        value = value + distmat(indv(i), indv(i+1));
    end
    value = value + distmat(1, indv(length(indv))); % Back to start
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

function [population, gens] = Run(Case, RNG, PS, GEN, CR, MR, k)
    nodecount = 52;
    nodes = createNodes(nodecount);
    
    distmat = zeros(nodecount, nodecount);
    for i = 1:nodecount
        for j = 1:nodecount
            distmat(i,j) = sqrt((nodes(j).X - nodes(i).X)^2 + (nodes(j).Y - nodes(i).Y)^2);
        end
    end
    
    rng(RNG);
    
%     initial = cell(1,PS);
    initial = zeros(PS,52);
    for i = 1:PS
        initial(i,1) = 1;
        initial(i,2:nodecount) = randperm(nodecount-1, nodecount-1)+1;
%         n(nodecount+1) = nodes(1);
%         initial{i} = n;
    end
%     res = initial;
    tic
    [population, gens] = generation(initial, PS, GEN, CR, MR, k, nodecount, distmat);
    disp(strcat("--- Case ", num2str(Case), " ---"));
    disp(strcat("RNG: ", num2str(RNG)));
    disp(strcat("PS: ", num2str(PS)));
    disp(strcat("GEN: ", num2str(GEN)));
    disp(strcat("CR: ", num2str(CR)));
    disp(strcat("MR: ", num2str(MR)));
    disp(strcat("k: ", num2str(k)));
    disp(fitness(population(1,:), distmat))
    toc
%     res = population; % fitness(population{1});
%     for i = 1:nodecount+1
%         disp(res{1,1}(1,i).ID);
%     end
end










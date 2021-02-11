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

RNG = 2;
PS = 1000;
GEN = 200;
CR = 0.8;
MR = 0.01;
k = 10;
[pop, gens] = Run(1, RNG, PS, GEN, CR, MR, k);
plot(gens);
% nodes = createNodes(52);
% plot([nodes(pop(1,:)).X], [nodes(pop(1,:)).Y], '-o');

function [population, bestPerGen] = generation(population, PS, genlimit, CR, MR, k, nodecount, distmat)
selectedcount = PS/k;
selected = zeros(selectedcount, nodecount);
gen = 1;
bestPerGen = zeros(1,genlimit);
while gen <= genlimit
%   Tournament Selection
    best = Inf; % Best in current generation
    rowsToTake = randperm(PS, PS); % Generate a permutation for indices
    rowIdx = 1;
    for i = 1:PS/k
        currBest = Inf; % Best in current tournament
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
        
    % Crossover
    for i = 1:PS 
        % Randomly select two parents from tournament winners
        p1 = selected(randsample(selectedcount, 1), :);
        p2 = selected(randsample(selectedcount, 1), :);
        if rand() < CR
            % Select range for crossover slice
            from = randsample(nodecount-1, 1)+1;
            to   = randsample(nodecount-1, 1)+1;
            if from > to % Swap in case from is greater than to
                temp = to;
                to = from;
                from = temp;
            end
            child1 = crossover(p1, p2, from, to, nodecount);
            population(i,:) = child1;
        else
            population(i,:) = p1; % No crossover done
        end
    end

    
    % Mutation
    % Flip a slice in the order
    for i = 1:PS
        for j = 1:nodecount
            if rand() < MR
                from = randsample(nodecount-1, 1) + 1;
                to = randsample(nodecount-1, 1) + 1;
                if to < from % Swap in case from is greater than to
                    temp = from;
                    from = to;
                    to = temp;
                end
                population(i,from:to) = flip(population(i,from:to));
            end
        end
    end
    
    
    % Replacement
    % Using best individual that we calculated earlier.
    population(1,:) = bestIndividual;
    gen = gen + 1;
end % While Loop

end

function child = crossover(p1, p2, from, to, nodecount)
    child = zeros(1,nodecount);  
    child(1) = 1; % Set city 1 first
    taken = p1(from:to); % Slice from p1
    [~, ia] = setdiff(p2, [1 taken], 'stable');
    p2noP1 = p2(ia); % p2 without the elements taken from p1
    
    child(2:from-1) = p2noP1(1:from-2); % Insert from p2
    child(from:to) = taken; % Insert slice from p1
    child(to+1:nodecount) = p2noP1(from-1:end); % Insert rest of p2
end

function value = fitness(indv, distmat)
    value = 0;
    for i = 1:length(indv)-1 % All cities
        value = value + distmat(indv(i), indv(i+1)); 
    end
    value = value + distmat(1, indv(length(indv))); % Last city -> start
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
    
    initial = zeros(PS,52);
    for i = 1:PS
        initial(i,1) = 1;
        initial(i,2:nodecount) = randperm(nodecount-1, nodecount-1)+1;
    end

    tic
    [population, gens] = generation(initial, PS, GEN, CR, MR, k, nodecount, distmat);
    disp(strcat("--- Case ", num2str(Case), " ---"));
    disp(strcat("RNG: ", num2str(RNG)));
    disp(strcat("PS: ", num2str(PS)));
    disp(strcat("GEN: ", num2str(GEN)));
    disp(strcat("CR: ", num2str(CR)));
    disp(strcat("MR: ", num2str(MR)));
    disp(strcat("k: ", num2str(k)));
    disp(strcat("Fitness: ", num2str(fitness(population(1,:), distmat))));
    toc
end










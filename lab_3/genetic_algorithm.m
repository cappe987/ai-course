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
rng(1);





tic
res = Run();
fitness(res{1})
toc

temp = res;

new = cell(50,2);

for i = 1:50
    new(i,1) = temp(i);
    new(i,2) = {fitness(temp{i})};
end
sorted = sortrows(new, 2);


% euclid(res(1), res(2))

% fitness(res{1})

% a = res{1}
% b = res{2}

% crossover(a, b, 2, 3, 52)


function res = generation(population, PS, genlimit, nodecount)
    if genlimit == 0
        res = population;
        return
    end
    
    % Selection
    % Tournament Selection with k=2
    population = population(randperm(PS, PS)); % Randomize order.
    i = 1;
    idx = 1;
    selectedcount = PS/2;
    selected = cell(1,selectedcount);
    best = Inf;
    while i < PS
        f1 = fitness(population{i});
        f2 = fitness(population{i+1});
        if f1 < f2
            selected{idx} = population{i};
        else
            selected{idx} = population{i+1};
        end
        if f1 < best
            best = f1;
            bestIndividual = population{i};
        end
        if f2 < best
            best = f2;
            bestIndividual = population{i+1};
        end
        
        idx = idx + 1;
        i = i + 2;
    end
        
    % Crossover
    new_population = cell(1,PS);
    idx = 1;
    for i = 1:selectedcount
        p1 = selected{randsample(selectedcount, 1)};
        p2 = selected{randsample(selectedcount, 1)};

        from = randsample(nodecount, 1);
        to   = randsample(nodecount, 1);
        if from > to
            temp = to;
            to = from;
            from = temp;
        end
        child1 = crossover(p1, p2, from, to, nodecount);
        child2 = crossover(p2, p1, from, to, nodecount);
        new_population{idx} = child1;
        new_population{idx + 1} = child2;
        idx = idx + 2;
    end

    
    % Mutation
    for i = 1:PS
        if rand() < 0.3
            i1 = randsample(nodecount, 1);
            i2 = randsample(nodecount, 1);
            temp = new_population{i}(i1);
            new_population{i}(i1) = new_population{i}(i2);
            new_population{i}(i2) = temp;
        end
    end
    
    
    % Replacement
    % Using best individual that we calculated earlier.
    new_population{1} = bestIndividual;
    
    
    res = generation(new_population, PS, genlimit - 1, nodecount);
end


function child = crossover(p1, p2, from, to, nodecount)
    child = Node.empty(0,nodecount);  
    taken = arrayfun(@(x) (x.ID), p1(from:to));
    p2idx = 1;
    i = 1;
%     disp(p1);
%     disp(p2);
    while i < from
       if ~ismember(p2(p2idx).ID, taken)
%            disp("test");
           child(i) = p2(p2idx);
           p2idx = p2idx + 1;
           i = i + 1;
       else
           p2idx = p2idx + 1;
       end
    end
    for i = from:to
% %         disp(i);
%         disp(p1(i));
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
%     for i = 1:(from-1)
%         if ~ismember(p2(i).ID, taken)
%             child(i) = p2(i);
% %             p2idx = p2idx + 1;
%         end
%         if i >= from && i <= to
%             child(i) = p1(i);
%         else
%             if ~ismember(p2(p2idx).ID, taken)
%                 child(i) = p2(p2idx);
%                 p2idx = p2idx + 1;
%             end
%         end
%     end
end

function value = fitness(individual)
    value = 0;
    for i = 1:length(individual)-1
        value = value + euclid(individual(i), individual(i+1));
    end
end


function dist = euclid(n1, n2)
    dist = sqrt((n2.X - n1.X)^2 + (n2.Y - n1.Y)^2);
end



function res = Run()
    nodecount = 52;
    fid = fopen('berlin52.txt', 'r');
    
    format = '%d %f %f';
    data = transpose(fscanf(fid, format, [3 nodecount]));    
    nodes = Node.empty(0,nodecount);
    for i = 1:nodecount
        nodes(i) = Node(data(i,1), data(i,2), data(i,3));
    end
    
    
    PS = 50;
    F  = 2;
    CR = 1;
    initial_population = cell(1,PS);
    
    for i = 1:PS
       initial_population{i} = nodes(randperm(nodecount, nodecount));
    end
    
%     initial_population = nodes(randperm(52,52)); % Random permutation

%     for i = 1:PS
%         disp(fitness(initial_population{i}));
%     end
    
%     disp("Generation 2");
    population = generation(initial_population, PS, 2000, nodecount);
    res = population; % fitness(population{1});
end










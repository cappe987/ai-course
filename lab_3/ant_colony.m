



RNG = 1;
alpha = 0.5;
beta = 0.5;
evaporation_rate = 0.8;
PS = 10;
GEN = 100;

disp(strcat("RNG: ", num2str(RNG)));
disp(strcat("PS: ", num2str(PS)));
disp(strcat("GEN: ", num2str(GEN)));
disp(strcat("Alpha: ", num2str(alpha)));
disp(strcat("Beta: ", num2str(beta)));
disp(strcat("Evaporation rate: ", num2str(ceil(evaporation_rate))));

tic
[pop, gens, best] = Run(RNG, PS, GEN, alpha, beta, evaporation_rate);
disp(strcat("Fitness: ", num2str(best)));
plot(gens);

toc

function nodes = createNodes(nodecount)
    fid = fopen('berlin52.txt', 'r');
    
    format = '%d %f %f';
    data = transpose(fscanf(fid, format, [3 nodecount]));    
    nodes = Node.empty(0,nodecount);
    for i = 1:nodecount
        nodes(i) = Node(data(i,1), data(i,2), data(i,3));
    end
end

function value = fitness(ant, distmat)
    value = 0;
    for i = 1:length(ant)-1 % All cities
        value = value + distmat(ant(i), ant(i+1)); 
    end
    value = value + distmat(1, ant(length(ant))); % Last city -> start
end

function [ants, gens, best] = Run(RNG, PS, GEN, alpha, beta, evap_rate)
    nodecount = 52;
    nodes = createNodes(nodecount);
    
    distmat = zeros(nodecount, nodecount);
    for i = 1:nodecount
        for j = 1:nodecount
            distmat(i,j) = sqrt((nodes(j).X - nodes(i).X)^2 + (nodes(j).Y - nodes(i).Y)^2);
        end
    end
    
    eta = zeros(nodecount, nodecount); % Heuristic matrix
    for i = 1:nodecount
        for j = 1:nodecount
            if i == j
                eta(i,j) = NaN;
            else
                eta(i,j) = 1/distmat(i,j);
            end
        end
    end
    
    ants = zeros(PS, nodecount);
    for i = 1:PS
        ants(i,1) = 1; % Set first node to start
    end
    
    [ants, gens, best] = generation(ants, nodecount, distmat, PS, GEN, eta, alpha, beta, evap_rate);
    
end


function [ants, bestPerGen, globalBest] = generation(initial, nodecount, distmat, PS, genlimit, eta, alpha, beta, evap_rate)
gen = 1;
costs = zeros(1,PS);
bestPerGen = zeros(1,genlimit);
globalBest = Inf;
% tau = zeros(nodecount, nodecount);
tau(1:nodecount,1:nodecount) = 10; % Initialize all to 10;
% eta = zeros(nodecount, nodecount);

while gen <= genlimit
    ants = initial;

    % Build solutions
    for i = 2:nodecount
        for k = 1:PS
            ants(k,i) = transition_rule(ants(k,:), tau, eta, alpha, beta, nodecount);
        end
    end
    
    % Calculate total cost and find best ant
    best = Inf;
    for k = 1:PS
        cost = fitness(ants(k,:), distmat);
        costs(k) = cost;
        if cost < best
            best = cost;
            bestAnt = ants(k,:);
        end
    end
    
    % Update pheromones
    for i = 1:nodecount
        for j = 1:nodecount
            tau(i,j) = pheromone_update(i, j, tau(i,j), evap_rate, ants, costs, PS);
        end
    end
%     function pheromone = pheromone_update(r, s, pheromone, evaporation_rate, ants, costs, PS)

    if best < globalBest
        globalBest = best;
    end
    bestPerGen(gen) = globalBest;
    
    
    gen = gen + 1;
end

end


function node = transition_rule(ant, tau, eta, alpha, beta, nodecount)
    rem = strfind(ant, 0); 
    r = ant(rem(1) - 1); % Find current node
    % If rem is empty, it has reached the end. Shouldn't happen.
    
    probs = zeros(1,nodecount);
    probIds = zeros(1,nodecount);
    notvisited = setdiff(1:nodecount, ant);
    
    usum = 0;
    for i = 1:length(notvisited)
        u = notvisited(i);
        if r ~= u
            usum = usum + tau(r,u)^alpha * eta(r,u)^beta;
        end
    end
    
    % Create probability vector
    for i = 1:length(notvisited)
        s = notvisited(i);
        if r ~= s
            probs(i) = (tau(r,s)^alpha * eta(r,s)^beta) / usum;
            probIds(i) = s;
        else
            probs(i) = 0;
            probIds(i) = NaN;
        end
    end
        
    % Select random node based on probability
    idx = 1;
    sum = 0;
    random = rand();
    while sum <= random
        sum = sum + probs(idx);
        idx = idx + 1;
    end
    idx = idx - 1;
    node = probIds(idx);
end

function pheromone = pheromone_update(r, s, pheromone, evaporation_rate, ants, costs, PS)
    sum = 0;
    edge = [r s];
    for k = 1:PS
         % \delta\tau_{rs}^{k}
%         for i = 1:51
%             if ants(k,i) == r && ants(k,i+1) == s
%                 sum = sum + (1 / costs(k));
%                 break;
%             end
%         end
        if strfind(ants(k,:), edge) % Checks if edge is subvector of path.
            sum = sum + (1 / costs(k));
        end
    end
        
    pheromone = (1 - evaporation_rate) * pheromone + sum;
end









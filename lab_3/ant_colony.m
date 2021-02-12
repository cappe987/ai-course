



RNG = 1;
alpha = 0.5; % Saved information \alpha >= 0
beta = 2; % Heuristic information \beta >= 1
evaporation_rate = 0.8;
PS = 50;
GEN = 100;

disp(strcat("RNG: ", num2str(RNG)));
disp(strcat("PS: ", num2str(PS)));
disp(strcat("GEN: ", num2str(GEN)));
disp(strcat("Alpha: ", num2str(alpha)));
disp(strcat("Beta: ", num2str(beta)));
disp(strcat("Evaporation rate: ", num2str(evaporation_rate)));

tic
[bestAnt, gens, best] = Run(RNG, PS, GEN, alpha, beta, evaporation_rate);
disp(strcat("Fitness: ", num2str(ceil(best))));
plot(gens);
% nodes = createNodes(52);
% plot([nodes(bestAnt).X], [nodes(bestAnt).Y], '-o');

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

function [bestAnt, gens, best] = Run(RNG, PS, GEN, alpha, beta, evap_rate)
    nodecount = 52;
    nodes = createNodes(nodecount);
    rng(RNG);
    
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
        ants(i,:) = 1:52;
    end
    
    [bestAnt, gens, best] = generation(ants, nodecount, distmat, PS, GEN, eta, alpha, beta, evap_rate);
    
end


function [globalBestAnt, bestPerGen, globalBest] = generation(initial, nodecount, distmat, PS, genlimit, eta, alpha, beta, evap_rate)
gen = 1;
costs = zeros(1,PS);
bestPerGen = zeros(1,genlimit);
globalBest = Inf;
tau(1:nodecount,1:nodecount) = 10; % Initialize all to 10;

while gen <= genlimit
    ants = initial;

    % Build solutions
    for i = 2:nodecount
        for k = 1:PS
            ants(k,:) = transition_rule(ants(k,:), tau, eta, alpha, beta, nodecount, i);
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
    sums = zeros(nodecount, nodecount);
    % Collect the sums of all costs for the edges. 
    % Then update all tau at once.
    for k = 1:PS
        ant = ants(k,:);
        for i = 1:nodecount-1 
            r = ant(i);
            s = ant(i+1);
            sums(r,s) = sums(r,s) + (1 / costs(k));
        end
    end
    tau = (1 - evap_rate) * tau + sums;
    
    if best < globalBest
        globalBest = best;
        globalBestAnt = bestAnt;
    end
    bestPerGen(gen) = globalBest;
    
    
    gen = gen + 1;
end

end


function ant = transition_rule(ant, tau, eta, alpha, beta, nodecount, nextIndex)
    % If rem is empty, it has reached the end. Shouldn't happen.
    % Not visited nodes are the ones ater nextIndex. 
    r = ant(nextIndex-1);
    
    probs = zeros(1,nodecount);
    probIndices = zeros(1,nodecount);
    
    usum = 0;
    for i = nextIndex:nodecount % Not visited
        u = ant(i);
        if r ~= u
            usum = usum + tau(r,u)^alpha * eta(r,u)^beta;
        end
    end
    
    % Create probability vector
    idx = 1;
    for i = nextIndex:nodecount
        s = ant(i);
        if r ~= s
            probs(idx) = (tau(r,s)^alpha * eta(r,s)^beta) / usum;
            probIndices(idx) = i;
        else
            probs(idx) = 0;
            probIndices(idx) = NaN;
        end
        idx = idx + 1;
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
    % Switch next and the one found to be next. 
    % So not visited are kept at the end.
    ant([nextIndex probIndices(idx)]) = ant([probIndices(idx) nextIndex]);
end

function pheromone = pheromone_update(r, s, pheromone, evaporation_rate, ants, costs, PS)
    sum = 0;
%     edge = [r s];
    for k = 1:PS
         % \delta\tau_{rs}^{k}
%         for i = 1:51
%             if ants(k,i) == r && ants(k,i+1) == s
%                 sum = sum + (1 / costs(k));
%                 break;
%             end
%         end
%         if strfind(ants(k,:), edge) % Checks if edge is subvector of path.
%             sum = sum + (1 / costs(k));
%         end
        if find(ants(k,:) == r) + 1 == find(ants(k,:) == s)
            sum = sum + (1 / costs(k));
        end
    end
        
    pheromone = (1 - evaporation_rate) * pheromone + sum;
end









function res = astarHeuristic(item, adjmat, distmap)
%ASTARHEURISTIC Summary of this function goes here
% item is the array from the prio queue, [id heuristic dist-from-start]
% adjmat is the adjacency matrix
% distmap is the map of city id's to absolute distance
% returns a matrix of all [id dist-from-start heuristic]
    
    id = item(1);
    neighbours = zeros(length(adjmat), 2); % preallocate memory.
    count = 0;
    for i = 1:length(adjmat)
        if adjmat(id,i) > 0
            count = count + 1;
            neighbours(count,1:2) = [i adjmat(id,i)];
        end
    end
            
    neighbours = neighbours(1:count, 1:2); % Removes unused spots
    % Now a matrix of [id dist-from-input]
    
    distFromStart = item(2);
    for i = 1:count
        neighbours(i,2) = distFromStart + neighbours(i,2);
        neighbours(i,3) = neighbours(i,2) + distmap(neighbours(i,1));
    end
    
    res = neighbours;
end


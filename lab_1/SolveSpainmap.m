
[gbfsDist, gbfsPath]  = Solve('gbfs')
[astarDist, astarPath] = Solve('astar')

% Only difference between A* and Greedy BFS is that A* also includes the
% distance traveled in the heuristic. Otherwise the code is exactly the
% same.

% A*
% Time complexity: O(b^d)
% Space complexity: O(b^d)
% where `b` is the branching factor and `d` is the depth of the shortest
% path.

% Greedy BFS
% Time complexity: O(b^m)
% Space complexity: O(b^m)
% where `b` is the branching factor and `m` is the maximum depth of the
% search space.

function [distance, path] = Solve(algo)
%     mapfile = "Romania_map.txt";
%     sdlfile = "Romania_straight_lines.txt";
%     StartCity = "Arad";
%     EndCity = "Bucharest"; 
    mapfile = "spain_map.txt";
    sdlfile = "spain_map_straight_lines.txt";
    StartCity = "Malaga";
    EndCity = "Valladolid";
    
    import containers.Map;
    fid = fopen(mapfile, "r");
    data = textscan(fid, "%s %s %d");
    fclose(fid);
    
    fid2 = fopen(sdlfile, "r");
    sld = textscan(fid2, "%s %d"); % SLD = Straight Line Distance
    fclose(fid2);

    citymap = containers.Map(); % Name -> City object
    
    % Create cities
    for i = 1:length(sld{1})
        city = City(sld{1}{i}, sld{2}(i));
        citymap(city.Name) = city;
    end
    
    % Connect roads
    for i = 1:length(data{1})
        from = data{1}{i};
        to   = data{2}{i};
        dist = data{3}(i);
        fromC = citymap(from);
        toC = citymap(to);
        fromC.addNeighbour(toC, dist);
        toC.addNeighbour(fromC, dist);
    end
    
    % Run algorithm
    start = citymap(StartCity);    
    q = PriorityQueue(1); % Sorts based on the first index
    %      [heuristic dist-traveled city city-path]
    curr = [start.SLD 0 {start} {[StartCity]}]; 
    q.insert(curr);
    
    while q.size() > 0
        curr = q.remove();
        city = curr{3};
        if city.Name == EndCity
            distance = curr{2};
            path = curr{4};
            return;
        end
        
        for i = 1:city.NeighbourCount
            ncity = city.Neighbours(i).City;
            visited = curr{4}; % visited keeps track of the path traveled.
            visited(length(visited) + 1) = ncity.Name; 
            traveled = curr{2} + city.Neighbours(i).Length;
            
            % Choose heuristic function depending on algorithm
            if strcmp(algo, 'gbfs')
                heuristic = ncity.SLD;
            elseif strcmp(algo, 'astar')
                heuristic = traveled + ncity.SLD;
            end
            
            item = [heuristic traveled {ncity} {visited}];
            q.insert(item);
        end     
    end
end
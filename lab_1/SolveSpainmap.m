
gbfs  = Solve('gbfs')
Astar = Solve('astar')


function res = Solve(algo)
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
    

    start = citymap(StartCity);    
    % Run algorithm
    if strcmp(algo, 'astar')
        res = astar(start, StartCity, EndCity);
    elseif strcmp(algo, 'gbfs')
        res = greedybfs(start, StartCity, EndCity);
    end
end

% Time complexity: O(b^d)
% Space complexity: O(b^d)
% where `b` is the branching factor and `d` is the depth of the shortest
% path.
function res = astar(start, StartCity, EndCity)
    q = PriorityQueue(1); % Sorts based on the first index
    %      [heuristic dist-traveled city city-path]
    curr = [start.SLD 0 {start} {[StartCity]}]; 
    q.insert(curr);
    
    while q.size() > 0
        curr = q.remove();
        city = curr{3};
        traveled = curr{2};
%         disp(city.Name);
        if city.Name == EndCity
            res = curr;
            return;
        end
        
        for i = 1:city.NeighbourCount
            
            dist = city.Neighbours(i).Length;
            ncity = city.Neighbours(i).City;
            travelednext = traveled + dist; % g(n);
            heuristic = travelednext + ncity.SLD; % f(n) = g(n) + h(n)
            visited = curr{4}; % visited keeps track of the path traveled.
            visited(length(visited) + 1) = ncity.Name; 
            item = [heuristic travelednext {ncity} {visited}];
            q.insert(item);
        end     
    end
end

% Only difference between A* and Greedy BFS is that A* also includes the
% distance traveled in the heuristic. Otherwise the code is exactly the
% same.

% Time complexity: O(b^m)
% Space complexity: O(b^m)
% where `b` is the branching factor and `m` is the maximum depth of the
% search space.
function res = greedybfs(start, StartCity, EndCity)
    q = PriorityQueue(1); % Sorts based on the first index
    %      [heuristic dist-traveled city city-path]
    curr = [start.SLD 0 {start} {[StartCity]}];
%     disp(curr);
    q.insert(curr);
    
    while q.size() > 0
        curr = q.remove();
        city = curr{3};
        traveled = curr{2};
%         disp(city.Name);
        if city.Name == EndCity
            res = curr;
            return;
        end
        
        for i = 1:city.NeighbourCount
            
            dist = city.Neighbours(i).Length;
            ncity = city.Neighbours(i).City;
            travelednext = traveled + dist; 
            visited = curr{4}; % visited keeps track of the path traveled.
            visited(length(visited) + 1) = ncity.Name; 
            item = [ncity.SLD travelednext {ncity} {visited}];
            q.insert(item);
        end
    end
end
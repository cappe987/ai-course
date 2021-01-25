function res = Test(algorithm)
    import containers.Map;
    
    fid = fopen("spain_map.txt", "r");
    data = textscan(fid, "%s %s %d");
    fclose(fid);
    
    fid2 = fopen("spain_map_straight_lines.txt", "r");
    absdist = textscan(fid2, "%s %d");
    fclose(fid2);
    
    % Map id to absolute dist. Used in heuristic function
    % Id is determined by the order in the absolute distance list
%     distmap = containers.Map(1:length(absdist{1}), absdist{2}); 
    
    % distmap = containers.Map(cities, absdist{2}); % Hashmap for faster lookup
    
    % Create adjacency matrix    
    len = length(absdist{1});
    adjmat = zeros(len, len);
    cities = absdist{1}; % Just city names
    for i = 1:length(data{1})
        from = string(data{1}{i});
        to   = string(data{2}{i});
        dist =        data{3}(i);
        fromIndex = find(cities == from);
        toIndex   = find(cities == to  );
        adjmat(fromIndex, toIndex) = dist;
        adjmat(toIndex, fromIndex) = dist;
    end

    
%     q = PriorityQueue(2); % Use [id heuristic (dist for A*)]
    
%     distmap = containers.Map(1:length(cities), absdist{2}); % Map id to dist.

    % Use `graph()` or `digraph` to build the tree.
    % sortrows(A,2) % to choose traversal order.
    
    res = cities;
end


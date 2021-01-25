function res = Test(algorithm)
    import containers.Map;
    
    fid = fopen("spain_map.txt", "r");
    data = textscan(fid, "%s %s %d");
    fclose(fid);
    
    fid2 = fopen("spain_map_straight_lines.txt", "r");
    absdist = textscan(fid2, "%s %d");
    fclose(fid2);
    
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
    
    res = adjmat;
end


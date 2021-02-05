classdef Node
    properties
        ID
        X
        Y
    end
    
    methods
        function obj = Node(id, x, y)
            obj.ID = id;
            obj.X = x;
            obj.Y = y;
        end
    end
end


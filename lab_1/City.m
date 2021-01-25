classdef City < handle
    properties
        Name
        Neighbours
        NeighbourCount
        SLD
    end
    
    methods
        function obj = City(Name, SLD)
            obj.Name = Name;
            obj.Neighbours = [];
            obj.NeighbourCount = 0;
            obj.SLD = SLD;
        end
        
        function addNeighbour(obj, City, Length)
            obj.NeighbourCount = obj.NeighbourCount + 1;
            obj.Neighbours(obj.NeighbourCount).City = City;
            obj.Neighbours(obj.NeighbourCount).Length = Length;

        end
    end
end


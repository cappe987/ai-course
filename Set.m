classdef Set < handle
    %SET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data
        Size
    end
    
    methods
        function obj = Set()
            %SET Construct an instance of this class
            %   Detailed explanation goes here
            obj.Size = 0;
        end
        
        function insert(obj,item)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if obj.contains(item)
                return;
            end
            obj.Size = obj.Size + 1;
            obj.Data(obj.Size) = item;
        end
        
        function delete(obj, item)
            idx = 0;
            for i = 1:obj.Size
                if obj.Data(i) == item
                    idx = i;
                end
            end
            if idx == 0
                return;
            end
            for i = idx:(obj.Size-1)
                obj.Data(i) = obj.Data(i+1);
            end
            obj.Size = obj.Size - 1;
        end
            
            
        
        function res = contains(obj, item)
            for i = 1:obj.Size
                if obj.Data(i) == item
                    res = 1;
                    return;
                end
            end
            res = 0;
            return;
        end
    end
end


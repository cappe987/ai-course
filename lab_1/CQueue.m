
classdef CQueue < handle
% CQueue define a queue data strcuture
% 
% It likes java.util.Queue, however, it could use CQueue.content() to
% return all the data (in cells) of the Queue, and it is a litter faster
% than java's Queue.
% 
%   q = CQueue(c); c is a cells, and could be omitted
%   s.size() return the numble of element
%   s.isempty() return true when the queue is empty
%   s.empty() delete all the elements in the queue.
%   s.push(el) push el to the top of qeueu
%   s.pop() pop out the the beginning of queue, and return the element
%   s.front() return the the the beginning element of the qeueu
%   s.back() return the the the rear element of the qeueu
%   s.remove() remove all data from the queue
%   s.content() return all the data of the queue (in the form of a
%   cells with size [s.size(), 1]
%   
% See also CList, CStack
%
% ¶¨ÒåÁËÒ»¸ö¶ÓÁÐ
% q = CQueue; ¶¨ÒåÒ»¸ö¿ÕµÄ¶ÓÁÐ¶ÔÏó
% q = CQueue(c); ¶¨Òå¶ÓÁÐ¶ÔÏó£¬²¢ÓÃc³õÊ¼»¯q£¬µ±cÎªcellÊ±£¬cµÄÔªËØÎªÕ»µÄÊý¾Ý£¬
%    ·ñÔòc±¾ÉíÎªÕ»µÄµÚÒ»¸öÊý¾Ý
%
% Ö§³Ö²Ù×÷£º
%     sz = q.size() ·µ»Ø¶ÓÁÐÄÚÔªËØ¸öÊý£¬Ò²¿ÉÓÃÀ´ÅÐ¶Ï¶ÓÁÐÊÇ·ñ·Ç¿Õ¡£
%     q.isempty() ÓÃÀ´ÅÐ¶Ï¶ÓÁÐÎª¿Õ
%     q.empty() Çå¿Õ¶ÓÁÐ
%     q.push(el) ½«ÐÂÔªËØelÑ¹Èë¶ÓÁÐÄÚ
%     s.pop()  µ¯³ö¶ÓÊ×ÔªËØ£¬ÓÃ»§Ðè×Ô¼ºÈ·±£¶ÓÁÐ·Ç¿Õ
%     el = q.front() ·µ»Ø¶ÓÊ×ÔªËØ£¬ÓÃ»§Ðè×Ô¼ºÈ·±£¶ÓÁÐ·Ç¿Õ
%     el = q.back() ·µ»Ø¶ÓÎ²ÔªËØ£¬ÓÃ»§Ðè×Ô¼ºÈ·±£¶ÓÁÐ·Ç¿Õ
%     q.remove() Çå¿Õ¶ÓÁÐ
%     q.content() °´Ë³Ðò·µ»ØqµÄÊý¾Ý£¬ÎªÒ»¸öcellÊý×é
%     
% See also CStack, CList
%
% Copyright: zhang@zhiqiang.org, 2010.
% url: http://zhiqiang.org/blog/it/matlab-data-structures.html
    properties (Access = private)
        buffer      % a cell, to maintain the data
        beg         % the start position of the queue
        rear        % the end position of the queue
                    % the actually data is buffer(beg:rear-1)
    end
    
    properties (Access = public)
        capacity    % Õ»µÄÈÝÁ¿£¬µ±ÈÝÁ¿²»¹»Ê±£¬ÈÝÁ¿À©³äÎª2±¶¡£
    end
    
    methods
        function obj = CQueue(c) % ³õÊ¼»¯
            if nargin >= 1 && iscell(c)
                obj.buffer = [c(:); cell(numel(c), 1)];
                obj.beg = 1;
                obj.rear = numel(c) + 1;
                obj.capacity = 2*numel(c);
            elseif nargin >= 1
                obj.buffer = cell(100, 1);
                obj.buffer{1} = c;
                obj.beg = 1;
                obj.rear = 2;
                obj.capacity = 100;                
            else
                obj.buffer = cell(100, 1);
                obj.capacity = 100;
                obj.beg = 1;
                obj.rear = 1;
            end
        end
        
        function s = size(obj) % ¶ÓÁÐ³¤¶È
            if obj.rear >= obj.beg
                s = obj.rear - obj.beg;
            else
                s = obj.rear - obj.beg + obj.capacity;
            end
        end
        
        function b = isempty(obj)   % return true when the queue is empty
            b = ~logical(obj.size());
        end
        
        function s = empty(obj) % clear all the data in the queue
            s = obj.size();
            obj.beg = 1;
            obj.rear = 1;
        end
        
        function push(obj, el) % Ñ¹ÈëÐÂÔªËØµ½¶ÓÎ²
            if obj.size >= obj.capacity - 1
                sz = obj.size();
                if obj.rear >= obj.front
                    obj.buffer(1:sz) = obj.buffer(obj.beg:obj.rear-1);                    
                else
                    obj.buffer(1:sz) = obj.buffer([obj.beg:obj.capacity 1:obj.rear-1]);
                end
                obj.buffer(sz+1:obj.capacity*2) = cell(obj.capacity*2-sz, 1);
                obj.capacity = numel(obj.buffer);
                obj.beg = 1;
                obj.rear = sz+1;
            end
            obj.buffer{obj.rear} = el;
            obj.rear = mod(obj.rear, obj.capacity) + 1;
        end
        
        function el = front(obj) % ·µ»Ø¶ÓÊ×ÔªËØ
            if obj.rear ~= obj.beg
                el = obj.buffer{obj.beg};
            else
                el = [];
                warning('CQueue:NO_DATA', 'try to get data from an empty queue');
            end
        end
        
        function el = back(obj) % ·µ»Ø¶ÓÎ²ÔªËØ            
            
           if obj.rear == obj.beg
               el = [];
               warning('CQueue:NO_DATA', 'try to get data from an empty queue');
           else
               if obj.rear == 1
                   el = obj.buffer{obj.capacity};
               else
                   el = obj.buffer{obj.rear - 1};
               end
            end
            
        end
        
        function el = pop(obj) % µ¯³ö¶ÓÊ×ÔªËØ
            if obj.rear == obj.beg
                error('CQueue:NO_Data', 'Trying to pop an empty queue');
            else
                el = obj.buffer{obj.beg};
                obj.beg = obj.beg + 1;
                if obj.beg > obj.capacity, obj.beg = 1; end
            end             
        end
        
        function remove(obj) % Çå¿Õ¶ÓÁÐ
            obj.beg = 1;
            obj.rear = 1;
        end
        
        function display(obj) % ÏÔÊ¾¶ÓÁÐ
            if obj.size()
                if obj.beg <= obj.rear 
                    for i = obj.beg : obj.rear-1
                        disp([num2str(i - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end
                else
                    for i = obj.beg : obj.capacity
                        disp([num2str(i - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end     
                    for i = 1 : obj.rear-1
                        disp([num2str(i + obj.capacity - obj.beg + 1) '-th element of the stack:']);
                        disp(obj.buffer{i});
                    end
                end
            else
                disp('The queue is empty');
            end
        end
        
        function c = content(obj) % È¡³ö¶ÓÁÐÔªËØ
            if obj.rear >= obj.beg
                c = obj.buffer(obj.beg:obj.rear-1);                    
            else
                c = obj.buffer([obj.beg:obj.capacity 1:obj.rear-1]);
            end
        end
    end
end

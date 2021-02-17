clear all;

fprintf('     This is the CLIENT\n\n');
playerName = "Matlab Player";
t = tcpip('localhost', 30000, 'NetworkRole', 'client');
%t = tcpip('192.168.1.187', 30000, 'NetworkRole', 'client');

fopen(t);

gameEnd = 0;
maxTimeResponse = 5;
while ~gameEnd
    start = tic;
    currentTime = 0;
    while t.BytesAvailable == 0 && currentTime < maxTimeResponse
    currentTime = toc(start);

        
    end
    if t.BytesAvailable > 0
        data = fread(t, t.BytesAvailable);
    else
        fprintf("No response in %d sec\n",maxTimeResponse);
        gameEnd = 1;
        data = [];
    end

    if data == 78
        fwrite(t, playerName)
    end
    if data == 69
        gameEnd = 1;
    end
    if length(data) > 1
        % Read the board and player turn
        data = data-48;
        playerTurn = data(1);
        board = zeros(14,0);
        i = 1;
        j = 2;
        while i <= 14
            board(i) = data(j) * 10 + data(j+1);
            i = i + 1;
            j = j+2;
        end
        % Using your intelligent bot, assign a move to "move".
        % 
        % example: move = '1'; Possible moves from '1' to '6' if the game's 
        % rules allows those moves.
        
        % TODO: Change this %%%%%%%%%%
        
        alpha = -Inf;
        beta = Inf;
        depth = 3;
        if playerTurn == 1
            [~, a] = maxValue(board, alpha, beta, depth);
        elseif playerTurn == 2
            [~, a] = minValue(board, alpha, beta, depth);
            a = a - 7; % To get it in range 1-6
        end
        
        move = num2str(a);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fwrite(t, move)
       
    end
end


function [val, move] = maxValue(state, alpha, beta, depth)
    if depth < 0 || all(state(1:6) == 0) % Side is empty
        val = evalState(state);
        move = NaN;
        return;
    end
    val = -Inf;
    move = NaN;
    for a = 1:6
        if state(a) == 0
            continue
        end
        [newstate, goAgain] = doMove(state, a);
        if goAgain
            [newval, ~] = maxValue(newstate, alpha, beta, depth-1);
        else
            [newval, ~] = minValue(newstate, alpha, beta, depth-1);
        end
        if newval > val
            val = newval;
            move = a;
        end
        if val >= beta
            return;
        end
        
        alpha = max(alpha, val);
    end
end

function [val, move] = minValue(state, alpha, beta, depth)
    if depth < 0 || all(state(8:13) == 0) % Side is empty
        val = evalState(state);
        move = NaN;
        return;
    end
    val = Inf;
    move = NaN;
    for a = 8:13
        if state(a) == 0
            continue
        end
        [newstate, goAgain] = doMove(state, a);
        if goAgain
            [newval, ~] = minValue(newstate, alpha, beta, depth-1);
        else
            [newval, ~] = maxValue(newstate, alpha, beta, depth-1);
        end
        if newval < val
            val = newval;
            move = a;
        end
        if val <= alpha
            return;
        end
        
        beta = min(beta, val);
    end
end

function [state, goAgain] = doMove(state, a)
    rocks = state(a);
    state(a) = 0;
    goAgain = false;
    if a < 7
        player = 1;
    else
        player = 2;
    end
    
    i = 0;
    idx = a;
    % Move the rocks
    while i < rocks
        idx = mod(idx + 1, 15);
        if idx == 0
            idx = 1;
        end
        if (idx == 7 && player == 2) || (idx == 14 && player == 1) 
            continue;
        end
        state(idx) = state(idx) + 1;
        i = i + 1;

    end
    
    % Go again
    if (player == 1 && idx == 7) || (player == 2 && idx == 14)
        goAgain = true;
    end
    
    % Take stones from opponent
    if player == 1 && idx < 7 && state(idx) == 1
        taken = state(14 - idx);
        state(14 - idx) = 0;
        state(7) = state(7) + taken;
    elseif player == 2 && idx > 7 && idx < 14 && state(idx) == 1
        taken = state(14 - idx);
        state(14 - idx) = 0;
        state(14) = state(14) + taken;
    end
    
    if all(state(1:6) == 0) % One side is empty
        state(14) = state(14) + sum(state(8:13));
        state(8:13) = zeros(1,6);
    elseif all(state(8:13) == 0) % Other side is empty
        state(7) = state(7) + sum(state(1:6));
        state(1:6) = zeros(1,6);
    end
end

function val = evalState(state)
    val = 0;
    % Counts the rocks in the stores and how many moves we can do.
    % Some paper said this was a good idea.
    val = val + (state(7) - state(14)); % Stores
    val = val + (sum(state(1:6) ~= 0) - sum(state(8:13) ~= 0));
end




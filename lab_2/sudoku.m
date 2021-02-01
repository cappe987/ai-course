tic
Run()
toc

function [resmat, valid] = Solve(matrix, i, j)
    if i > 9
        i = 1;
        j = j + 1;
    end
    if j > 9 % If j goes out of bounds we have filled all squares
        resmat = matrix;
        valid = true;
        return;
    end
    
    % Already has a number
    if matrix(i,j) ~= 0
        [resmat, valid] = Solve(matrix, i + 1, j);
        return;
    end
    
    % Try numbers
    valid = false;
    for x = 1:9
        matrix(i,j) = x;
        if isValid(matrix, i,j)
            [resmat, valid] = Solve(matrix, i + 1, j);
        end
        if valid == true
            return; % Solution found
        end
    end
    resmat = matrix;
end

function valid = isValid(matrix, i, j)
    x = matrix(i,j);
    for row = 1:9
        if matrix(row,j) == x && row ~= i
            valid = false;
            return;
        end 
    end
    
    for col = 1:9
        if matrix(i,col) == x && col ~= j
            valid = false;
            return;
        end
    end
    
    % Upper left corner of the current square.
    sI = floor((i-1)/3)*3 + 1; 
    sJ = floor((j-1)/3)*3 + 1;
    
    % Check square
    for si = sI:sI+2
        for sj = sJ:sJ+2
            if matrix(si,sj) == x && si ~= i && sj ~= j
                valid = false;
                return;
            end
        end
    end
    valid = true;
end

function Sudokus = Run()
    % Read file and put in right format
    fid = fopen('sudokus.txt', 'r');   
    Sudokus = cell(1,10);
    for i = 1:10
        sudoku = cell(9,1);
        for j = 1:9
            sudoku{j} = fgetl(fid);
        end
        fgetl(fid); % Read blank line
        sudoku2 = zeros(9,9);
        for x = 1:9
            for y = 1:9
                sudoku2(x,y) = str2double(sudoku{x}(y));
            end
        end
        Sudokus(i) = {sudoku2};
    end
    % Sudokus is now an array of matrices (for the 10 sudokus)
    
    % Solve the sudokus
    for i = 1:10
        [Sudokus{i}, ~] = Solve(Sudokus{i}, 1, 1);
    end
end







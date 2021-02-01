tic
Run()
toc

function [resmat, fail] = Solve(matrix, i, j)
    if i > 9
        i = 1;
        j = j + 1;
    end
    if j > 9 % If j goes out of bounds we have solved it.
        resmat = matrix;
        fail = false;
        return;
    end
    
    % Already has a number
    if matrix(i,j) ~= 0
        [resmat, fail] = Solve(matrix, i + 1, j);
        return;
    end
    
    % Try numbers
    resmat = matrix;

    fail = true;
    for x = 1:9
        matrix(i,j) = x;
        if isValid(matrix, i,j)
            [resmat, fail] = Solve(matrix, i + 1, j);
        end
        if fail == false
            return;
        end
    end
end

function res = isValid(matrix, i, j)
    x = matrix(i,j);
    for row = 1:9
        if row ~= i && matrix(row,j) == x
            res = false;
            return;
        end 
    end
    
    for col = 1:9
        if col ~= j && matrix(i,col) == x
            res = false;
            return;
        end
    end
    
    sI = floor((i-1)/3)*3 + 1;
    sJ = floor((j-1)/3)*3 + 1;
    
    for si = sI:sI+2
        for sj = sJ:sJ+2
            if si ~= i && sj ~= j && matrix(si,sj) == x
                res = false;
                return;
            end
        end
    end
    res = true;
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
        fgetl(fid);
        sudoku2 = zeros(9,9);
        for x = 1:9
            for y = 1:9
                sudoku2(x,y) = str2double(sudoku{x}(y));
            end
        end
        Sudokus(i) = {sudoku2};
    end
    % Sudokus is now an array of matrices (for the 10 sudokus)
%     res = Sudokus;
    for i = 1:10
        [Sudokus{i}, ~] = Solve(Sudokus{i}, 1, 1);
    end
end







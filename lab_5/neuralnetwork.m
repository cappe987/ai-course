% clear all



% input - hidden layers - output
layers = [784 200 50 10]; 
n = 2000;
rng(1);
eta = 0.1; % Learning rate


weightCount = length(layers)-1;

% matrix = loadMatrix();

tic

inputs = transpose(matrix(1:n, 2:end));
targets = matrix(1:n,1);


[W,B, tAccs, vAccs] = doTraining(layers, weightCount, eta, inputs, targets, n);

% L = runNetwork(layers, W, B, weightCount, inputs(:,14)); % 41: 9
% disp(outputToNum(L{end}));
% disp(topThree(L{end}));

toc

function matrix = loadMatrix()
    disp("Reading CSV");
    matrix = readmatrix('assignment5.csv');
    disp("CSV Loaded");
end

function [W,B, trainingAccs, validationAccs] = doTraining(layers, weightCount, eta, inputs, targets, n)
    disp("Training...");
    [W,B] = initWB(layers, weightCount);
    tenth = floor(n/10);
    validationRange = (tenth*7):(tenth*8 - 1);
    testStart = tenth*8;
    i = 1;
    j = 1;
    while j > 0
        [W, trainAcc] = train(layers, weightCount, eta, W, B, inputs, targets, n);
        acc = validate(layers, W, B, weightCount, inputs, targets, validationRange);
        [testAcc, perClass] = test(layers, W, B, weightCount, inputs, targets, testStart:n);
        fprintf("---- Epoch %d ----\n", i);
        fprintf("Training: %.1f%% | Validation: %.1f%% | Test: %.1f%% {", trainAcc, acc, testAcc);
        for k = 1:9
            fprintf("(%d: %.1f%%), ", k-1, perClass(k));
        end
        fprintf("(%d: %.1f%%)}\n", 9, perClass(9));
        trainingAccs(i) = trainAcc;
        validationAccs(i) = acc;
        i = i + 1;
%         fprintf("", testAcc);
        if testAcc > 80
            j = j - 1;
        end
    end
    disp("Training done");
end

function [W, acc] = train(layers, weightCount, eta, W, B, inputs, targets, n)
    tenth = floor(n/10);
    trainEnd = tenth*7 - 1;
    results = zeros(1,trainEnd);

    for curr = 1:trainEnd
        input = inputs(:, curr);
        target = createTargetOutput(targets(curr));
        
        % Run neural network
        L = runNetwork(layers, W, B, weightCount, input);
        results(curr) = outputToNum(L{end}) == targets(curr);
%         disp(L{end});

        % Backpropagation
        delta = zeros(layers(end), 1);
        for i = 1:layers(end)
            delta(i) = (target(i) - L{end}(i)) * 1; % Errors of output layer
        end

        weightDeltas = cell(1, weightCount);
        for z = 1:weightCount
            weightDeltas{z} = zeros(layers(z+1), layers(z));
        end

        for lay = flip(1:weightCount)
            % Find Weight deltas
            for i = 1:layers(lay) 
                for j = 1:layers(lay+1)
                    weightDeltas{lay}(j,i) = eta * delta(j) * L{lay}(i);
                end
            end
            % Calculate all delta J for layer i
            newDeltas = zeros(1,layers(lay));
            for j = 1:layers(lay)
                derivOutput = derivsigmoid(L{lay}(j));
                total = 0;
                for k = 1:layers(lay+1)
                    total = total + delta(k) * W{lay}(k,j);
                end
                newDeltas(j) = derivOutput * total;
            end
            delta = newDeltas;
        end


        % Apply weight deltas
        for i = 1:weightCount
            W{i} = W{i} + weightDeltas{i};
        end
        
%         % Run validation
%         if mod(curr, 100) == 0
%             acc = validate(layers, W, B, weightCount, inputs, targets, validationRange);
%             fprintf("Validation after %d images: %.1f%%\n", curr, acc);
%         end
    end
    
    acc = (sum(results)/length(results))*100;
end


function L = runNetwork(layers, W, B, weightCount, input)
    L = cell(1, length(layers)); % L{1} is input. L{end} is output
    L{1} = arrayfun(@(x) sigmoid(x), input);%Input. Do we use sigmoid on input?
    for i = 1:weightCount-1
        A = W{i}*L{i} + B{i}; % Linear regression with multiple variables
        L{i+1} = arrayfun(@(x) sigmoid(x), A); 
    end

    L{end} = softmax(W{weightCount}*L{weightCount} + 1);
end

function accuracy = validate(layers, W, B, weightCount, inputs, targets, idxRange)
%     len = length(idxRange);
    results = zeros(1, length(idxRange));
    diff = idxRange(1)-1;
    for curr = idxRange
        input = inputs(:, curr);
        target = targets(curr);

        % Run neural network
        L = runNetwork(layers, W, B, weightCount, input);
        res = outputToNum(L{end});
        if res == target
            results(curr-diff) = 1;
        else
            results(curr-diff) = 0;
        end
    end
    accuracy = (sum(results)/length(results)) * 100;
end

function [accuracy, perClass] = test(layers, W, B, weightCount, inputs, targets, idxRange)
    results = zeros(1, length(idxRange));
    diff = idxRange(1)-1;
    correct = zeros(1,10);
    total   = zeros(1,10);
    for curr = idxRange
        input = inputs(:, curr);
        target = targets(curr);

        % Run neural network
        L = runNetwork(layers, W, B, weightCount, input);
        res = outputToNum(L{end});
        total(target+1) = total(target+1) + 1;
        if res == target
            correct(target+1) = correct(target+1) + 1;
            results(curr-diff) = 1;
        else
            results(curr-diff) = 0;
        end
    end
    perClass = zeros(1,10);
    for i = 1:10
        perClass(i) = (correct(i)/total(i))*100;
    end
    accuracy = (sum(results)/length(results)) * 100;
end

function [W,B] = initWB(layers, weightCount)
    W = cell(1, weightCount);
    B = cell(1, weightCount); % Bias term

    for i = 1:weightCount
        % Make them be floats from -1 to 1.
    %     W{i} = randi([0 10], [layers(i+1) layers(i)]);
        W{i} = rand([layers(i+1) layers(i)]) * 2 - 1;
    end

    for i = 1:weightCount
        B{i} = ones(layers(i+1),1); % Initialize bias to 1
    end
end

function res = outputToNum(probs)
    [~, idx] = max(probs);
    res = idx-1;
end

function str = topThree(probs)
    [~, ixs] = sort(probs, 'descend');
    str = sprintf("%d: %d%%\n", ixs(1)-1, round(probs(ixs(1))*100));
    str = strcat(str, sprintf("%d: %d%%\n", ixs(2)-1, round(probs(ixs(2))*100)));
    str = strcat(str, sprintf("%d: %d%%\n", ixs(3)-1, round(probs(ixs(3))*100)));
end

function target = createTargetOutput(num)
    target = zeros(10,1);
    target(num+1) = 1;
end

function val = sigmoid(x)
    val = 1/(1+exp(-x));
end

function val = derivsigmoid(x)
    val = (1/(1+exp(-x)))*(1 - 1/(1+exp(-x)));
end

function val = relu(x) 
    if x <= 0 
        val = 0;
    else
        val = x;
    end
end

function val = derivrelu(x)
    if x <= 0
        val = 0;
    else
        val = 1;
    end
end

function val = derivtanh(x)
    val = 1 - tanh(x)^2;
end










% clear all



rng(1);

layers = [784 200 100 10]; % input - hidden layers - output
eta = 0.2; % Learning rate
% inputs = [1 3 1; 2 3 2];
% targets = [1 2 1];
L = cell(1, length(layers)); % L{1} is input. L{end} is output

weightCount = length(layers)-1;


tic

% matrix = readmatrix('assignment5.csv');
n = 5000;
inputs = transpose(matrix(1:n, 2:end));
targets = matrix(1:n,1);


[W,B] = initWB(layers, weightCount);
W = train(layers, weightCount, eta, L, W, B, inputs, targets);

L = runNetwork(L,W,B, weightCount, inputs(:,14)); % 41: 9
% disp(outputToNum(L{end}));
disp(topThree(L{end}));

toc


function W = train(layers, weightCount, eta, L, W, B, inputs, targets)
    for curr = 1:length(inputs(1,:))
        input = inputs(:, curr);
        target = createTargetOutput(targets(curr));
        
        % Run neural network
        L = runNetwork(L, W, B, weightCount, input);
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
            for i = 1:layers(lay) % Parfor?
                for j = 1:layers(lay+1)
                    weightDeltas{lay}(j,i) = eta * delta(j) * L{lay}(i);
                end
            end
            % Calculate all delta J for layer i
            newDeltas = zeros(1,layers(lay));
            for j = 1:layers(lay) % Parfor?
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
        for i = 1:weightCount % Parfor?
            W{i} = W{i} + weightDeltas{i};
        end
    end
end


function L = runNetwork(L, W, B, weightCount, input)
    L{1} = arrayfun(@(x) sigmoid(x), input);%Input. Do we use sigmoid on input?
    % L{2} = W{1}*L{1} + 1;
    for i = 1:weightCount-1
    %     A = arrayfun(@(x) sigmoid(x), L{i});
    %     L{i+1} = W{i}*A + B{i};
        A = W{i}*L{i} + B{i}; % Linear regression with multiple variables
        L{i+1} = arrayfun(@(x) sigmoid(x), A); 
    end

    L{end} = softmax(W{weightCount}*L{weightCount} + 1);

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













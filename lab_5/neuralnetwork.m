clear all

rng(1);

layers = [2 3 4 3]; % input - hidden layers - output
eta = 0.2; % Learning rate
input = [1;2];
target = [0;1;0];

weightCount = length(layers)-1;
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

L = cell(1, length(layers)); % L{1} is input. L{end} is output


for x = 1:5
    % Go through network
    L{1} = arrayfun(@(x) sigmoid(x), input);%Input. Do we use sigmoid on input?
    % L{2} = W{1}*L{1} + 1;
    for i = 1:weightCount-1
    %     A = arrayfun(@(x) sigmoid(x), L{i});
    %     L{i+1} = W{i}*A + B{i};
        A = W{i}*L{i} + B{i}; % Linear regression with multiple variables

        L{i+1} = arrayfun(@(x) sigmoid(x), A); 
    end

    L{end} = softmax(W{weightCount}*L{weightCount} + 1);

    % disp("EXITING EARLY THROUGH RETURN");
    % return;

    % Backpropagation
    delta = zeros(layers(end), 1);
    for i = 1:layers(end)
        delta(i) = (target(i) - L{end}(i)) * 1; % Errors of output layer
    end
    disp(L{end});

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
end


function val = sigmoid(x)
    val = 1/(1+exp(-x));
end

function val = derivsigmoid(x)
    val = (1/(1+exp(-x)))*(1 - 1/(1+exp(-x)));
end













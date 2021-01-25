function bin = binArr2decStr(arr)
%BINARR2DEC Reverses the arr and transforms to int string.
%   Detailed explanation goes here
    x = num2str(arr);
    x(isspace(x)) = '';
    x = reverse(x);
    bin = int2str(bin2dec(x));
end


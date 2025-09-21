function y = findInverse(x)
% y=x;
    symbolicVar = symvar(x);
    if length(symbolicVar) > 1; error('Only 1 symbolic variable allowed');end;
    expression = strrep(x, symbolicVar{:}, 'x');
    syms x
    f(x) = eval(expression);
    g = finverse(f);
    y = strrep(char(g), 'x', symbolicVar{:});

end
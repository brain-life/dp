function [A b xt x0] = gennnls(m, n, sp1, sp2)

% fix random seed for repeatability of experiments; later move it to some
% higher level experimentation script !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Fix the random seed
    if (~exist('sp2', 'var'))
        sp2=0.5;
    end
    s = RandStream.create('mt19937ar','seed', 112781);
    RandStream.setDefaultStream(s);

    A = randn(m, n);
    xt = sprand(n, 1, sp2);
    xt = full(xt);
    b1 = A * xt;
    idx = find(xt == 0);
    y = zeros(size(xt));
    y(idx) = .01 * rand(length(idx), 1);

    b = A' \ (A' * b1 - y);
    x0 = zeros(size(xt));
end
function g = g_heuristic_sca1asy1(~, ~, u, ~)

% Heuristic belief updating with scaling and asymmetry fixed to one.

eBR = u(1);
E1 = u(2);
BR = u(3);

scaling = 1;
asymmetry = 1;

EE = BR - eBR;
LR = scaling + sign(eBR - BR) * asymmetry;

g = E1 + LR * EE;


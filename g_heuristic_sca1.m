function g = g_heuristic_sca1(~, P, u, ~)

% Heuristic belief updating with scaling fixed to one.

eBR = u(1);
E1 = u(2);
BR = u(3);

scaling = 1;
asymmetry = P(2);

EE = BR - eBR;
LR = scaling + sign(eBR - BR) * asymmetry;

g = E1 + LR * EE;


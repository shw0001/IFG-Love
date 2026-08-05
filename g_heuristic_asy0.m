function g = g_heuristic_asy0(~, P, u, ~)

% Heuristic belief updating with asymmetry fixed to zero.

eBR = u(1);
E1 = u(2);
BR = u(3);

scaling = P(1);
asymmetry = 0;

EE = BR - eBR;
LR = scaling + sign(eBR - BR) * asymmetry;

g = E1 + LR * EE;


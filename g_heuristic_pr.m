function g = g_heuristic_pr(~, P, u, ~)

% Heuristic belief updating with personal relevance weight.

eBR = u(1);
E1 = u(2);
BR = u(3);

scaling = P(1);
asymmetry = P(2);

EE = BR - eBR;
rP = personal_relevance(eBR, E1);
LR = scaling + sign(eBR - BR) * asymmetry;

g = E1 + LR * EE * (1 - rP);

end

function rP = personal_relevance(eBR, E1)

if E1 < eBR
    rP = (eBR - E1) / (eBR - 1);
elseif E1 > eBR
    rP = (E1 - eBR) / (99 - eBR);
else
    rP = 0;
end

end

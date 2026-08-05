function g = g_heuristic_pr_sca1(~, P, u, ~)

% Heuristic belief updating with personal relevance and scaling fixed to one.

eBR = u(1);
E1 = u(2);
BR = u(3);

scaling = 1;
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

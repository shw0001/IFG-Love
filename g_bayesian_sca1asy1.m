function g = g_bayesian_sca1asy1(~, ~, u, ~)

% Bayesian belief updating with raw scaling and asymmetry fixed to one.

eBR = u(1) / 100;
E1 = u(2) / 100;
BR = u(3) / 100;

scaling = 0;
asymmetry = 1;

LR = (E1 / (1 - E1)) / (eBR / (1 - eBR));
BY = (BR * LR) / (BR * LR + (1 - BR));

if eBR <= BR
    UPD = (scaling - asymmetry) * (BY - E1);
else
    UPD = (scaling + asymmetry) * (BY - E1);
end

g = (BY + UPD) * 100;


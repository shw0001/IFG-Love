function g = g_bayesian(~, P, u, ~)  

% inputs
eBR = u(1)/100;
E1 = u(2)/100;
BR = u(3)/100;

% parameters
scaling   = P(1) - 1;
asymmetry = P(2);

% compute the optimal Bayesian update
LR  = (E1 / (1-E1)) / (eBR / (1-eBR));
BY = (BR * LR) / (BR * LR + (1-BR));

if eBR <= BR % negative valence
    UPD = (scaling - asymmetry) * (BY - E1);
else         % positive valence
    UPD = (scaling + asymmetry) * (BY - E1);
end

% predict second estimate
g = (BY + UPD)*100;


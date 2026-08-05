function g = g_heuristic(~, P, u, ~)  

% inputs
eBR = u(1);
E1 = u(2);
BR = u(3);

% parameters
scaling   = P(1);
asymmetry = P(2);

% intermediate values
% =========================================================================
% : estimation error
EE = BR - eBR; 

% : personal knowlege
% uncomment for version with personal relevance weight 
% if E1 < eBR
%    rP = (eBR - E1)/(eBR - 1)
%elseif E1 > eBR
%    rP = (E1 - eBR)/(99 - eBR)
%else 
%    rP = 0;
%end

% : learning rate 
%   = scaling + asymmetry if positive valence (lower risk than expected)
%   = scaling - asymmetry if positive valence (higher risk than expected)
LR = scaling  + sign(eBR-BR) * asymmetry;
   
% belief update
% =========================================================================
E2 = E1 + LR * EE;
%E2 = E1 + LR * EE * (1 - rP); % version with personal relevance weight

% return model prediction
% =========================================================================
g = E2;
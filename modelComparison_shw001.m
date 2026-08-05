function modelComparison_shw001 ()
% // VBA toolbox //////////////////////////////////////////////////////////
%
% demo_modelComparison ()
% demo of random-effect group-level bayesian model selection in the context
% of nested linear models. 
%
% /////////////////////////////////////////////////////////////////////////

% definition of the observations and models
% =========================================================================

% dimensions
% -------------------------------------------------------------------------
% number of subjects
nSubjects = 55;
% number of observatiosn per subject
nObs = 40;
% number of predictors (regressors)
nPred = 4;

% parameters
% -------------------------------------------------------------------------
% % noise variance
% sigma2 = 1e0;
% % signal strength
% signal = 1e0; 
% 
% % generate data
% % -------------------------------------------------------------------------
% for i = 1 : nSubjects
%     
%     % full design matrix
%     X1 = randn (nObs, nPred);
%     % nested model
%     X2 = X1(:, 1 : 2);
%     
%     % random weights
%     b = sqrt (signal) * rand(nPred, 1);
%     
%     % simulate observations
%     y1 = X1 * b + sqrt (sigma2) * randn (nObs, 1);
%     y2 = X2 * b(1 : 2) + sqrt (sigma2) * randn (nObs, 1);
    
    load('I:\&&&&文章写作\#&&&投稿\20220307重生\2024-12补数据后\&&投稿\NC\第一次修改\VBA_toolbox_master\Results\converge_str.mat');%converge_str  D:\VBA_\VBA_toolbox_master\Results\converge_str.mat
    % compute model evidence (frequentist limit)
    logEvidence_y1 = converge_str;

    
% end



% display empirical histogram of log-Bayes factors
% -------------------------------------------------------------------------
plotBayesFactor (logEvidence_y1);

% perform model selection with the VBA
% =========================================================================
options.verbose = false;

% perform group-BMS on data generated under the full model
[p1, o1] = VBA_groupBMC (logEvidence_y1, options);
set (o1.options.handles.hf, 'name', 'group BMS: y_1')

fprintf('Statistics in favor of the true model (m1): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(1), o1.Ef(1));
fprintf('Statistics in favor of the true model (m2): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(2), o1.Ef(2));
fprintf('Statistics in favor of the true model (m3): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(3), o1.Ef(3));
fprintf('Statistics in favor of the true model (m4): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(4), o1.Ef(4));
fprintf('Statistics in favor of the true model (m5): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(5), o1.Ef(5));
fprintf('Statistics in favor of the true model (m6): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(6), o1.Ef(6));
fprintf('Statistics in favor of the true model (m7): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(7), o1.Ef(7));
fprintf('Statistics in favor of the true model (m8): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(8), o1.Ef(8));
fprintf('Statistics in favor of the true model (m9): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(9), o1.Ef(9));
fprintf('Statistics in favor of the true model (m10): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(10), o1.Ef(10));
fprintf('Statistics in favor of the true model (m11): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(11), o1.Ef(11));
fprintf('Statistics in favor of the true model (m12): pxp = %04.3f (Ef = %04.3f)\n', o1.pxp(12), o1.Ef(12));



end

%% ########################################################################
% display subfunctions
% #########################################################################
function plotBayesFactor (logEvidence_y1)
    [n1, x1] = VBA_empiricalDensity ((logEvidence_y1(2,:) )');
    hf = figure ('color' ,'w', 'name', 'demo_modelComparison: distribution of log Bayes factors');
    ha = axes ('parent', hf,'nextplot','add');
    plot (ha, x1, n1, 'color', 'r');

end

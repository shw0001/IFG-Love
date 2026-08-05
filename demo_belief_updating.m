function [posterior,out,parameters] = demo_belief_updating()

    % Make the demo robust when only the toolbox root is on the MATLAB path.
    toolbox_root = fileparts(mfilename('fullpath'));
    addpath(genpath(toolbox_root));

    % generate fake experimental design for the simulation
    % =====================================================================
    % number of trials 
    n_trials = 80;

    % here, all base rates are between 1 and 99
    % each measure is entered as a vector corresponding to all trials
    % questions are not relevant here, only numerical values

    % initial base rate estimation by the participant
    eBR = 1 + randi(98, 1,n_trials);
    % (self) lifetime risk estimation of the participatn
    E1 = 1 + randi(98, 1,n_trials);
    % actual base rate shown by the experimenter
    BR = 1 + randi(98, 1,n_trials);
 
    % inputs
    u(1,:) = eBR;
    u(2,:) = E1;
    u(3,:) = BR;
     
    % simulate estimation update for the model
    % =====================================================================

    % options
    options = struct();

    % update parameters 
    scaling = 0.8; % deviation from unit updating, <1 means UPD<EE
    asymmetry = 0.2; % optimism bias!
    noise_precision = 1e-1; % inverse variance of simulated noise

    % the function g_heuristic predicts updated estimate given first
    % estimate of self and general risk, and true risk
    E2 = VBA_simulate (n_trials,[],@g_heuristic,[],[scaling; asymmetry],u,Inf,noise_precision, options);

    % plot updated self estimate as a function of first self estimate
    % because of the dummy design, there are some implausible values
    figure
    scatter(E1,E2) 

    % plot update as a function of estimation error
    % for positive valence (here defined as BR<eBR, ie EE<0), LR is .8+.2 = 1
    % for negative valence, LR is .8-.2 = .6, 
    figure
    scatter(BR-eBR,E2-E1) 
    refline(1,0)
   
    % invert model
    % =====================================================================

     % &&&&&&&&&&&&&&&&&&&&&&&&&7&&&&&&
    %%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&=====================================================================
    % Basic settings
    
    %%% model 1: asymmetry in belife updating S+A varied 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [0.8316	     -0.0571]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % invert model
    % inversion routine
    
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{1,1} = out.F; 
%     str1{1,1} = out.fit.AIC; 
%     str2{1,1} = out.fit.BIC; 
    scaling_asymmetry{1,1} = parameters.scaling;
    scaling_asymmetry{1,2} = parameters.asymmetry;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 2: non-asymmetry in belife updating S varied,A fixed to zero 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints 
     
    % priors
    priors.muPhi    = [0.8316      0]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic_asy0,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{2,1} = out.F;
%     str1{2,1} = out.fit.AIC; 
%     str2{2,1} = out.fit.BIC; 
    scaling_asymmetry{2,1} = parameters.scaling;
    scaling_asymmetry{2,2} = parameters.asymmetry;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 3: asymmetry in belife updating S fixed to one ,A varied
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [1          -0.0570]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic_sca1,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{3,1} = out.F;
%     str1{3,1} = out.fit.AIC; 
%     str2{3,1} = out.fit.BIC; 
    scaling_asymmetry{3,1} = parameters.scaling;
    scaling_asymmetry{3,2} = parameters.asymmetry;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 4: asymmetry in belife updating S fixed to one ,A fixed to one
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [1 1]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
 
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic_sca1asy1,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{4,1} = out.F;
%     str1{4,1} = out.fit.AIC; 
%     str2{4,1} = out.fit.BIC; 
    scaling_asymmetry{4,1} = parameters.scaling;
    scaling_asymmetry{4,2} = parameters.asymmetry;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 5: asymmetry in belife updating S+A varied +pr 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [1.0190       -0.1107]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % =====================================================================
    % invert model
    % inversion routine
    
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic_pr,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{5,1} = out.F;
%     str1{5,1} = out.fit.AIC; 
%     str2{5,1} = out.fit.BIC; 
    scaling_asymmetry{5,1} = parameters.scaling;
    scaling_asymmetry{5,2} = parameters.asymmetry;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 6: non-asymmetry in belife updating S varied,A fixed to zero +pr 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints 
     
    % priors
    priors.muPhi    = [1.0143    0]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic_pr_asy0,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{6,1} = out.F;
%     str1{6,1} = out.fit.AIC; 
%     str2{6,1} = out.fit.BIC; 
    scaling_asymmetry{6,1} = parameters.scaling;
    scaling_asymmetry{6,2} = parameters.asymmetry;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 7: asymmetry in belife updating S fixed to one ,A varied +pr 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: updateS
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [1     -0.1107]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors
    
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic_pr_sca1,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{7,1} = out.F;
%     str1{7,1} = out.fit.AIC; 
%     str2{7,1} = out.fit.BIC; 
    scaling_asymmetry{7,1} = parameters.scaling;
    scaling_asymmetry{7,2} = parameters.asymmetry;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 8: asymmetry in belife updating S fixed to one ,A fixed to one +pr 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [1 1]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
 
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic_pr_sca1asy1,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{8,1} = out.F;
%     str1{8,1} = out.fit.AIC; 
%     str2{8,1} = out.fit.BIC; 
    scaling_asymmetry{8,1} = parameters.scaling;
    scaling_asymmetry{8,2} = parameters.asymmetry;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % =====================================================================
    % Bayesian models:
    
    %%% model 9-Bayesian model 1: asymmetry in belife updating S+A varied 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [0.6036       -0.0283]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % invert model
    % inversion routine
    
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_bayesian,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{9,1} = out.F; 
%     str1{9,1} = out.fit.AIC; 
%     str2{9,1} = out.fit.BIC; 
    scaling_asymmetry{9,1} = parameters.scaling;
    scaling_asymmetry{9,2} = parameters.asymmetry;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 10-Bayesian model 2: non-asymmetry in belife updating S varied,A fixed to zero 
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints 
     
    % priors
    priors.muPhi    = [0.6188     0]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_bayesian_asy0,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{10,1} = out.F;
%     str1{10,1} = out.fit.AIC; 
%     str2{10,1} = out.fit.BIC; 
    scaling_asymmetry{10,1} = parameters.scaling;
    scaling_asymmetry{10,2} = parameters.asymmetry;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 11-Bayesian model 3: asymmetry in belife updating S fixed to one ,A varied
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [1          0.8062]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_bayesian_sca1,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{11,1} = out.F;
%     str1{11,1} = out.fit.AIC; 
%     str2{11,1} = out.fit.BIC; 
    scaling_asymmetry{11,1} = parameters.scaling;
    scaling_asymmetry{11,2} = parameters.asymmetry;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model 12-Bayesian model 4: asymmetry in belife updating S fixed to one ,A fixed to one
    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [1 1]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
 
    % =====================================================================
    % invert model
    % inversion routine
     
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_bayesian_sca1asy1,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
    str{12,1} = out.F;
%     str1{12,1} = out.fit.AIC; 
%     str2{12,1} = out.fit.BIC; 
    scaling_asymmetry{12,1} = parameters.scaling;
    scaling_asymmetry{12,2} = parameters.asymmetry;
   
    
    str=cell2mat(str);

    results_dir = fullfile(toolbox_root, 'Results');
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
    end
    fname2 = fullfile(results_dir, 'test_str.mat');
    fname3 = fullfile(results_dir, 'test_scaling_asymmetry.mat');

    save (fname2,'str') ;
    save (fname3,'scaling_asymmetry') ;

    
     
    end

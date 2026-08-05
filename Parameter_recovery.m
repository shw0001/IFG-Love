
            
     
        Update_param=strcat('D:\VBA_\VBA_toolbox_master\Results\test_scaling_asymmetry');%',m,'
        New_data=load(Update_param);

        a = New_data.scaling_asymmetry{1,1};
        b = New_data.scaling_asymmetry{1,2};   
        
    
    % optimism bias!
    % generate fake experimental design for the simulation
    % =====================================================================
    % number of trials 
    n_trials = 50;

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
    scaling = a; % deviation from unit updating, <1 means UPD<EE
    asymmetry = b; % optimism bias!
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

    % model dimensions
    dim.n = 0; % state
    dim.p = 1; % observations: update
    dim.n_theta = 0; % evolution parameters
    dim.n_phi = 2; % observation parameters
    dim.n_t = n_trials; % timepoints
     
    % priors
    priors.muPhi    = [0.3864  -0.1430]' ; % scaling and asymetry
    %priors.SignaPhi    = 0.01*eye(2) ; % scaling and asymetry
    [priors.a_sigma, priors.b_sigma] = VBA_guessHyperpriors(E2, [.1, .9]);
    options.priors = priors;
    
    % inversion routine
    [posterior,out] = VBA_NLStateSpaceModel(E2,u,[],@g_heuristic,dim,options);

    % estimated update parameters
    % for simulated data, should be close to ground truth
    parameters.scaling = posterior.muPhi(1);
    parameters.asymmetry = posterior.muPhi(2) ;
    
    % store log-evidence for  model Comparison
        
        scaling_asymmetry{1,1} = parameters.scaling;
        scaling_asymmetry{1,2} = parameters.asymmetry;
    
    eBR = eBR';
    E1 = E1';
    BR = BR';
    E2 = E2';
    
    stimulation_data = cell(50,4);
    
    for i=1:50;
    stimulation_data {i,1}= eBR(i);
    stimulation_data {i,2}= E1(i);
    stimulation_data {i,3}= BR(i);
    stimulation_data {i,4}= E2(i);        

    
    end
    
    
    stimulation_data=cell2mat(stimulation_data);

     fname2=strcat('D:\VBA_\VBA_toolbox_master\Results\test_stimulation_data.mat');
     fname3=strcat('D:\VBA_\VBA_toolbox_master\Results\New_scaling_asymmetry.mat');

     save (fname2,'stimulation_data') ;
     save (fname3,'scaling_asymmetry') ;
 
        
     close all
    end

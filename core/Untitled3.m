[posterior,out] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options,in)

This function inverts any nonlinear state-space model of the form:
  y_t = g( x_t,u_t,phi ) + e_t
  x_t = f( x_t-1,u_t,theta ) + f_t
using a variational bayesian annealing scheme.
It is devoted to the trial estimation problem, ie:
  - estimation of the dynamic hidden-states x_t
  - estimation of the static observation/evolution parameters phi/theta
  - estimation of the variance parameters associated with the measurement
  error e_t and the stochastic innovations f_t.

It is possible to specify priors that are such that the evolution
function is deterministic. In such a case, the function inverts a
standard DCM, and only evolution/observation parameters are estimated
(see bellow).

Calling this function without any input outputs the default inputs.
NB: You can re-display the standard graphical output of the VB scheme by
calling the VBA_ReDisplay.m function.

IN :
  - y: pxn_t mesurements matrix
  - u: mxn_t known input matrix (which is required as an argument in
  the obvservation/evolution functions, default is empty [])
  - f_fname (resp. g_fname): name/handle of the function that returns the
  evolution (resp. observation) of the hidden states.
      ! NB: The generic i/o form of these functions has to conform to the
      following:
                 [ fx,dfdx,dfdP ] = fname(x_t,P,u_t,in)
                     |_________|
                    { varargout }
      where:
      . x_t, u_t and P are respectively the current hidden state value,
      the current input value and the evolution/observation parameters
      value
      . in contains any additional information which has to be passed to
      the functions. For example, it is used to indicate the chosen time
      discretization (dt) for evolution functions that derive from a
      continuous formulation.
      . fx is the current evaluation of the function
      . dfdx and dfdP are the matrices containing the gradients of the
      function w.r.t. the hidden states and the invariant parameters
      ! NB: the output of the evolution/observation functions does not
      have to provide all above derivatives. For, e.g., the evolution
      function, the possible output are: [fx], [fx,dfdx] or
      [fx,dfdx,dfdP]. The missing derivatives are automatically computed
      using numerical derivation.
  - dim: a structure variable containing the dimensions of the 3 sets of
  the model's unknown variables:
      .n: the dimension of the hidden-states
  	.n_theta: the dimension of the vector of evolution parameters theta
  	.n_phi: the dimension of the vector of observation parameters phi
      ! NB: the n_t and p dimensions are derived from the provided
       observation matrix 'y' !
  - options: user-defined structure containing specific informations
  regarding the model, ie (see VBA_check.m):
      .priors: a structure variable containing the priors sufficient
      statistics over the evolution/observation/precision parameters and
      hidden-states initial condition (see VBA_defaultPriors() for standard
      output)
      ! NB: if the prior about the stochastic innovations precision is a
       Dirac delta (priors.a_alpha = Inf, priors.b_alpha = 0), the model
       becomes a deterministic (ODE) state-space model. This is used
       during the initialization of the posterior.
      ! NB2: time-dependent covariance structure for both the measurement
      and the state noise can be passed to the inversion routine through
      the .iQx and .iQy fields (these are cell aray of time-dependent
      precision matrices).
      .decim: the number of times the evolution function is applied
      between each time sample {1}. This is used to increase the
      micro-time resolution
      .microU: a flag determining whether the input u is specified in
      micro-resolution time (1) or in data sampling time ({0}). This is
      useful for providing sub-sampling sparse inputs to the system.
      .inF: a (possibly structure) variable containing the additional
      (internal) fixed parameters which may have to be sent to the
      evolution function {[]}
      .inG: idem for the observation function {[]}
      .checkGrads: a flag for eyeballing provided analytical gradients of
      the evolution/observation function against automated numerical
      derivatives
      .updateX0: a flag indicating whether or not the initial conditions
      should be updated ({1}:yes, 0:no).
      .updateHP: a similar flag for the (precision) hyperparameters {1}
      .backwardLag: a positive integer that defines the size of the
      short-sighted backward pass for the hidden states VB update {1}.
      NB: if 0, there is no backward pass.
      .MaxIter: maximum number of VB iterations {32}
      .MinIter: minimum number of VB iterations {1}
      .TolFun: minimum absolute increase of the free energy {2e-2}
      .DisplayWin: flag to display (1) or not (0) the main display
      window {1}
      .gradF: binary variable that flags whether the regularized
      Gauss_newton update scheme optimizes the free energy (1) or the
      variational energy ({0}) of each mean-field partition.
      .GnMaxIter: maximum number of inner Gauss-Newton iterations {32}
      .GnTolFun: minimum relative increase of the variational energy for
      the inner regularized Gauss-Newton loops {1e-5}
      .GnFigs: flag to display (=1) or not (=0) the Gauss-Newton inner
      loops display figures {0}.
      .delays: dim.nX1 vector containing the discrete delays for the
      evolution function.
      NB: nonzero delays induces an embedding of the system, thereby
      increasing the computational demand of the inversion. The state
      space dimension if multiplied by max(options.delays)+1!
      .sources: a structure or array of structures defining the probability 
       distribution of the observation. If the observations are
       homogenous, this structure can contain a unique field 'type' whose
       value can be: 
         - {0} for normally distributed observation, ie. y = g(x,phi) + eps
            where eps ~ N(0,sigma^2 Id) with sigma^2 is itsel defined by
            hyperparameters a_sigma and b_sigma.
         - 1 for binary observations. It is then  assumed that the 
            likelihood function is a binomial pdf, whose probability is 
            given by the observation function, i.e. g(phi) = p(y=1|phi). 
            The Laplace approximation on observation parameters still holds 
            and the i/o of the inversion routine is conserved.
         - 2 for categorical data. 
       If the observations are composed of a concatenation of differently
       distributed variables, sources should be an array of structures,
       each defining the distribution type as above, and also containing 
       a field 'out' that give the index of the observations covered by the
       distribution.
      .figName: the name of the display window
  - in: structure variable containing the output of a previously ran
  VBA_NLStateSpaceModel.m routine. Providing this input to the function
  allows one to re-start the VB updates from the point where it was
  stopped. The required fields are:
      .posterior: the posterior structure variable (see above)
      .out: the additional output structure of this routine (see above)

OUT:
  - posterior: a structure variable whose fields contain the sufficient
  statistics (typically first and second order moments) of the
  variational approximations to the posterior pdfs over the
  observation/evolution/precision parameters and hidden-states time
  series. Its fields are:
  	.muX: posterior mean of the hidden states X (nxn_t matrix)
      .SigmaX: covariance matrices of the variational posterior pdf of
      the dynamic hidden-states. Using the Kalman-Rauch marginalization
      procedure, this is further divided into:
          SigmaX.current{t} : the instantaneous covariance matrix at t
          SigmaX.inter{t} : the lagged covariance matrix between instants
          t and t+1
      .muX0: posterior mean of the hidden-states initial condition, ie
      before the first observation (nx1 vector)
      .SigmaX0: covariance matrix of the Gaussian df over the
      hidden-states initial condition (nxn matrix)
  	.muTheta: posterior mean of the evolution parameters (vector)
      .SigmaTheta: covariance matrix of the variational posterior pdf of
      the static evolution parameters
  	.muPhi: posterior mean of the observation parameters (vector)
      .SigmaPhi: covariance matrix of the variational posterior pdf of
      the static observation parameters
      .a_alpha / .b_alpha: shape and scale parameters of the variational
      posterior pdf of the stochastic innovations precision
      .a_sigma / .b_sigma: shape and scale parameters of the variational
      posterior pdf of the measurement noise precision
  - out: a structure variable containing the fields...
      .CV: convergence flag (0 if the algorithm has stopped because it
      reached the options.MaxIter termination condition)
      .F: the free energy associated with the inversion of the model
      .options: the options structure which has been used for the
      model inversion
      .dim: the dimensions of the model
      .it: the number of iterations which have been required for reaching
      the convergence criteria
      .suffStat: a structure containing internal variables that act as
      sufficient statistics for the VB updates (e.g. predicted data ...)
      .fit: structure, containing the following fields:
          .LL: log-likelihood of the model
          .R2: coefficient of determination (the fraction of variance
          unexplained is 1-R2)
          .AIC: Akaike Information Criterion
          .BIC: Bayesian Informaion Criterion


JD, 26/02/2007
function results = fit_ddm
    
    % Fit RL-DDM model to data from a two-armed bandit task.
    %
    % USAGE: results = fit_ddm
    %
    % INPUTS:
    %   data - [S x 1] data structure, where S is the number of subjects; see likfun_bandit for more details
    %
    % OUTPUTS:
    %   results - see mfit_optimize for more details
    %
    % Sam Gershman, Jun 2016
    
    % create parameter structure
    
    % drift rate differential action value weight
    param(1).name = 'b';
    param(1).logpdf = @(x) 0;  % uniorm prior
    param(1).lb = -20; % lower bound
    param(1).ub = 20;   % upper bound
    
    % decision threshold
    param(2).name = 'a';
    param(2).logpdf = @(x) 0;
    param(2).lb = 1e-3;
    param(2).ub = 20;
    
    % fit model
    experiments = {'bandit' 'leapfrog'};
    for i = 1:2
        for cond = 1:3
            disp(['Fitting ',experiments{i},', condition ',num2str(cond)]);
            data = bayes_learn(experiments{i},cond);
            
            f = @(x,data) likfun_ddm(x,data);    % log-likelihood function
            res = mfit_optimize(f,param,data);
            
            % get latent variables
            for s = 1:length(data)
                [~,res.latents(s)] = likfun_ddm(res.x(s,:),data(s));
            end
            
            results.(experiments{i})(cond) = res;
        end
    end
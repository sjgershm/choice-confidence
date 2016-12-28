function data = bayes_learn(experiment,cond)
    
    % Bayesian learning of expected reward.
    %
    % USAGE: data = bayes_learn(experiment,cond)
    %
    % INPUTS:
    %   experiment - 'bandit' or 'leapfrog'
    %   cond - condition number (1 = confidence, 2 = outcome, 3 = control)
    %
    % OUTPUTS:
    %   data - data structure with additional field:
    %           .V - [nTrials x nOptions] matrix of reward expectations
    %
    % Sam Gershman, July 2016
    
    switch experiment
        
        case 'bandit'
            data = load_data('bandit_data.csv',cond);
            for s = 1:length(data)
                nTrials = length(data(s).choice);
                for t = 1:nTrials
                    if t == 1 || data(s).block(t)~=data(s).block(t-1)
                        v = [0.5 0.5];
                        N = [2 2];
                    end
                    data(s).V(t,:) = v;
                    c = data(s).choice(t);
                    r = data(s).reward(t);
                    N(c) = N(c) + 1;
                    v(c) = v(c) + (1/N(c))*(r-v(c));
                end
            end
            
        case 'leapfrog'
            data = load_data('leapfrog_data.csv',cond);
            p = 0.1;    % jump probability
            T = [1-p p; p 1-p];
            
            for s = 1:length(data)
                nTrials = length(data(s).choice);
                b = [0.5; 0.5];
                R = [3 2; 2 3];
                for t = 1:nTrials
                    b = T*b;
                    data(s).V(t,:) = b'*R;
                    c = data(s).choice(t);
                    r = data(s).reward(t);
                    
                    if t > 1
                        B = double([R_jump(:,c)==r R_nojump(:,c)==r]);
                        b = b.*(B*[p; 1-p]);
                    else
                        if (c==1 && r==3) || (c==2 && r==2)
                            b = [1; 0];
                        else
                            b = [0; 1];
                        end
                    end
                    b = b./sum(b);
                    
                    % predicted reward under different hypotheses
                    if c == 1
                        R_nojump = [r r-1; r r+1];
                    else
                        R_nojump = [r+1 r; r-1 r];
                    end
                    R_jump = R_nojump + [2 0; 0 2];
                    R = p*R_jump + (1-p)*R_nojump;
                end
            end
    end
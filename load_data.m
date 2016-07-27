function data = load_data(filename,cond)
    
    % Load experimental data from csv file.
    %
    % USAGE: data = load_data(filename,cond)
    %
    % INPUTS:
    %   filename - csv file containing data (either 'bandit_data.csv' or 'leapfrog_data.csv')
    %   cond - condition number (1 = confidence, 2 = outcome, 3 = control)
    %
    % OUTPUTS:
    %   data - [1 x nSubjects] structure array with the following fields:
    %           .R1 - expected reward for option 1
    %           .R2 - expected for option 2
	%           .reward - observed reward
	%           .choice - chosen option
	%           .rt - response time (sec)
    %           .postjudgment - post-choice judgment
    %           .block - block number
    %
    % Sam Gershman, July 2016
    
    f = fopen(filename);
    H = regexp(fgetl(f),',','split');   % header
    H(1:2) = [];
    X = csvread(filename,1);
    cx = X(:,2) == cond;
    x = X(cx,:);
    subs = unique(x(:,1));
    for s = 1:length(subs)
        sx = x(:,1)==subs(s);
        for h = 1:length(H)
            data(s).(H{h}) = x(sx,h+2);
        end
        data(s).N = length(data(s).choice);
        data(s).C = 2;
    end
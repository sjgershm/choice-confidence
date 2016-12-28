function plot_figures(figname,varargin)
    
    % set nicer colors
    C = linspecer(3);
    set(0,'DefaultAxesColorOrder',C);
    
    switch figname
        
        case 'postchoice_bandit'
            
            for i = 1:2
                data = load_data('bandit_data.csv',i);
                P = unique(abs(data(1).R1-data(1).R2));
                
                for n=1:length(data)
                    d=abs(data(n).R1-data(n).R2);
                    for j=1:4
                        ix = d==P(j);
                        p{i}(n,j) = nanmean(data(n).postjudgment(ix));
                    end
                end
                
                [se_p(:,i),m_p(:,i)] = wse(p{i});
            end
            
            figure;
            myerrorbar(m_p,se_p)
            L = {'0.4/0.6' '0.3/0.7' '0.2/0.8' '0.1/0.9'};
            set(gca,'XTickLabel',L,'FontSize',25,'YLim',[0.4 1],'XLim',[0.5 4.5]);
            hold on; plot(get(gca,'XLim'),[0.5 0.5],'--k','LineWidth',2);
            ylabel('Post-choice judgment','FontSize',25);
            xlabel('Reward probabilities','FontSize',25);
            legend({'Confidence' 'Outcome'},'FontSize',25);
            
        case 'bandit_reward'
            data = bayes_learn('bandit',3);
            s = 5;
            r = [data(s).R1 data(s).R2];
            v = data(s).V;
            figure;
            plot(r,'-','LineWidth',4);
            hold on;
            plot(v,'--','LineWidth',4);
            set(gca,'FontSize',25)
            xlabel('Trial','FontSize',25);
            ylabel('Reward probability','FontSize',25);
            
        case 'leapfrog_reward'
            rng(3);
            n = 100;
            p = 0.1;
            x(1,:) = [2 3];
            
            for i = 2:n
                
                x(i,:) = x(i-1,:);
                if rand < p
                    [~,k] = min(x(i,:));
                    x(i,k) = x(i,k) + 2;
                end
                
            end
            
            figure;
            subplot(1,2,1);
            plot(x,'LineWidth',5);
            set(gca,'XLim',[1 n],'YLim',[1 max(x(:))+1],'FontSize',25);
            xlabel('Trial','FontSize',25);
            ylabel('Payoff','FontSize',25);
            legend({'Option A' 'Option B'},'FontSize',25,'Location','North');
            
            subplot(1,2,2);
            K = 5;
            y(:,1) = linspace(0.05,0.3,K);
            y(:,2) = zeros(1,K)+0.1;
            plot(y(:,1),'-k','LineWidth',5); hold on;
            plot(y(:,2),'-','LineWidth',5,'Color',[0.5 0.5 0.5]);
            set(gca,'XTick',1:K,'XLim',[0 K+1],'FontSize',25,'YLim',[0 0.5]);
            xlabel('n','FontSize',25);
            ylabel('Exploration probability','FontSize',25);
            legend({'Ideal actor' 'Naive RL'},'FontSize',25,'Location','North');
            
            set(gcf,'Position',[200 200 1400 500]);
            tightfig;
            
        case 'ddm_param'
            load results_ddm
            experiments = {'bandit' 'leapfrog'};
            for j = 1:length(experiments)
                group = []; X = [];
                for i = 1:3
                    x = results.(experiments{j})(i).x;
                    m(i,:) = mean(x);
                    se(i,:) = std(x)./sqrt(size(x,1));
                    group = [group; zeros(size(x,1),1)+i];
                    X = [X; x];
                end
                plot_param(m,se)
                [p,~,stats] = anova1(X(:,1),group);
                [p,~,stats] = anova1(X(:,2),group);
            end
            
        case 'choice_rt_bandit'
            modes = {'Data' 'Model'};
            load results_ddm
            
            nn = 1;
            
            for ii = 1:length(modes)
                for i = 1:3
                    data = load_data('bandit_data.csv',i);
                    P = unique(abs(data(1).R1-data(1).R2));
                    
                    for n=1:length(data)
                        d=abs(data(n).R1-data(n).R2);
                        for j=1:4
                            ix = d==P(j);
                            [~,k] = max([data(n).R1(ix) data(n).R2(ix)],[],2);    % correct choice
                            switch modes{ii}
                                case 'Model'
                                    c = results.bandit(i).latents(n).p(ix);
                                    c(k==2) = 1-c(k==2);
                                    p{i}(n,j) = mean(c);
                                    rt{i}(n,j) = mean(results.bandit(i).latents(n).rt(ix));
                                case 'Data'
                                    p{i}(n,j) = nanmean(data(n).choice(ix)==k);
                                    rt{i}(n,j) = nanmean(data(n).rt(ix));
                            end
                        end
                    end
                    
                    [se_p(:,i),m_p(:,i)] = wse(p{i});
                    [se_rt(:,i),m_rt(:,i)] = wse(rt{i});
                end
                
                subplot(2,2,nn)
                myerrorbar(m_p,se_p)
                L = {'0.4/0.6' '0.3/0.7' '0.2/0.8' '0.1/0.9'};
                set(gca,'XTickLabel',L,'FontSize',25,'YLim',[0.4 1],'XLim',[0.5 4.5]);
                hold on; plot(get(gca,'XLim'),[0.5 0.5],'--k','LineWidth',2);
                ylabel('P(optimal choice)','FontSize',25);
                xlabel('Reward probabilities','FontSize',25);
                if nn==1; legend({'Confidence' 'Outcome' 'Control'},'FontSize',20); end
                title(modes{ii},'FontSize',25,'FontWeight','Bold');
                
                subplot(2,2,nn+1)
                myerrorbar(m_rt,se_rt)
                L = {'0.4/0.6' '0.3/0.7' '0.2/0.8' '0.1/0.9'};
                set(gca,'XTickLabel',L,'FontSize',25,'XLim',[0.5 4.5],'YLim',[0.4 1]);
                ylabel('Response time (sec)','FontSize',25);
                xlabel('Reward probabilities','FontSize',25);
                title(modes{ii},'FontSize',25,'FontWeight','Bold');
                
                nn = nn + 2;
            end
            
            set(gcf,'Position',[200 200 1200 1000]);
            
        case 'choice_rt_leapfrog'
            
            modes = {'Data' 'Model'};
            load results_ddm
            
            nn = 1;
            
            for ii = 1:2
                for i = 1:3
                    data = load_data('leapfrog_data.csv',i);
                    
                    p = []; rt = [];
                    for s = 1:length(data)
                        R = [data(s).R1 data(s).R2];
                        [~,mx] = max(R,[],2);
                        switch modes{ii}
                            case 'Model'
                                c = results.leapfrog(i).latents(s).p;
                                c(mx==2) = 1-c(mx==2);
                                p(s) = mean(c);
                                rt(s) = mean(results.leapfrog(i).latents(s).rt);
                            case 'Data'
                                p(s) = nanmean(data(s).choice==mx);
                                rt(s) = nanmean(data(s).rt);
                        end
                    end
                    m(i,1) = mean(p);
                    se(i,1) = std(p)./sqrt(length(p));
                    m_rt(i,1) = mean(rt);
                    se_rt(i,1) = std(rt)./sqrt(length(rt));
                    P{i} = p;
                    RT{i} = rt;
                    clear p rt
                end
                
                subplot(2,2,nn);
                myerrorbar(m',se','o');
                L = {'Confidence' 'Outcome' 'Control'};
                set(gca,'XTick',1:3,'XTickLabel',L,'FontSize',25,'XLim',[0.5 3.5],'YLim',[0.4 1]);
                hold on; plot(get(gca,'XLim'),[0.5 0.5],'--k','LineWidth',2);
                ylabel('P(optimal choice)','FontSize',25);
                title(modes{ii},'FontSize',25,'FontWeight','Bold');
                
                subplot(2,2,nn+1);
                myerrorbar(m_rt',se_rt','o');
                set(gca,'XTick',1:3,'XTickLabel',L,'FontSize',25,'XLim',[0.5 3.5],'YLim',[0.4 1]);
                ylabel('Response time (ms)','FontSize',25);
                title(modes{ii},'FontSize',25,'FontWeight','Bold');
                
                nn = nn + 2;
            end
            
            set(gcf,'Position',[200 200 1200 1000]);
            
        case 'conf'
            experiment = varargin{1};
            switch experiment
                case 'leapfrog'
                    filename = 'leapfrog_data.csv';
                case 'bandit'
                    filename = 'bandit_data.csv';
            end
            for j = 1:2
                data = load_data(filename,j);
                S = length(data);
                
                for s = 1:S
                    R = [data(s).R1 data(s).R2];
                    [~,mx] = max(R,[],2);
                    q = quantile(data(s).postjudgment,[0 0.25 0.5 0.75 1]);
                    for i = 2:length(q)
                        ix = data(s).postjudgment <= q(i) & data(s).postjudgment > q(i-1);
                        Q{j}(s,i-1) = nanmean(data(s).choice(ix)==mx(ix));
                        RT{j}(s,i-1) = nanmean(data(s).rt(ix));
                    end
                end
            end
            
            figure;
            subplot(2,2,1);
            [se,m] = wse(Q{1});
            errorbar(m,se,'-ok','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w');
            set(gca,'XLim',[0.5 4.5],'YLim',[0.4 1],'XTick',1:4,'XTickLabel',{'0-25' '26-50' '51-75' '76-100'},'FontSize',25);
            hold on;
            plot(get(gca,'XLim'),[0.5 0.5],'--k','LineWidth',2);
            xlabel('Confidence judgment quartile','FontSize',25);
            ylabel('P(optimal choice)','FontSize',25);
            
            subplot(2,2,2);
            [se,m] = wse(RT{1});
            errorbar(m,se,'-ok','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w');
            set(gca,'YLim',[0.5 1],'XLim',[0.5 4.5],'XTick',1:4,'XTickLabel',{'0-25' '26-50' '51-75' '76-100'},'FontSize',25);
            xlabel('Confidence judgment quartile','FontSize',25);
            ylabel('Response time (sec)','FontSize',25);
            set(gcf,'Position',[200 200 1200 400]);
            
            subplot(2,2,3);
            [se,m] = wse(Q{2});
            errorbar(m,se,'-ok','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w');
            set(gca,'XLim',[0.5 4.5],'YLim',[0.4 1],'XTick',1:4,'XTickLabel',{'0-25' '26-50' '51-75' '76-100'},'FontSize',25);
            hold on;
            plot(get(gca,'XLim'),[0.5 0.5],'--k','LineWidth',2);
            xlabel('Outcome judgment quartile','FontSize',25);
            ylabel('P(optimal choice)','FontSize',25);
            
            subplot(2,2,4);
            [se,m] = wse(RT{2});
            errorbar(m,se,'-ok','LineWidth',4,'MarkerSize',10,'MarkerFaceColor','w');
            set(gca,'YLim',[0.5 1],'XLim',[0.5 4.5],'XTick',1:4,'XTickLabel',{'0-25' '26-50' '51-75' '76-100'},'FontSize',25);
            xlabel('Outcome judgment quartile','FontSize',25);
            ylabel('Response time (sec)','FontSize',25);
            
            set(gcf,'Position',[200 200 1200 900]);
            %tightfig
            
    end
    
end

%%%%%%%%%%%%%

function plot_param(m,se)
    C = linspecer(3);
    figure;
    names = {'Drift rate' 'Threshold'};
    for j = 1:2
        subplot(1,2,j);
        for i = 1:3
            errbar(i,m(i,j),se(i,j),'LineWidth',5,'Color',C(i,:));
            hold on;
            plot(i,m(i,j),'o','LineWidth',5,'MarkerSize',12,'MarkerFaceColor',C(i,:),'Color',C(i,:));
            
        end
        set(gca,'XTick',1:3,'XTickLabel',{'Confidence' 'Outcome' 'Control'},'FontSize',25,'XLim',[0.5 3.5]);
        ylabel(names{j},'FontSize',25);
    end
    set(gcf,'Position',[200 200 1200 400]);
    tightfig;
end

function myerrorbar(m,se,marker)
    if nargin < 3; marker = '-'; end
    C = linspecer(3);
    for i = 1:size(m,2)
        if size(m,1)==1
            x = i;
        else
            x = 1:size(m,1);
        end
        errbar(x',m(:,i),se(:,i),'LineWidth',5,'Color',C(i,:));
        hold on;
    end
    for i = 1:size(m,2)
        if size(m,1)==1
            x = i;
        else
            x = 1:size(m,1);
        end
        plot(x',m(:,i),marker,'LineWidth',5,'MarkerSize',12,'MarkerFaceColor',C(i,:),'Color',C(i,:));
    end
end
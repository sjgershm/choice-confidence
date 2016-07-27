function plot_figures(figname)
    
    % set nicer colors
    C = linspecer(3);
    set(0,'DefaultAxesColorOrder',C);
    
    switch figname
        
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
                for i = 1:3
                    x = results.(experiments{j})(i).x;
                    m(i,:) = mean(x);
                    se(i,:) = std(x)./sqrt(size(x,1));
                end
                plot_param(m,se)
            end
            
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
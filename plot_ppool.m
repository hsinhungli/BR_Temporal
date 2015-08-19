fileName = './Data/cond_1_08171247';
load(fileName);
nsim = length(p_pool);
condnames  =  {'B/A','B/iA','P/A','P/iA','SR/A','SR/iA','R/A','R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
subplotlocs    = [4 6 2 1 3]; %on a 2x3 plot
%% Dominance duration
for i = 1:nsim
    domDuration(i,:) = p_pool{i}.domDuration;
    contrast(i,:)    = p_pool{i}.contrast;
    fraction(i)      = domDuration(i,2) / sum(domDuration(i,:));
end
domDuration(isnan(domDuration)) = 0;
cpsFigure(.5,.5)
plot(fraction, domDuration(:,1), '-o',fraction, domDuration(:,2) ,'-o')
% ylim([0 10])
% xlim([0 1])
xlabel('Fraction B','FontSize',14)
ylabel('Mean duration (s)','FontSize',14)
legend({'A: fixed','B: varied'})

cpsFigure(.5,.5)
plot(contrast(:,2), domDuration(:,1), '-o',contrast(:,2), domDuration(:,2) ,'-o')
ylim([0 10])
%xlim([0 1])
xlabel('Contrast B','FontSize',14)
ylabel('Mean duration (s)','FontSize',14)
legend({'A: fixed','B: varied'})

cpsFigure(.5,.5)
plot(contrast(:,2), fraction,'-o')
ylim([0 1])
%xlim([0 1])
xlabel('Contrast B','FontSize',14)
ylabel('Fraction B','FontSize',14)
legend({'B: varied'})
%% Dominance duration
cpsFigure(.6*nsim,.6);
for i = 1:nsim
    subplot(1,nsim,i)
    hist(p_pool{i}.durationDist,100);
end
tightfig;

%% Rivalry Idx
cpsFigure(.6*nsim,.6);
xa = (1:p_pool{1}.epochlength-1)-p_pool{1}.epochlength/2;
xa = xa/1000;
for i = 1:nsim
    subplot(1,nsim,i)
    plot(xa,p_pool{i}.aSignal,'LineWidth',1.2);hold on;
    plot(xa,p_pool{i}.rSignal,'k','LineWidth',1.2);
    xlim([min(xa) max(xa)])
end
tightfig;

%%
pIdx  = 1;
tplot = 1:10000;

cpsFigure(2,.8);
set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{p_pool{1}.cond}, p_pool{pIdx}.contrast(1), p_pool{pIdx}.contrast(2)));
for lay = 1:p_pool{1}.nLayers
    subplot(2,3,subplotlocs(lay))
    cla; hold on;
    temp1 = squeeze(p_pool{pIdx}.r{lay}(1,tplot));
    temp2 = squeeze(p_pool{pIdx}.r{lay}(2,tplot));
    pL = plot(p_pool{pIdx}.tlist(tplot)/1000,temp1,'color',[1 0 1]);
    pR = plot(p_pool{pIdx}.tlist(tplot)/1000,temp2,'color',[0 0 1]);
    
    ylabel('Firing rate')
    xlabel('Time (s)')
    title(layernames(lay))
    %set(gca,'XLim',[0 p.T(tplot)/1000]);
    set(gca,'YLim',[0 max([temp1(:)' temp2(:)'])+.1]);
    drawnow;
end
subplot(2,3,5)
plot(p_pool{pIdx}.tlist(tplot)/1000,p_pool{pIdx}.att(1,tplot),'color',[1 0 1]); hold on;
plot(p_pool{pIdx}.tlist(tplot)/1000,p_pool{pIdx}.att(2,tplot),'color',[0 0 1]);
title('Attention')

% Draw time sereis_2
cpsFigure(1,1.5);
set(gcf,'Name',sprintf('%s contrast: %1.1f %1.1f', condnames{p_pool{1}.cond}, p_pool{pIdx}.contrast(1), p_pool{pIdx}.contrast(2)));

%To view the two rivarly time series
subplot(3,1,1);hold on
title('LE & RE')
for lay = 1:2
    temp1 = squeeze(p_pool{pIdx}.r{lay}(1,tplot));
    temp2 = squeeze(p_pool{pIdx}.r{lay}(2,tplot));
    switch lay
        case 1
            plot(p_pool{pIdx}.tlist(tplot)/1000, temp1,'r-','LineWidth',1.5)
        case 2
            plot(p_pool{pIdx}.tlist(tplot)/1000, temp2,'b--','LineWidth',1)
    end
    set(gca,'FontSize',12)
end

%Left eye
subplot(3,1,2);hold on
title('LE')
lay=1;
temp1 = squeeze(p_pool{pIdx}.r{lay}(1,tplot));
temp2 = squeeze(p_pool{pIdx}.r{lay}(2,tplot));
plot(p_pool{pIdx}.tlist(tplot)/1000, temp1,'r-','LineWidth',1.5)
plot(p_pool{pIdx}.tlist(tplot)/1000, temp2,'b-','LineWidth',1.5)

%Right eye
subplot(3,1,3);hold on
title('RE')
lay=2;
temp1 = squeeze(p_pool{pIdx}.r{lay}(1,tplot));
temp2 = squeeze(p_pool{pIdx}.r{lay}(2,tplot));
plot(p_pool{pIdx}.tlist(tplot)/1000, temp1,'r:','LineWidth',1)
plot(p_pool{pIdx}.tlist(tplot)/1000, temp2,'b:','LineWidth',1)
xlabel('Time (sec)', 'FontSize',12)
drawnow;


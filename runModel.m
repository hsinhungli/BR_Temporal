close all;
drawnow;
condnames =  {'B/A','B/iA','SR',[],'P/A', 'P/iA', 'R/A', 'R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
p = setParameters;

%% Make stimuli
% Pick contrasts to run
numContrasts = 1;
p.cRange     = .9;
logp.cRange  = log10(p.cRange);
logContrasts = linspace(logp.cRange(1),logp.cRange(1),numContrasts);
contrasts    = 10.^logContrasts;

% Pick conditions to run
rcond           = [2 6]; %which condition to run
ncond           = numel(rcond);
rcontrast       = 1:numContrasts; %which contrast level
ncontrasts      = numel(rcontrast);
p.rcond         = rcond;

%% Initializing time-courses
for lay=1:p.nLayers %go through maximum possible layers. This way, if there are <5 layers, the feedback can be zero.
    p.d{lay}   = zeros(p.ntheta,p.nt); %Drive
    p.s{lay}   = zeros(p.ntheta,p.nt); %Suppressive Drive
    p.r{lay}   = zeros(p.ntheta,p.nt); %Firing Rate
    p.f{lay}   = zeros(p.ntheta,p.nt); %Estimated Asy firing rate
    p.a{lay}   = zeros(p.ntheta,p.nt); %Adaptation term
    p.dr{lay}  = zeros(p.ntheta,p.nt); %Differentiation of firing rate (r)
    if ismember(lay,[1 2])
        p.inh{lay} = zeros(p.ntheta,p.nt);
    end
    
    p.d_n{lay}   = n_makeNoise(p.ntheta,lay,p,p.d_noiseamp,p.d_noisefilter_t); %Noise at drive
    p.f_n{lay}   = n_makeNoise(p.ntheta,lay,p,p.f_noiseamp,p.f_noisefilter_t); %Noise at firing
    p.m_n{lay}   = n_makeNoise(p.ntheta,lay,p,p.m_noiseamp,p.m_noisefilter_t); %Noise of measurement
end

p.att          = ones(p.ntheta,p.nt); %Attentional gain factor
p.attTrace     = zeros(p.ntheta,p.nt); %Record of Attentional gain factor
p.WTA          = zeros(p.ntheta,p.nt);
p_pool         = cell(max(rcond));
stim           = cell(ncond,2);
p.wta          = zeros(ncontrasts);
p.corrIdx      = zeros(ncontrasts);
p.meanAmp      = zeros(ncontrasts);
p.rivalryIdx   = zeros(ncond,1);
subplotlocs    = [4 6 2 1 3]; %on a 2x3 plot
%% loop through stimuli conditions
for cond = rcond
    %% Decide stimuli configuration for this condition
    fprintf('condition %d \n', cond);
    p = setModelPar(cond, p);
    p = setStim(cond, p);
    
    %% Loop through contrast levels
    for c = 1
        stim{cond,c,1} = p.stimL*contrasts(c);
        stim{cond,c,2} = p.stimR*contrasts(c);
        
        %Stimulus inputs to monocular layers
        for lay = 1:2
            p.i{lay} = stim{cond,c,lay};
        end
        
        %run the model
        ShowIdx = 1;
        p = n_model(p, cond);
        
        %% Draw time series_1
        cpsFigure(2,.8)
        set(gcf,'Name',['cond:' num2str(cond) ' contrast level:' num2str(c)])
        for lay = 1:p.nLayers
            subplot(2,3,subplotlocs(lay))
            cla; hold on;
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            %temp4 = squeeze(p.a{lay}(IdxR(1),IdxR(2),:));
            pL = plot(p.tlist/1000,temp1,'color',[1 0 1]);
            pR = plot(p.tlist/1000,temp2,'color',[0 0 1]);
            %legend([pL pR], 'Suppressor','Target')
            %text(0,.9,['Aamp= ' num2str((p.rA{lay}*p.rA{lay}'/p.nt)^.5) ' Bamp= ' num2str((p.rB{lay}*p.rB{lay}'/p.nt)^.5)], 'FontSize', 10)
            %text(0,.9,['Aamp= ' num2str(mean(abs(p.rA{lay}))) ' Bamp= ' num2str(mean(abs(p.rB{lay})))], ...
            %    'FontSize', 10);
            
            ylabel('Firing rate')
            xlabel('Time (s)')
            title(layernames(lay))
            set(gca,'XLim',[0 p.T/1000]);
            set(gca,'YLim',[0 max([temp1(:)' temp2(:)'])+.1]);
            drawnow;
        end
        subplot(2,3,5)
        plot(p.tlist/1000,p.att(1,:),'color',[1 0 1]); hold on;
        plot(p.tlist/1000,p.att(2,:),'color',[0 0 1]);
        
        %figure;
        %WTA = reshape(p.WTA,12,size(p.WTA,3));
        %plot(WTA'); xlim([0 size(p.WTA,3)]);
        
        %% Draw time sereis_2
        cpsFigure(1,1.5);
        set(gcf,'Name',condnames{cond});
        subplot(3,1,1);hold on
        title('LE & RE')
        for lay = 1:2
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            switch lay
                case 1
                    plot(p.tlist/1000, temp1,'r-','LineWidth',1.5)
                    if ismember(cond, [3 4])
                        plot(p.tlist/1000, temp2,'b-','LineWidth',1.5)
                    end
                case 2
                    if ismember(cond, [3 4])
                        plot(p.tlist/1000, temp1,'r--','LineWidth',1.5)
                    end
                    plot(p.tlist/1000, temp2,'b--','LineWidth',1)
            end
            set(gca,'FontSize',12)
        end
        subplot(3,1,2);hold on
        title('LE')
        lay=1;
        temp1 = squeeze(p.r{lay}(1,:));
        temp2 = squeeze(p.r{lay}(2,:));
        plot(p.tlist/1000, temp1,'r-','LineWidth',1.5)
        plot(p.tlist/1000, temp2,'b-','LineWidth',1.5)
        %plot(p.tlist/1000, max([temp1';temp2']),'k');
        subplot(3,1,3);hold on
        title('RE')
        lay=2;
        temp1 = squeeze(p.r{lay}(1,:));
        temp2 = squeeze(p.r{lay}(2,:));
        plot(p.tlist/1000, temp1,'r:','LineWidth',1)
        plot(p.tlist/1000, temp2,'b:','LineWidth',1)
        xlabel('Time (sec)', 'FontSize',12)
        drawnow;
        
        %% compute WTA index
        if ismember(cond,[5 6])
            temp1 = squeeze(p.r{1}(1,:));
            temp2 = squeeze(p.r{1}(2,:));
            
        else
            temp1 = squeeze(p.r{1}(1,:));
            temp2 = squeeze(p.r{2}(2,:));
        end
        
        %Use Summation Layers
        %temp1 = squeeze(p.r{3}(1,:));
        %temp2 = squeeze(p.r{3}(2,:));
        
        temp1(p.tlist<2000) = [];
        temp2(p.tlist<2000) = [];
        p.diff(c) = nanmean(abs(temp1-temp2));
        p.corrIdx(c) = corr(temp1',temp2');
        p.meanAmp(c) = mean([temp1 temp2]);
        p.diff(c) = mean(abs(temp1-temp2));
        %save the p
        p_pool{cond} = p;
    end
end

%%
cpsFigure(ncond*.5,.7);
epochlength = 6000;
aSignal = [];
rSignal = [];
for i = 1:ncond
    condIdx = rcond(i);
    subplot(1,ncond,i);
    if ismember(condIdx,[5 6])
        data1 = p_pool{condIdx}.r{1}(1,:);
        data2 = p_pool{condIdx}.r{1}(2,:);
    else
        data1 = p_pool{condIdx}.r{1}(1,:);
        data2 = p_pool{condIdx}.r{2}(2,:);
    end
    
    %Use summation Layer
    %data1 = p_pool{condIdx}.r{3}(1,:);
    %data2 = p_pool{condIdx}.r{3}(2,:);
    
    [tempEpoch,tempEpochr,domD] = getEpoch(p_pool{rcond(1)},data1,data2,epochlength);
    domDuration(condIdx) = domD/1000;
    x = 1:size(tempEpoch,2);
    x = ((x/max(x))*epochlength-epochlength/2)/1000;
    aSignal(i,:) = mean(tempEpoch);
    rSignal(i,:) = mean(tempEpochr);
    plot(x,aSignal(i,:),'LineWidth',1.2);hold on;
    plot(x,rSignal(i,:),'k','LineWidth',1.2);
    rivalryIdx(i) = abs(max(aSignal(i,:)) - min(rSignal(i,:)))/abs(max(aSignal(i,:)) + min(rSignal(i,:)));
    xlim([min(x) max(x)])
    ylim([0 1.5])
    title(condnames(condIdx),'FontSize', 12)
end
cpsFigure(1,1);
for i = 1:ncond
    bar(i,domDuration(rcond(i)), 'FaceColor', [.6 .6 .6]); hold on
end
%ylim([0 max(domDuration)+2])
ylabel('domDuration','FontSize', 12)
set(gca,'XTick',1:ncond,'FontSize', 12)
set(gca,'XTickLabel', (condnames(rcond)));

%% Plot Index
cpsFigure(1.4,.6)
subplot1(1,3,'Gap',[0.05 0.02]);hold on;

subplot1(1)
for i = 1:ncond
    bar(i,rivalryIdx(i), 'FaceColor', [.6 .6 .6]);
end
title('Rivalry index','FontSize',14)
ylim([0 1]); xlim([0.5 ncond+.5])
set(gca,'XTick', 1:ncond,'FontSize', 10)
set(gca,'XTickLabel', (condnames(rcond)));
set(gca,'FontSize',14);

% subplot1(2)
% for i = 1:ncond
%     bar(i,p_pool{rcond(i)}.diff, 'FaceColor', [.6 .6 .6]);
% end
% title('diff index','FontSize',14)
% ylim([0 1]); xlim([0.5 ncond+.5])
% set(gca,'XTick', 1:ncond,'FontSize', 10)
% set(gca,'XTickLabel', (condnames(rcond)));
% set(gca,'FontSize',14);

subplot1(2)
for i = 1:ncond
    bar(i,p_pool{rcond(i)}.corrIdx, 'FaceColor', [.6 .6 .6]); hold on
end
title('Correlation','FontSize',14)
ylim([-1 1]); xlim([0.5 ncond+.5])
set(gca,'YTick', -1:.5:1,'FontSize', 10)
set(gca,'YTickLabel', -1:.5:5);
set(gca,'XTick', 1:ncond,'FontSize', 10)
set(gca,'XTickLabel', (condnames(rcond)));
set(gca,'FontSize',14);

subplot1(3)
for i = 1:ncond
    bar(i,p_pool{rcond(i)}.meanAmp, 'FaceColor', [.6 .6 .6]); hold on
end
title('Mean Amplitude','FontSize',14)
set(gca,'FontSize',14); xlim([0.5 ncond+.5])
set(gca,'XTick', 1:ncond,'FontSize', 14)
set(gca,'XTickLabel', (condnames(rcond)));

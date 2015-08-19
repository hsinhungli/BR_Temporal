close all; drawnow;
condnames  =  {'B/A','B/iA','P/A','P/iA','SR/A','SR/iA','R/A','R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
p        = setParameters;
saveData = 0;
%% Set conditions/contrasts to simulate
% Pick contrasts to run
contrasts =...
    [.2;...
     .2];

% Pick conditions to run
rcond     = 3;   %conditions to run
ncond     = numel(rcond);
rcontrast = 3; %contrast levels to run
ncontrast = numel(rcontrast);
plotFig   = 1;
if plotFig == 1
    plotduration = 2*60*1000;
end
condtag  = regexprep(num2str(rcond),'\W','');
dataName = sprintf('./Data/cond_%s_%s.mat',condtag,datestr(now,'mmddHHMM'));

%% Initializing time-courses
% for lay=1:p.nLayers %go through maximum possible layers. Use the same noise for all the condition simulated
%     p.d_n{lay}   = n_makeNoise(p.ntheta,lay,p,p.d_noiseamp,p.d_noisefilter_t); %Noise at drive
%     p.f_n{lay}   = n_makeNoise(p.ntheta,lay,p,p.f_noiseamp,p.f_noisefilter_t); %Noise at firing
%     p.m_n{lay}   = n_makeNoise(p.ntheta,lay,p,p.m_noiseamp,p.m_noisefilter_t); %Noise of measurement
% end
p_pool         = cell(ncond*ncontrast,1); %data (p) of each simulated condition will be saved here
subplotlocs    = [4 6 2 1 3]; %on a 2x3 plot

%% loop through stimuli conditions
count = 0;
for cond = rcond
    
    %% Decide stimuli configuration for this condition
    p = setModelPar(cond, p);
    
    %% Loop through contrast levels
    for c = rcontrast
        
        p.cond = cond;
        p.contrast = contrasts(:,c);
        fprintf('cond: %s contrast: %1.2f %1.2f \n', condnames{cond}, p.contrast(1), p.contrast(2))
        count = count+1;
        p = initTimeSeries(p);
        p = setStim(cond,p);
        stim{cond,c,1} = p.stimL; %This has to change for monocular plaid
        stim{cond,c,2} = p.stimR; %This has to change for monocular plaid
        
        %Stimulus inputs to monocular layers
        for lay = 1:2
            p.i{lay} = stim{cond,c,lay};
        end
        
        %run the model
        ShowIdx = 1;
        p       = n_model(p, cond);
        
        %% compute WTA index
        p = getIndex(p);
        
        %save the p
        p_pool{count} = p;
        
        %% Draw time series_1
        if plotFig == 1
            cpsFigure(2,.8);
            set(gcf,'Name',sprintf('%s contrast: %1.2f %1.2f', condnames{cond}, p.contrast(1), p.contrast(2)));
            for lay = 1:p.nLayers
                subplot(2,3,subplotlocs(lay))
                cla; hold on;
                temp1 = squeeze(p.r{lay}(1,:));
                temp2 = squeeze(p.r{lay}(2,:));
                pL = plot(p.tlist/1000,temp1,'color',[1 0 1]);
                pR = plot(p.tlist/1000,temp2,'color',[0 0 1]);
                
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
            title('Attention')
            tightfig;
            
            %% Draw time sereis_2
            cpsFigure(1,1.5);
            set(gcf,'Name',sprintf('%s contrast: %1.1f %1.1f', condnames{cond}, p.contrast(1), p.contrast(2)));
            
            %To view the two rivarly time series
            subplot(4,1,1);hold on
            title('LE & RE')
            imagesc(p.tlist/1000,.5,p.phaseIdx)
            colormap([.8 .65 .65;.65 .65 .8;])
            xlim([1 max(p.tlist/1000)])
            lay = 3;
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            plot(p.tlist/1000, temp1,'r-')
            plot(p.tlist/1000, temp2,'b-')
            set(gca,'FontSize',12)
            
            %Left eye
            subplot(4,1,2);hold on
            title('LE')
            lay=1;
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            plot(p.tlist/1000, temp1,'r-')
            plot(p.tlist/1000, temp2,'b-')
            
            %Right eye
            subplot(4,1,3);hold on
            title('RE')
            lay=2;
            temp1 = squeeze(p.r{lay}(1,:));
            temp2 = squeeze(p.r{lay}(2,:));
            plot(p.tlist/1000, temp1,'r:','LineWidth',1)
            plot(p.tlist/1000, temp2,'b:','LineWidth',1)
            xlabel('Time (sec)', 'FontSize',12)
            drawnow;
            
            subplot(4,1,4);hold on
            title('Phase')
            imagesc(p.tlist/1000,1,p.phaseIdx)
            xlim([1 max(p.tlist/1000)])
            axis fill
            tightfig;
        end
    end
end

if saveData==1
    save(dataName,'p_pool');
end

% %%
% temp = p_pool{1};
% cpsFigure(.5,.5);
% xa = 1:size(temp.rSignal,2);
% xa = ((xa/max(xa))*temp.epochlength-temp.epochlength/2)/1000;
% plot(xa,temp.aSignal,'LineWidth',1.2);hold on;
% plot(xa,temp.rSignal,'k','LineWidth',1.2);
% 
% cpsFigure(ncond*.5,.7);
% epochlength = 6000; %in msec
% filter_std  = 300; %in msec
% aSignal = [];
% rSignal = [];
% 
% for i = 1:ncond
%     cond = rcond(i);
%     for c = 1:ncontrast
%         subplot(ncontrast,ncond,(i-1)*ncontrast+c);
%         
%         plot(x,aSignal(i,:),'LineWidth',1.2);hold on;
%         plot(x,rSignal(i,:),'k','LineWidth',1.2);
%         
%         xlim([min(x) max(x)])
%         ylim([0 1.5])
%         title(condnames(condIdx),'FontSize', 12)
%     end
% end
% 
% % cpsFigure(1,1);
% % for i = 1:ncond
% %     bar(i,domDuration(rcond(i)), 'FaceColor', [.6 .6 .6]); hold on
% % end
% % %ylim([0 max(domDuration)+2])
% % ylabel('domDuration','FontSize', 12)
% % set(gca,'XTick',1:ncond,'FontSize', 12)
% % set(gca,'XTickLabel', (condnames(rcond)));
% 
% %% Plot Index
% cpsFigure(1.4,.6)
% subplot1(1,3,'Gap',[0.05 0.02]);hold on;
% 
% subplot1(1)
% for i = 1:ncond
%     bar(i,rivalryIdx(i), 'FaceColor', [.6 .6 .6]);
% end
% title('Rivalry index','FontSize',14)
% ylim([0 1]); xlim([0.5 ncond+.5])
% set(gca,'XTick', 1:ncond,'FontSize', 10)
% set(gca,'XTickLabel', (condnames(rcond)));
% set(gca,'FontSize',14);
% 
% % subplot1(2)
% % for i = 1:ncond
% %     bar(i,p_pool{rcond(i)}.diff, 'FaceColor', [.6 .6 .6]);
% % end
% % title('diff index','FontSize',14)
% % ylim([0 1]); xlim([0.5 ncond+.5])
% % set(gca,'XTick', 1:ncond,'FontSize', 10)
% % set(gca,'XTickLabel', (condnames(rcond)));
% % set(gca,'FontSize',14);
% 
% subplot1(2)
% for i = 1:ncond
%     bar(i,p_pool{rcond(i)}.corrIdx, 'FaceColor', [.6 .6 .6]); hold on
% end
% title('Correlation','FontSize',14)
% ylim([-1 1]); xlim([0.5 ncond+.5])
% set(gca,'YTick', -1:.5:1,'FontSize', 10)
% set(gca,'YTickLabel', -1:.5:5);
% set(gca,'XTick', 1:ncond,'FontSize', 10)
% set(gca,'XTickLabel', (condnames(rcond)));
% set(gca,'FontSize',14);
% 
% subplot1(3)
% for i = 1:ncond
%     bar(i,p_pool{rcond(i)}.meanAmp, 'FaceColor', [.6 .6 .6]); hold on
% end
% title('Mean Amplitude','FontSize',14)
% set(gca,'FontSize',14); xlim([0.5 ncond+.5])
% set(gca,'XTick', 1:ncond,'FontSize', 14)
% set(gca,'XTickLabel', (condnames(rcond)));

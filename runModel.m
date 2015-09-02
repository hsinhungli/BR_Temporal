close all; drawnow;
condnames  =  {'B/A','B/iA','P/A','P/iA','SR/A','SR/iA','R/A','R/iA'};
layernames =  {'L. Monocular', 'R. Monocular', 'Summation', 'L-R Opponency', 'R-L Opponency'};
p          = setParameters;
saveData   = 0;
%% Set conditions/contrasts to simulate
% Pick contrasts to run
contrasts =...
    [1;...
     1];

% Pick conditions to run
rcond     = [1 2 3];   %conditions to run
ncond     = numel(rcond);
rcontrast = 1; %contrast levels to run
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
        p       = n_model(p);
        
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
            title('Summation Layer')
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

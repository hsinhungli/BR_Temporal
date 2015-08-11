function [tempEpoch,tempEpochr,dominanceDuration] = getEpoch(p,data1,data2,epochlength)

tIdx = epochlength/2/p.dt:(p.T-epochlength/2)/p.dt;
temp1 = data1;
temp2 = data2;

kernel = 0:p.dt:2400;
kernel = normpdf(kernel,kernel((length(kernel)+1)/2),1200/p.dt);
kernel = kernel./sum(kernel);
ftemp1 = conv(temp1,kernel,'same');
ftemp2 = conv(temp2,kernel,'same');

% figure;
% plot(temp1,'b--');hold on;
% plot(ftemp1,'b-');hold on;
% plot(temp2,'r--');hold on;
% plot(ftemp2,'r-');hold off;

tempEpoch = [];
tempEpochr = [];

for iter = 1:2
    if iter ==1
        phaseIdx = ftemp1>ftemp2;
        seedtemp = ftemp1;
        rivaltemp = ftemp2;
    elseif iter ==2
        phaseIdx = ftemp2>ftemp1;
        seedtemp = ftemp2;
        rivaltemp = ftemp1;
    end
    
    % figure;
    % stem(phaseIdx);
    
    count = 0;
    currentValue = 0;
    currentPhase = 0;
    for Idx = tIdx;
        if phaseIdx(Idx) == 1
            if currentPhase == 0
                count = count+1;
            end
            newValue = seedtemp(Idx);
            if newValue > currentValue
                currentValue = newValue;
                localMax(count) = Idx;
            end
            currentPhase = 1;
        else
            currentPhase = 0;
            currentValue = 0;
        end
    end
    
    
    if exist('localMax','var')
        for i = 1:length(localMax)
            Idx = localMax(i);
            Idx1 = Idx-epochlength/2/p.dt+1;
            Idx2 = Idx+epochlength/2/p.dt-1;
            tempEpoch = [tempEpoch; seedtemp(Idx1:Idx2)];
            tempEpochr = [tempEpochr; rivaltemp(Idx1:Idx2)];
        end
    end
    
    if iter == 1
        reversalIdx = abs(diff(phaseIdx));
        reversaltime = [0 p.tlist(reversalIdx==1) p.tlist(end)];
        dominanceDuration = mean(diff(reversaltime));
        
    end
end
% plot(tempEpoch'); hold on;
% plot(mean(tempEpoch),'LineWidth',1.5);
% plot(mean(tempEpochr),'k','LineWidth',1.5);
% hold off;
end
function [tempEpoch,tempEpochr,dominanceDuration,durationDist,phaseIdx,fdata1,fdata2] = getEpoch(p,data1,data2,epochlength,filter_std)

tIdx  = epochlength/2/p.dt:(p.T-epochlength/2)/p.dt;
temp1 = data1;
temp2 = data2;

kernel = 0:p.dt:filter_std*4;
kernel = normpdf(kernel,kernel((length(kernel)+1)/2),filter_std/p.dt);
kernel = kernel./sum(kernel);
fdata1 = conv(temp1,kernel,'same');
fdata2 = conv(temp2,kernel,'same');
validIdx = round([length(kernel)*1.5 length(fdata1)-length(kernel)*1.5]);

% figure;
% plot(temp1,'b--');hold on;
% plot(ftemp1,'b-');hold on;
% plot(temp2,'r--');hold on;
% plot(ftemp2,'r-');hold off;

tempEpoch  = [];
tempEpochr = [];
dominanceDuration = nan(1,2);
durationDist = [];

for iter = 1:2
    if iter ==1
        phaseIdx  = fdata1>fdata2;
        seedtemp  = fdata1;
        rivaltemp = fdata2;
    elseif iter ==2
        phaseIdx  = fdata2>fdata1;
        seedtemp  = fdata2;
        rivaltemp = fdata1;
    end
    
    %get Dominance duration
    reversalIdx  = diff([0 phaseIdx]);
    onsetIdx     = find(reversalIdx==1);
    reversalIdx  = diff([phaseIdx 0]);
    offsetIdx    = find(reversalIdx==-1);
    phaseduration = (offsetIdx - onsetIdx)*p.dt;
    dominanceDuration(iter) = mean(phaseduration);
    durationDist = [durationDist phaseduration];
    
    %if iter == 1
    %    reversalIdx       = abs(diff(phaseIdx));
    %    reverseTime       = [0 p.tlist(reversalIdx==1) p.tlist(end)];
    %    durationDist_full = diff(reverseTime);
    %end
    
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
        localMax(localMax<validIdx(1) | localMax>validIdx(2)) = [];
        %localMax
        for i = 1:length(localMax)
            Idx = localMax(i);
            Idx1 = Idx-epochlength/2/p.dt+1;
            Idx2 = Idx+epochlength/2/p.dt-1;
            tempEpoch  = [tempEpoch; seedtemp(Idx1:Idx2)];
            tempEpochr = [tempEpochr; rivaltemp(Idx1:Idx2)];
        end
        clear localMax;
    end
end
% plot(tempEpoch'); hold on;
% plot(mean(tempEpoch),'LineWidth',1.5);
% plot(mean(tempEpochr),'k','LineWidth',1.5);
% hold off;
end
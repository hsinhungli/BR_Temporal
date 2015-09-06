function p = getIndex(p,smooth,epochlength,filter_std)

p.epochlength = epochlength;
p.filter_std = filter_std;

%% Winner take all Index
if ismember(p.cond,[3 4]) %Monocular Plaid
    data1 = squeeze(p.r{3}(1,:));
    data2 = squeeze(p.r{3}(2,:));
    %data1 = squeeze(p.r{1}(1,:));
    %data2 = squeeze(p.r{1}(2,:));
else
    data1 = squeeze(p.r{3}(1,:));
    data2 = squeeze(p.r{3}(2,:));
    %data1 = squeeze(p.r{1}(1,:));
    %data2 = squeeze(p.r{2}(2,:));
end

temp1 = data1(p.tlist>200);
temp2 = data2(p.tlist>200);
p.Idx.corr = corr(temp1',temp2');
p.Idx.mean = mean([temp1 temp2]);
p.Idx.wta  = nanmean(abs(temp1-temp2) ./ (temp1+temp2));
p.Idx.diff = nanmean(abs(temp1-temp2));

p.ratio = [temp1(temp1>temp2)./temp2(temp1>temp2) temp2(temp1<temp2)./temp1(temp1<temp2)];
p.ratio = min(p.ratio,10);
p.Idx.ratio = nanmean(p.ratio);

%% get raw Dominance duration
durationDist_r = [];
for iter = 1:2
    if iter==1
        phaseIdx  = data1>data2;
    elseif iter==2
        phaseIdx  = data1<data2;
    end
    
    reversalIdx   = diff([0 phaseIdx]);
    onsetIdx      = find(reversalIdx==1);
    reversalIdx   = diff([phaseIdx 0]);
    offsetIdx     = find(reversalIdx==-1);
    phaseduration = (offsetIdx - onsetIdx)*p.dt;
    domD_r(iter)   = mean(phaseduration);
    durationDist_r = [durationDist_r phaseduration];
end
p.Idx.domD_r = domD_r/1000;
p.durationDist_r = durationDist_r;
p.Idx.cv_r   = std(p.durationDist_r) / mean(p.durationDist_r);

if length(unique(phaseIdx)) == 1
    p.Idx.wtaflag_r = 1;
else
    p.Idx.wtaflag_r = 0;
end

%% Rivalry Index and Dominance duration
if smooth == 1
    [tempEpoch,tempEpochr,domD, durationDist, phaseIdx] = getEpoch(p,data1,data2,epochlength,filter_std);
    p.aSignal = mean(tempEpoch,1);
    p.rSignal = mean(tempEpochr,1);
    
    p.Idx_rivalry  = abs(max(p.rSignal)-min(p.rSignal))/abs(max(p.aSignal)-min(p.aSignal));
    p.Idx_phase_s  = phaseIdx;
    p.Idx_domD_s   = domD/1000;
    p.Idx_durationDist_s = durationDist/1000;
    p.Idx_cv_s     = std(p.Idx_durationDist_s) / mean(p.Idx_durationDist_s);
    
    %p.aEpoch       = tempEpoch;
    %p.rEpoch       = tempEpochr;
    
    if length(unique(phaseIdx)) == 1
        p.Idx_wtaflag_s = 1;
    else
        p.Idx_wtaflag_s = 0;
    end
end

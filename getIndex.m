function p = getIndex(p)

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
p.Idx_corr = corr(temp1',temp2');
p.Idx_mean = mean([temp1 temp2]);
p.Idx_wta  = nanmean(abs(temp1-temp2) ./ (temp1+temp2));
p.Idx_diff = nanmean(abs(temp1-temp2));

p.ratio = [temp1(temp1>temp2)./temp2(temp1>temp2) temp2(temp1<temp2)./temp1(temp1<temp2)];
p.ratio = min(p.ratio,10);
p.Idx_ratio = nanmean(p.ratio);
%% Rivalry Index and Dominance duration
[tempEpoch,tempEpochr,domD, durationDist, phaseIdx] = getEpoch(p,data1,data2,p.epochlength,p.filter_std);
p.aSignal = mean(tempEpoch,1);
p.rSignal = mean(tempEpochr,1);

p.Idx_rivalry  = abs(max(p.rSignal)-min(p.rSignal))/abs(max(p.aSignal)-min(p.aSignal));
p.Idx_domD     = domD/1000;
p.durationDist = durationDist/1000;
p.phaseIdx     = phaseIdx;
p.Idx_cv       = std(p.durationDist) / mean(p.durationDist);
p.aEpoch       = tempEpoch;
p.rEpoch       = tempEpochr;

if length(unique(p.phaseIdx)) == 1
   p.wta = 1;
else
    p.wta = 0;
end


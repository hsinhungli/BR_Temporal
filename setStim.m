function p = setStim(cond,p)

switch cond
    case {1,2} %BR
        timeSeriesL = ones([1 p.nt]);
        timeSeriesR = ones([1 p.nt]);
        stimL = [1 0]';
        stimR = [0 1]';
        p.stimL = kron(timeSeriesL, stimL);
        p.stimR = kron(timeSeriesR, stimR);
    case {3,4} %SR
        p.timeSeriesL = ones([1 p.nt]);
        p.timeSeriesR = ones([1 p.nt]);
        p.swapIdx = mod(floor(p.tlist/300),2)+1;
        p.flickrIdx = mod(floor(p.tlist/30),2);
    case {5,6} %MP
        timeSeriesL = ones([1 p.nt]);
        timeSeriesR = ones([1 p.nt]);
        stimL = [1 1]';
        stimR = [0 0]';
        p.stimL = kron(timeSeriesL, stimL);
        p.stimR = kron(timeSeriesR, stimR);
    case {7,8} %RP
        %         if p_pool{1}.r{3}(IdxL(1),IdxL(2),p.nt) == 0
        %             Idx = p.n{1}(IdxL(1),IdxL(2),:) >= p.n{2}(IdxR(1),IdxR(2),:);
        %         else
        %             Idx = p_pool{1}.r{3}(IdxL(1),IdxL(2),:) >= p_pool{1}.r{3}(IdxR(1),IdxR(2),:);
        %         end
        %         p.timeSeriesL = Idx;
        %         p.timeSeriesR = ~Idx;
end
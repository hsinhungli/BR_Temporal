function p = setModelPar(cond,p)
% [IdxL] = [find(p.theta==120) find(p.x==p.stimCenterL)];
% [IdxR] = [find(p.theta==30) find(p.x==p.stimCenterR)];

switch cond
    case 1 %Dichoptic Gratings + Attention
        %p.aexo          = 1.3;
        p.aend          = 0;
        p.changeAtt     = 1;
    case 2 %Dichoptic Gratings + noAttention
        %p.aexo          = 1.3;
        p.aend          = 0;
        p.changeAtt     = 0;
    case 5 %Plaid + Attention
        %p.aexo          = 1.3;
        p.aend          = 0;
        p.changeAtt     = 1;
    case 6 %Plaid + noAttention
        %p.aexo          = 1.3;
        p.aend          = 0;
        p.changeAtt     = 0;
        
    case 3 %Swap + Attention
        p.aend          = 0;
        p.changeAtt     = 1;
end
%end
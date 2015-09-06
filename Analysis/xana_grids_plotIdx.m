datafolder = '/Users/hhli/Google Drive/PROJECTS_CURRENT/Pro_BR_Temporal/simRivalry_2nd/Data/';
load(sprintf('%s/par_%s.mat',datafolder,'471303'));
load('../HPC/grid.mat')
%%

%fix parameter
condIdx  = par.cond == 1;
noiseIdx = par.noiseamp == .05;
oppIdx   = true;
aTIdx    = par.aT == .1;
aRIdx    = par.aR == 1;
aMIdx    = true;
fixIdx   = condIdx & noiseIdx & oppIdx & aTIdx & aRIdx & aMIdx;

w_opp_level = unique(par.w_opp);
aM_level    = unique(par.aM);
pargrid = [];
for i = 1:length(w_opp_level);
    w_opp = w_opp_level(i);
    for j = 1:length(aM_level);
        aM = aM_level(j);
        tempIdx = par.aM==aM & par.w_opp==w_opp & fixIdx;
        pargrid.mean(i,j)      = par.Idx(tempIdx).mean;
        pargrid.wta(i,j)       = par.Idx(tempIdx).wta;
        pargrid.diff(i,j)      = par.Idx(tempIdx).diff;
        pargrid.ratio(i,j)     = par.Idx(tempIdx).ratio;
        pargrid.domD_r(i,j)    = mean(par.Idx(tempIdx).domD_r);
        pargrid.cv_r(i,j)      = par.Idx(tempIdx).cv_r;
        pargrid.wtaflag_R(i,j) = par.Idx(tempIdx).wtaflag_r;
        pargrid.fileIdx(i,j)   = par.fileIdx(tempIdx);
    end
end
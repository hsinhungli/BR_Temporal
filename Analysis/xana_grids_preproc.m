datafolder = '/Users/hhli/Google Drive/PROJECTS_CURRENT/Pro_BR_Temporal/simRivalry_2nd/Data/';
gridname = '/Users/hhli/Google Drive/PROJECTS_CURRENT/Pro_BR_Temporal/simRivalry_2nd/HPC/grid.mat';
load(gridname);

% set parameters
nfile = 576;
par.smooth      = 0;
par.epochlength = 6000;
par.filter_std  = 200;
par.grid     = grid;
par.cond     = [];
par.noiseamp = [];
par.w_opp    = [];
par.aT = [];
par.aR = [];
par.aM = [];

%cond contrast contrast tau_att noiseamp w_opp aT aR aM

% Loop through
count = 0;
for fileIdx = 1:576;
    counterdisp(fileIdx);
    filename = sprintf('%s/cond_1234_%04d.mat',datafolder,fileIdx);
    load(filename)
    for i = 1:numel(p_pool)
        count = count+1;
        temp  = getIndex(p_pool(i),par.smooth, par.epochlength, par.filter_std);
        par.fileIdx(count)  = fileIdx;
        par.cond(count)     = temp.cond;
        par.noiseamp(count) = temp.d_noiseamp(1);
        par.w_opp(count)    = temp.w_opp;
        par.aT(count)       = temp.aT;
        par.aR(count)       = temp.aR;
        par.aM(count)       = temp.aM;
        par.Idx(count)      = temp.Idx;
    end
end

filename = sprintf('%s/par_%s.mat',datafolder,datestr(now,'MMHHDD'));
save(filename,'par')
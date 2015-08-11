function p = setParameters

%% Temporal Parameters
p.tau             = [20 20 20 20 20];         %time constant (ms)
p.tau_a           = [1000 1000 800 300 300];  %time constant adaptation (ms)
p.tau_att         = 100;                       %time constant attention (ms)
p.tau_inh         = 10;
p.dt              = 2;                        %time-step (ms)
p.T               = 10000;                    %duration (ms)
p.d_noisefilter_t = 80;                      %noise at drive (ms)
p.d_noiseamp      = [0.2 0.2 0 0.2 0.2];
p.f_noisefilter_t = 100;                      %noise at firingrate (ms)
p.f_noiseamp      = [0 0 0 0 0];
p.m_noisefilter_t = 50;                      %measurement noise
p.m_noiseamp      = [.2 .2 .1 .1 .1]*0;        

%% Spatial & Neuronal Parameters
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;
p.x             = 0;                          %Sampling of space
p.nx            = numel(p.x);
p.ntheta        = 2;                          %Sampling of orientation
p.baselineMod   = [0 0 0 0 0];
p.baselineAtt   = 1;
p.p             = [2 2 2 2 2];
p.sigma         = 10.^[-2 -2 0 -2 -2];        %semisaturation constant
p.wa            = [0 0 0 0 0];                %weights of self-adaptation
p.w_int         = 1;                          %weights of interocular normalization
p.w_opp         = 5;                          %weights of feedback
p.fbtype        = 'divisive';
p.nLayers       = 5;                          %set to 3 for conventional model, 5 for opponency model

%% Attention
p.aT            = .3;                        %Threshold of attention function
p.aR            = 10;                         %Slope of attention function
p.aM            = 1.7;
end
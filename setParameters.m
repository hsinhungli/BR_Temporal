function p = setParameters

%% Temporal Parameters

%Expeirment parameters
p.dt            = 1;                        %time-step (ms)
p.T             = 30*1000;                  %duration (ms)
p.nt            = p.T/p.dt+1;
p.tlist         = 0:p.dt:p.T;

%Temporal dynamic of neurons
p.tau             = [10 10 10 10 10];         %time constant (ms)
p.tau_a           = [99 99 99 99 99]; %time constant adaptation (ms)
p.tau_att         = 200;                      %time constant attention (ms)
p.tau_inh         = 5;                        %time constant opponency fb (ms)
p.tau_n           = 100;                      %time constant noise (ms)
p.d_noiseamp      = [0.05 0.05 0 0 0];
% p.d_noisefilter_t = 99;                       %noise at drive (ms)
% p.f_noisefilter_t = 99;                      %noise at firingrate (ms)
% p.f_noiseamp      = [0 0 0 0 0];
% p.m_noisefilter_t = 99;                       %measurement noise
% p.m_noiseamp      = [0 0 0 0 0];      

%% Spatial & Neuronal Parameters
p.x             = 0;                %Sampling of space
p.nx            = numel(p.x);
p.ntheta        = 2;                %Sampling of orientation
p.baselineMod   = [0 0 0 0 0];
p.baselineAtt   = 1;
p.p             = [2 2 2 2 2];
p.sigma         = [.1 .1 .5 .5 .5]; %semisaturation constant
p.wa            = [0 0 0 0 0];      %weights of self-adaptation
p.w_int         = 1;                %weights of interocular normalization
p.w_opp         = .75;               %weights of feedback
p.fbtype        = 's';
p.nLayers       = 5;                %set to 3 for conventional model, 5 for opponency model

%% Attention
p.aT            = 0.75; %Threshold of attention function
p.aR            = 5;  %Slope of attention function
p.aM            = .5;

%% Parameters for index computation
p.epochlength = 6000;
p.filter_std  = 600;
end
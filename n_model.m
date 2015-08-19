function [p] = n_model(p, cond)
%This function is called by n_runModel.m
%The word 'layer' is used in the following sense:
%Layer 1 = Left monocular neurons
%Layer 2 = Right monocular neurons
%Layer 3 = Summation neurons
%Layer 4 = Left-Right opponency neurons
%Layer 5 = Right-Left opponency neurons

switch p.fbtype %This set the form of the inhibitory feedback from opponency layer
    case 'subtraction_e'
        p.w_opp_se = p.w_opp;
        p.w_opp_d  = p.w_opp*0;
        p.w_opp_g  = p.w_opp*0;
    case 'divisive'
        p.w_opp_se = p.w_opp*0;
        p.w_opp_d  = p.w_opp;
        p.w_opp_g  = p.w_opp*0;
    case 'gain'
        p.w_opp_se = p.w_opp*0;
        p.w_opp_d  = p.w_opp*0;
        p.w_opp_g  = p.w_opp;
end

idx = 1; %corresponds to t=0
for t = p.dt:p.dt:p.T
    counterdisp(t);
    idx = idx+1;
    %% Computing the responses of Monocular layers
    for lay = [1 2]
        
        %defining inputs (stimulus)
        inp = p.i{lay}(:,idx);
        
        %updating noise
        p.d_n{lay}(:,idx) = p.d_n{lay}(:,idx-1) + (p.dt/p.tau_n)*...
            (-p.d_n{lay}(:,idx-1) + randn(p.ntheta,p.nx)*p.d_noiseamp(lay)*sqrt(p.tau_n*2));
        
        %updating drives
        drive = halfExp(inp,p.p(lay)) .* p.att(:,idx-1) - p.inh{lay}(:,idx-1)*p.w_opp_se + p.d_n{lay}(:,idx); 
        %drive : stimulus_contrast * attention - subtractive_inhibition + noise
        p.d{lay}(:,idx) = halfExp(drive, 1); %rectification
        
    end
    for lay = [1 2] %monocular layers
        
        %defining normalization pool for each layer
        if lay ==1 
            pool      = zeros(p.ntheta,2);
            pool(:,1) = p.d{1}(:,idx)*1;
            pool(:,2) = p.d{2}(:,idx)*p.w_int; %Interocular normalization
            sigma     = p.sigma(lay);
        elseif lay ==2
            pool      = zeros(p.ntheta,2);
            pool(:,1) = p.d{1}(:,idx)*p.w_int; %Interocular normalization
            pool(:,2) = p.d{2}(:,idx)*1;
            sigma     = p.sigma(lay);
        end
        
        %Compute Suppressive Drive
        p.s{lay}(:,idx) = sum(pool(:));
        
        %Normalization (p.w_opp_g is used when modeling feedback as gain change)
        g = (1+p.inh{lay}(:,idx-1)*p.w_opp_g);
        p.s{lay}(:,idx) = p.s{lay}(:,idx).*g;
        p.f{lay}(:,idx) = p.d{lay}(:,idx) ./ (p.s{lay}(:,idx) + p.w_opp_d*p.inh{lay}(:,idx-1) ...
            + halfExp(p.a{lay}(:,idx-1)+sigma,p.p(lay))) + p.baselineMod(lay); %Adaptation, p.a, is implemented as Wilson 2003 here.
        %p.f{lay}(:,idx) = halfExp(p.f{lay}(:,idx)+ p.f_n{lay}(:,idx),1); %Add niose at the firing rate
        
        %update firing rates
        p.r{lay}(:,idx) = p.r{lay}(:,idx-1) + (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %record change of firing rates
        p.dr{lay}(:,idx) = (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %update adaptation
        p.a{lay}(:,idx) = p.a{lay}(:,idx-1) + (p.dt/p.tau_a(lay))*(-p.a{lay}(:,idx-1) + p.r{lay}(:,idx)*p.wa(lay));
        
    end
    
    %A potential way to implement eye-based suppression (similar to opponency layer?)
    %for lay = [1 2]
    %    if lay == 1
    %        p.inh{lay}(:,idx) = p.inh{lay}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{lay}(:,idx-1) + sum(p.r{2}(:,idx)));
    %    elseif lay == 2
    %        p.inh{lay}(:,idx) = p.inh{lay}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{lay}(:,idx-1) + sum(p.r{1}(:,idx)));
    %    end
    %end
    
    %% Computing the responses of Binocular layers
    for lay = 3:p.nLayers
        
        %defining inputs (stimulus)
        if lay == 3 %summation layer
            inp = p.r{1}(:,idx) + p.r{2}(:,idx);
        elseif lay == 4 %opponency layer (left-right)
            inp = p.r{1}(:,idx) - p.r{2}(:,idx);
        elseif lay == 5 %opponency layer (right-left)
            inp = p.r{2}(:,idx) - p.r{1}(:,idx);
        end
        
        %updating drives
        drive = halfExp(inp,p.p(lay)) .* p.att(:,idx-1);% + p.d_n{lay}(:,idx); 
        p.d{lay}(:,idx) = halfExp(drive, 1);
        
    end
    for lay = 3:p.nLayers
        
        %defining normalization pool for each layer
        if lay == 3 %summation layer
            pool = p.d{3}(:,idx);
            sigma = p.sigma(lay);
        elseif lay >= 4 %opponency layer
            pool = zeros(p.ntheta,2);
            pool(:,1) = p.d{4}(:,idx);
            pool(:,2) = p.d{5}(:,idx);
            sigma = p.sigma(lay);
        end
        
        %Compute Suppressive Drive
        p.s{lay}(:,idx) = sum(pool(:));
        
        %Normalization
        p.f{lay}(:,idx) = p.d{lay}(:,idx) ./ (p.s{lay}(:,idx) + halfExp(p.a{lay}(:,idx-1)+sigma,p.p(lay))) + p.baselineMod(lay);
        %p.f{lay}(:,idx) = halfExp(p.f{lay}(:,idx)+ p.f_n{lay}(:,idx), 1); %Add niose at the firing rate
        %p.f{lay}(:,idx) = poissrnd(p.f{lay}(:,idx));
        
        %update firing rates
        p.r{lay}(:,idx) = p.r{lay}(:,idx-1) + (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %compute change of firing rates
        p.dr{lay}(:,idx) = (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %update adaptation
        p.a{lay}(:,idx) = p.a{lay}(:,idx-1) + (p.dt/p.tau_a(lay))*(-p.a{lay}(:,idx-1) + p.r{lay}(:,idx)*p.wa(lay));
        
        %update negative feedback
        if lay == 4
           Inh = sum(p.r{lay}(:,idx));
           p.inh{2}(:,idx) = p.inh{2}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{2}(:,idx-1) + Inh); %Inhibition sent to layer one
        elseif lay == 5
           Inh = sum(p.r{lay}(:,idx));
           p.inh{1}(:,idx) = p.inh{1}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{1}(:,idx-1) + Inh); %Inhibition sent to layer two
        end

    end
    
    %% Update attention map
    if p.changeAtt == 1 %Full Attention, No endo implemented yet, but exo follow stronger stimulus
        
        attnGain = nan(p.ntheta,1);
        %attnGain(1) = 2 ./ (1 + exp(-(p.r{3}(1,idx-1)-p.r{3}(2,idx-1))*p.aR + p.aT)); % + p.baselineAtt;
        %attnGain(2) = 2 ./ (1 + exp(-(p.r{3}(2,idx-1)-p.r{3}(1,idx-1))*p.aR + p.aT)); % + p.baselineAtt;
        if ismember(cond,[1 2 3 4 5])
            diff1 = p.r{3}(1,idx-1)-p.r{3}(2,idx-1);
            diff2 = p.r{3}(2,idx-1)-p.r{3}(1,idx-1);
            attnGain(1) = halfExp(1 + p.aM*(sigmoid(diff1,p.aT,p.aR) - sigmoid(diff2,p.aT,p.aR)),1);
            attnGain(2) = halfExp(1 + p.aM*(sigmoid(diff2,p.aT,p.aR) - sigmoid(diff1,p.aT,p.aR)),1);
            %attnGain(1) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
            %attnGain(2) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
        %elseif ismember(cond, [3 4])
            %diff = p.r{1}(1,idx-1)-p.r{1}(2,idx-1);
            %attnGain(1) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
            %diff = p.r{1}(2,idx-1)-p.r{1}(1,idx-1);
            %attnGain(2) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
            %attnGain(1) = 1 + p.aM ./ (1 + exp(-(p.r{1}(1,idx-1)-p.r{1}(2,idx-1))*p.aR + p.aT));
            %attnGain(2) = 1 + p.aM ./ (1 + exp(-(p.r{2}(2,idx-1)-p.r{1}(1,idx-1))*p.aR + p.aT));
        end
        p.attTrace(:,idx) = attnGain;
    elseif p.changeAtt == 0;
        attnGain = ones(size(p.att(:,idx-1)));
    end
    
%     if p.changeAtt == 1
%         if ismember(cond,[1 2])
%             r1 = p.r{1}(1,idx-1); r2 = p.r{2}(2,idx-1);
%         elseif ismember(cond, [5 6])
%             r1 = p.r{1}(1,idx-1); r2 = p.r{1}(2,idx-1);
%         end
%         attnGain(1) = halfExp(1 + r1^p.an - r2^p.an) / (r1^p.an+r2^p.an+p.asigma);
%         attnGain(2) = halfExp(1 + r2^p.an - r1^p.an) / (r1^p.an+r2^p.an+p.asigma);
%     else
%         attnGain = ones(size(p.att(:,idx-1)));
%     end
    
    p.att(:,idx) = p.att(:,idx-1) + (p.dt/p.tau_att)*(-p.att(:,idx-1) + attnGain);
end

% for lay = 1:p.nLayers %Add measurement noise when simulating EEG/MEG experiment
%     p.r{lay} = p.r{lay} + p.m_n{lay};
% end

function y = sigmoid(x,theta, k)
    y = 1./(1+exp(-k*(x-theta)));
end
end
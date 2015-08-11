function [p] = n_model(p, cond)
%This function is called by n_runModel.m
%The word 'layer' is used in the following sense:
%Layer 1 = Left monocular neurons
%Layer 2 = Right monocular neurons
%Layer 3 = Summation neurons
%Layer 4 = Left-Right opponency neurons
%Layer 5 = Right-Left opponency neurons
%A and B refer to the two stimulus orientations.
%
%If you use this code, please cite
%Said and Heeger (2013) A model of binocular rivalry and cross-orientation
%suppression. PLOS Computational Biology.

switch p.fbtype
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

count = 0;
idx = 1; %corresponds to t=0
for t = p.dt:p.dt:p.T
    counterdisp(t);
    idx = idx+1;
    %% Computing the responses of Monocular layers
    for lay = [1 2]
        
        %defining inputs (stimulus and recurrent connections)
        inp = p.i{lay}(:,idx);
        
        %updating drives
        rawinp = halfExp(inp,p.p(lay)) - p.inh{lay}(:,idx-1)*p.w_opp_se;
        inp    = rawinp.*p.att(:,idx-1) + p.d_n{lay}(:,idx) + p.baselineMod(lay);
        p.d{lay}(:,idx) = halfExp(inp, 1);
        
    end
    for lay = [1 2]
        %defining normalization pool for each layer
        if lay ==1 %monocular
            pool      = zeros(p.ntheta,2);
            pool(:,1) = p.d{1}(:,idx)*1;
            pool(:,2) = p.d{2}(:,idx)*p.w_int;
            sigma     = p.sigma(lay);
        elseif lay ==2 %monocular
            pool      = zeros(p.ntheta,2);
            pool(:,1) = p.d{1}(:,idx)*p.w_int;
            pool(:,2) = p.d{2}(:,idx)*1;
            sigma     = p.sigma(lay);
        end
        
        %Compute Suppressive Drive
        p.s{lay}(:,idx) = sum(pool(:));
        
        %Normalization (p.w_opp_g is used when modeling feedback as gain change)
        g = (1+p.inh{lay}(:,idx-1)*p.w_opp_g);
        p.s{lay}(:,idx) = p.s{lay}(:,idx).*g;
        p.f{lay}(:,idx) = p.d{lay}(:,idx) ./ (p.s{lay}(:,idx) + p.w_opp_d*p.inh{lay}(:,idx-1) + halfExp(p.a{lay}(:,idx-1),p.p(lay)) + halfExp(sigma,p.p(lay)));
        p.f{lay}(:,idx) = halfExp(p.f{lay}(:,idx)+ p.f_n{lay}(:,idx),1); %Add niose at the firing rate
        
        %update firing rates
        p.r{lay}(:,idx) = p.r{lay}(:,idx-1) + (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %compute change of firing rates
        p.dr{lay}(:,idx) = (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %update adaptation
        p.a{lay}(:,idx) = p.a{lay}(:,idx-1) + (p.dt/p.tau_a(lay))*(-p.a{lay}(:,idx-1) + p.r{lay}(:,idx)*p.wa(lay));
        
        %update feedback
    end
    for lay = [1 2]
        if lay == 1
            p.inh{lay}(:,idx) = p.inh{lay}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{lay}(:,idx-1) + sum(p.r{2}(:,idx)));
        elseif lay == 2
            p.inh{lay}(:,idx) = p.inh{lay}(:,idx-1) + (p.dt/p.tau_inh)*(-p.inh{lay}(:,idx-1) + sum(p.r{1}(:,idx)));
        end
    end
    %% Computing the responses of Binocular layers
    for lay = 3:p.nLayers
        if lay == 3 %summation layer
            inp = p.r{1}(:,idx) + p.r{2}(:,idx);
        elseif lay == 4 %opponency layer (left-right)
            inp = p.r{1}(:,idx) - p.r{2}(:,idx);
        elseif lay == 5 %opponency layer (right-left)
            inp = p.r{2}(:,idx) - p.r{1}(:,idx);
        end
        %updating drives
        rawinp = halfExp(inp,p.p(lay));
        inp    = rawinp.*p.att(:,idx-1) + p.d_n{lay}(:,idx) + p.baselineMod(lay);
        p.d{lay}(:,idx) = halfExp(inp, 1);
    end
    for lay = 3:p.nLayers
        if lay == 3 %summation
            pool = p.d{3}(:,idx);
            sigma = p.sigma(lay);
        elseif lay >= 4 %opponency
            pool = zeros(p.ntheta,2);
            pool(:,1) = p.d{4}(:,idx);
            pool(:,2) = p.d{5}(:,idx);
            sigma = p.sigma(lay);
        end
        
        p.s{lay}(:,idx) = sum(pool(:));
        
        %normalization
        p.f{lay}(:,idx) = p.d{lay}(:,idx) ./ (p.s{lay}(:,idx) + halfExp(p.a{lay}(:,idx-1),p.p(lay)) + halfExp(sigma,p.p(lay)));
        p.f{lay}(:,idx) = halfExp(p.f{lay}(:,idx)+ p.f_n{lay}(:,idx), 1); %Add niose at the firing rate
        %p.f{lay}(:,idx) = poissrnd(p.f{lay}(:,idx));
        
        %update firing rates
        p.r{lay}(:,idx) = p.r{lay}(:,idx-1) + (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %compute change of firing rates
        p.dr{lay}(:,idx) = (p.dt/p.tau(lay))*(-p.r{lay}(:,idx-1) + p.f{lay}(:,idx));
        
        %update adaptation
        p.a{lay}(:,idx) = p.a{lay}(:,idx-1) + (p.dt/p.tau_a(lay))*(-p.a{lay}(:,idx-1) + p.r{lay}(:,idx)*p.wa(lay));
        
        %update negative feedback
        if lay == 4
            temp = mean(p.r{lay}(:,idx));
            p.inh{2}(:,idx) = repmat(temp,p.ntheta,1);
        elseif lay == 5
            temp = mean(p.r{lay}(:,idx));
            p.inh{1}(:,idx) = repmat(temp,p.ntheta,1);
        end
    end
    
    %% Update attention map
    %     if p.changeAtt == 1 %Full Attention, No Endatt, but exo follow stimulus
    %
    %         attnGain = nan(p.ntheta,1);
    %         %         attnGain(1) = 2 ./ (1 + exp(-(p.r{3}(1,idx-1)-p.r{3}(2,idx-1))*p.aR + p.aT)); % + p.baselineAtt;
    %         %         attnGain(2) = 2 ./ (1 + exp(-(p.r{3}(2,idx-1)-p.r{3}(1,idx-1))*p.aR + p.aT)); % + p.baselineAtt;
    %         if ismember(cond,[1 2])
    %             diff = p.r{1}(1,idx-1)-p.r{2}(2,idx-1);
    %             attnGain(1) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
    %             diff = p.r{2}(2,idx-1)-p.r{1}(1,idx-1);
    %             attnGain(2) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
    %         elseif ismember(cond, [5 6])
    %             diff = p.r{1}(1,idx-1)-p.r{1}(2,idx-1);
    %             attnGain(1) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
    %             diff = p.r{1}(2,idx-1)-p.r{1}(1,idx-1);
    %             attnGain(2) = 1+ p.aM ./ (1 + exp(-(diff-p.aT)*p.aR));
    %             %attnGain(1) = 1 + p.aM ./ (1 + exp(-(p.r{1}(1,idx-1)-p.r{1}(2,idx-1))*p.aR + p.aT));
    %             %attnGain(2) = 1 + p.aM ./ (1 + exp(-(p.r{2}(2,idx-1)-p.r{1}(1,idx-1))*p.aR + p.aT));
    %         end
    %         p.attTrace(:,idx) = attnGain;
    %
    %     elseif p.changeAtt == 0;
    %         attnGain = ones(size(p.att(:,idx-1)));
    %     end
    
    if p.changeAtt == 1
        if ismember(cond,[1 2])
            r1 = p.r{1}(1,idx-1); r2 = p.r{2}(2,idx-1);
        elseif ismember(cond, [5 6])
            r1 = p.r{1}(1,idx-1); r2 = p.r{1}(2,idx-1);
        end
        attnGain(1) = halfExp(1 + r1^p.an - r2^p.an) / (r1^p.an+r2^p.an+p.asigma);
        attnGain(2) = halfExp(1 + r2^p.an - r1^p.an) / (r1^p.an+r2^p.an+p.asigma);
    else
        attnGain = ones(size(p.att(:,idx-1)));
    end
    p.att(:,idx) = p.att(:,idx-1) + (p.dt/p.tau_att)*(-p.att(:,idx-1) + attnGain);
end

for lay = 1:p.nLayers
    p.r{lay} = p.r{lay} + p.m_n{lay};
end

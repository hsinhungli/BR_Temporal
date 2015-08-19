aT            = .5;                    %Threshold of attention function
aR            = 5;                    %Slope of attention function
aM            = 2;
R1R2          = (-1:.01:1);

% attR1 = R1^n / (R1^n+R2^n)+sigma;
% attR2 = R2^n / (R1^n+R2^n)+sigma;
inpR1 = R1R2;
inpR2 = fliplr(R1R2);

attR1  = halfExp(1+ aM *(1./(1 + exp(-(inpR1-aT)*aR)) - 1./(1 + exp(-(inpR2-aT)*aR))),1);
attR2  = halfExp(1+ aM *(1./(1 + exp(-(inpR2-aT)*aR)) - 1./(1 + exp(-(inpR1-aT)*aR))),1);

figure;
plot(R1R2,attR1); hold on
plot(R1R2,attR2);
%plot(R1R2, fliplr(attR1)); hold on
%plot(R1R2,ones(size(R1R2)),'--')
ylim([0 3])
xlim([-1 1])
xlabel('R1-R2','FontSize',15)
ylabel('aGain','FontSize',15)
legend({'attention to ori1','attention to ori2'},'FontSize',16)
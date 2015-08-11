r1=.1; r2=.2;
an=1;
asigma=0;

attnGain(1) = (1 + r1^an - r2^an);
attnGain(2) = (1 + r2^an - r1^an);

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
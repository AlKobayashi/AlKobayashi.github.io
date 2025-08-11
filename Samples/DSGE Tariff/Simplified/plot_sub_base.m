function plot_sub_base(opt,zero,eff,T)

brown = [146 36 40]./255;
navy_blue = [0 0 128]./255;
Tvec  = (0:1:T-1);
width = 2.;
TX = 50;


i=1;
subplot(3,3,i)
hold on 
title('ch')
plot(Tvec,(opt.ch_t./eff.ch_t-1)*100,'LineWidth',width,'Color',navy_blue);
plot(Tvec,(zero.ch_t./eff.ch_t-1)*100,'-.','LineWidth',width,'Color',brown);
xticks((0:10:T))
ylabel('\%','Interpreter','latex')
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i) 
hold on
title('cf')
plot(Tvec,(opt.cf_t./eff.cf_t-1)*100,'LineWidth',width,'Color',navy_blue);
plot(Tvec,(zero.cf_t./eff.cf_t-1)*100,'-.','LineWidth',width,'Color',brown);
xticks((0:10:T))
ylabel('\%','Interpreter','latex')
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i) 
title('l')
hold on
plot(Tvec,(opt.l_t./eff.l_t-1)*100,'LineWidth',width,'Color',navy_blue);
plot(Tvec,(zero.l_t./eff.l_t-1)*100,'-.','LineWidth',width,'Color',brown);
plot([0 T],[0 0],':k','LineWidth',1)
xticks((0:10:T))
ylabel('\%','Interpreter','latex')
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i) 
title('inflation')
hold on
plot(Tvec,((1+opt.pi_t).^4-1)*100,'LineWidth',width,'Color',navy_blue);
plot(Tvec,zeros(T,1),'-.','LineWidth',width,'Color',brown);
xticks((0:10:T))
ylabel('\%','Interpreter','latex')
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i) 
title('P')
hold on
plot(Tvec,opt.P_t,'LineWidth',width,'Color',navy_blue);
plot(Tvec,zero.P_t,'-.','LineWidth',width,'Color',brown);
plot([0 T],[eff.P_t(1) eff.P_t(1)],':k','LineWidth',1.5);
xticks((0:10:T))
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i) 
title('exchange rate')
hold on
plot(Tvec(1:end-1),(opt.pH_t(2:end)./opt.pH_t(1:end-1)-1)*100,'LineWidth',width,'Color',navy_blue);
plot(Tvec(1:end-1),(zero.pH_t(2:end)./zero.pH_t(1:end-1)-1)*100,'-.','LineWidth',width,'Color',brown);
xticks((0:10:T))
ylabel('\%','Interpreter','latex')
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i)
title('nfa')
hold on
plot(Tvec,opt.b_t(1:T)./opt.y_t,'LineWidth',width,'Color',navy_blue);
plot(Tvec,zero.b_t(1:T)./zero.y_t,'-.','LineWidth',width,'Color',brown);
xticks((0:10:T))
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i) 
title('tb')
hold on
plot(Tvec,(opt.tb_t)./opt.y_t*100,'LineWidth',width,'Color',navy_blue);
plot(Tvec,(zero.tb_t)./opt.y_t*100,'-.','LineWidth',width,'Color',brown);
xticks((0:10:T))
ylabel('\%','Interpreter','latex')
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


i=i+1; subplot(3,3,i)
title('labor wedge')
hold on
plot(Tvec,(opt.lw_t),'LineWidth',width,'Color',navy_blue);
plot(Tvec,(zero.lw_t),'-.','LineWidth',width,'Color',brown);
xticks((0:10:T))
set(gca,'Xlim',[0 TX])
set(gca,'TickLabelInterpreter','latex','FontSize',14)
box off


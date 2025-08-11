
brown = [146 36 40]./255;
purple = [107 76 154]./255;
navy_blue = [0 0 128]./255;
webgreen = [0.1 0.5 0.5];
olive = [128 128 0]./255;
blue = [0 0 255]./255;
red = [255 0 0]./255;
cyan = [0 255 255]./255;

color1{1} = webgreen;
color1{2} = blue;
color1{3} = navy_blue;
color1{4} = purple;
color1{5} = brown;
color1{6} = red;


xp = np;
xg = 2;
xs = 1;
xu =  1;
Tvec  = (0:1:T-1);



% inflation
figure(1);
for ip=1:np 
var_plot = squeeze(((1+pi_vec(:,ip,xg,xs,xu)).^4-1)*100);
h(ip) = plot(Tvec,var_plot,'--','color',color1{ip},'LineWidth',1);

hold on
filename{ip} = ['$\psi$ = ' num2str(psi_vec(ip))]
end
zz=axis; axis([zz(1) 30 zz(3) zz(4)])
xticks((0:10:30))
xlabel('quarters','Interpreter','latex')
ylabel('Inflation','Interpreter','latex')
lh = legend(h,filename,...
    'location','northeast','Interpreter','latex');
legend boxoff
set(gca,'TickLabelInterpreter','latex','FontSize',20)
box off



% inflation
figure(21);
for iu=1:nu
var_plot = squeeze(((1+pi_vec(:,xp,ng,xs,iu)).^4-1)*100);
h2(iu) = plot(Tvec,var_plot,'--','color',color1{iu},'LineWidth',1);
hold on
filename2{iu} = ['slopePC = ' num2str(slope_vec(iu))]
end
zz=axis; axis([zz(1) 30 zz(3) zz(4)])
xticks((0:10:30))
xlabel('quarters','Interpreter','latex')
ylabel('Inflation','Interpreter','latex')
lh = legend(h2,filename2,...
    'location','northeast','Interpreter','latex');
legend boxoff
set(gca,'TickLabelInterpreter','latex','FontSize',20)
box off


color1{1} = blue;
color1{2} = navy_blue;
color1{3} = purple;
color1{4} = brown;
color1{5} = red;



% inflation
FigCP = figure(3);
hold on
for ig=1:ng 
var_plot = squeeze(((1+pi_vec(:,xp,ig,xs,xu)).^4-1)*100);
h3(ig) = plot(Tvec,var_plot,'--','color',color1{ig},'LineWidth',1);

filename3{ig} = ['$\gamma$ = ' num2str(gamm_vec(ig))]
end
zz=axis; axis([zz(1) 30 zz(3) zz(4)])
xticks((0:10:30))
xlabel('quarters','Interpreter','latex')
ylabel('Inflation','Interpreter','latex')
lh = legend(h3,filename3,...
    'location','northeast','Interpreter','latex');
legend boxoff
set(gca,'TickLabelInterpreter','latex','FontSize',20)
box off


figure(311);
plot(psi_vec,squeeze(welf_gain_vec(:,xg,xs,xu)),'color',red,'LineWidth',1)
xlabel('$\psi$','Interpreter','latex')
ylabel('Welfare','Interpreter','latex')
set(gca,'TickLabelInterpreter','latex','FontSize',20)

figure(312);
plot(gamm_vec,squeeze(welf_gain_vec(xp,:,xs,xu)),'color',red,'LineWidth',1)
xlabel('$\gamma$','Interpreter','latex')
ylabel('Welfare','Interpreter','latex')
set(gca,'TickLabelInterpreter','latex','FontSize',20)

figure(313);
plot(slope_vec,squeeze(welf_gain_vec(xp,xg,xs,:)),'color',red,'LineWidth',1)
xlabel('slope PC','Interpreter','latex')
ylabel('Welfare policy','Interpreter','latex')
set(gca,'TickLabelInterpreter','latex','FontSize',20)




plot(psi_vec,squeeze(welf_loss_vec(:,xg,xs,xu)),'color',red,'LineWidth',1)
xlabel('$\psi$','Interpreter','latex')
ylabel('Welfare loss tariff','Interpreter','latex')
set(gca,'TickLabelInterpreter','latex','FontSize',20)


plot(gamm_vec,squeeze(welf_loss_vec(xp,:,xs,xu)),'color',red,'LineWidth',1)
xlabel('$\gamma$','Interpreter','latex')
ylabel('Welfare loss tariff','Interpreter','latex')
set(gca,'TickLabelInterpreter','latex','FontSize',20)


plot(slope_vec,squeeze(welf_loss_vec(xp,xg,xs,:)),'color',red,'LineWidth',1)
xlabel('slope PC','Interpreter','latex')
ylabel('Welfare loss','Interpreter','latex')
set(gca,'TickLabelInterpreter','latex','FontSize',20)

disp('ip ig is iu ')
%  psi = psi_vec(ip);
% gamma = gamm_vec(ig);
% sigma = sigma_vec(is); 
% slopePC = slope_vec(iu);

welf_gain_vec


for i=1:3
    figure
plot(squeeze(welf_gain_vec(i,1,1,:)))
xlabel('slope PC')
end

for i=1:3
    figure
plot(squeeze(welf_gain_vec(1,i,1,:)))
xlabel('slope PC')
end
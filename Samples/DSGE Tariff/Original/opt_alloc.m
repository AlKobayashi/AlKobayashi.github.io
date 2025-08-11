function F = opt_alloc(x,tau,b0,p,psi,Upsilon,vxphi,epsi,sigma,gamma,omega,beta,betavec,markup)

% 3*T+1 equations and variables
T            = length(betavec);

pi_t         = [x(1:T); x(T)];
l_t          = [x(T+1:2*T); x(2*T)];
eta_t        = [0; x(2*T+1:3*T)];  
ch           = x(3*T+1);

tau          = [tau; tau(end)]; 
theta_t      = ((omega+(1-omega).*((1-omega)./(omega.*p.*(1+tau))).^(gamma-1))).^(gamma/(gamma-1));

ch_t         = ch .*(theta_t./theta_t(1)).^(sigma/gamma-1); 
cf_t         = ch_t .*((1-omega)./(omega.*p.*(1+tau))).^gamma;
tb_t         = (1-Upsilon*vxphi/2.*pi_t.^2).*l_t - ch_t - p.*cf_t;
mc_t         = theta_t.^(1/sigma-1/gamma) .*ch_t.^(1/sigma) .*l_t.^psi; 

lhs_PC       = (1+pi_t(1:T)).*pi_t(1:T) ;
rhs_PC       = epsi/vxphi*(mc_t(1:T) -1/markup) + betavec.*l_t(2:end)./l_t(1:T).*(1+pi_t(2:end)).*pi_t(2:end);

aux_num      = (theta_t(1:T).^(sigma/gamma) .*theta_t(1).^(1-sigma/gamma)).^(1-1/sigma);
aux_num      = sum(betavec .* aux_num) +beta^T/(1-beta) *aux_num(end);
aux_den      = ch_t(1:T) + p.*cf_t(1:T);
aux_den      = sum(betavec.* aux_den) +beta^T/(1-beta) *aux_den(end);
mgcost_eta   = mc_t(1:T) .*l_t(1:T).*eta_t(2:end);
mgcost_eta   = sum(betavec.* mgcost_eta) +beta^T/(1-beta) *mgcost_eta(end);

lambda       = 1./aux_den .*(aux_num.*ch.^(1-1/sigma) -epsi/(vxphi*sigma).*mgcost_eta);
foc_pi       = Upsilon*pi_t(1:T) - (1+2*pi_t(1:T))./(lambda*vxphi) .*(eta_t(2:end)-eta_t(1:T));

aux_Dsdf     = (1+pi_t).*pi_t .*eta_t;
Dsdf_l       = betavec.*l_t(2:end)./l_t(1:T).*aux_Dsdf(2:end) - aux_Dsdf(1:T);
foc_l        = omega.*l_t(1:T).^psi + epsi/vxphi*psi.*mc_t(1:T) .*eta_t(2:end) -Dsdf_l...
                - (1-Upsilon*vxphi/2.* pi_t(1:T).^2).* lambda;

if Upsilon ==0
    F(1:T) = (1+pi_t(1:T)).*pi_t(1:T) - epsi/(vxphi*(1-beta)).*(mc_t(1:T) -1/markup);
else
    F(1:T) = lhs_PC-rhs_PC;
end
F(T+1:2*T)   = foc_pi;
F(2*T+1:3*T) = foc_l;
F(3*T+1)     = b0 + sum(betavec.*(tb_t(1:T))) + beta^T/(1-beta)*tb_t(end);

function F = zero_alloc(x,tau,b0,p,psi,sigma,gamma,omega,beta,betavec,markup)

% T+1 equations and variables
T     = length(betavec);
l_t   = x(1:T);
ch    = x(T+1);

Theta = ((omega+(1-omega).*((1-omega)./(omega.*p.*(1+tau))).^(gamma-1))).^(gamma/(gamma-1));

ch_t  = ch .* (Theta./Theta(1)).^(sigma/gamma-1);
cf_t  = ch_t .*((1-omega)./(omega.*p.*(1+tau))).^gamma;
y_t   = l_t;
tb_t  = y_t - ch_t - p.*cf_t;
mc_t  = Theta.^(1/sigma-1/gamma) .*ch_t.^(1/sigma).* l_t.^psi;

F(1:T) = mc_t - 1/markup;
F(T+1) = b0 + sum(betavec.*(tb_t(1:T))) + beta^T/(1-beta)*tb_t(end);

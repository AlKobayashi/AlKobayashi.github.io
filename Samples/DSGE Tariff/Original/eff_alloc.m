function F = eff_alloc(x,b0,p,psi,sigma,gamma,beta,markup,target_m)

l     = x(1);
ch    = x(2);
omega = x(3);

cf = ch .*((1-omega)./(omega.*p)).^gamma;
y  = l;
tb = y - ch - p *cf;

theta = ((omega+(1-omega).*((1-omega)./(omega.*p)).^(gamma-1))).^(gamma/(gamma-1));
mc = theta.^(1/sigma-1/gamma) .*ch.^(1/sigma).* l.^psi;

F(1) = mc - 1/markup;
F(2) = tb + (1-beta)*b0;
F(3) = p.*cf/y - target_m;
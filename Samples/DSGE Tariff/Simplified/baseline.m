%% Baseline
markup = 1;

% Efficient allocation
xguess = [1;1;0.8];
fun    = @(x) eff_alloc(x,b0,p,psi,sigma,gamma,beta,markup,target_m);
xstar  = fsolve(fun,xguess,options);

l_t   = xstar(1).*ones(T,1);
ch    = xstar(2);
pi_t  = zeros(T,1);
omega = xstar(3);

tau_zero = zeros(T,1);
eff = eqvar(ch,l_t,pi_t,tau_zero,b0,p,psi,Upsilon,vxphi,sigma,gamma,omega,beta,betavec);


% Zero inflation
xguess = [ones(T,1);1];
fun    = @(x) zero_alloc(x,tau,b0,p,psi,sigma,gamma,omega,beta,betavec,markup);
xstar  = fsolve(fun,xguess,options);

l_t    = xstar(1:T);
ch     = xstar(T+1);
pi_t   = zeros(T,1);

zero = eqvar(ch,l_t,pi_t,tau,b0,p,psi,Upsilon,vxphi,sigma,gamma,omega,beta,betavec);


% Optimal Allocation
x_guess   = [zero.pi_t; zero.l_t; zeros(T,1); zero.ch_t(1)];
fun = @(x) opt_alloc(x,tau,b0,p,psi,Upsilon,vxphi,epsi,sigma,gamma,omega,beta,betavec,markup);
[xstar,Fval,flag] = fsolve(fun,x_guess,options);

pi_t  = [xstar(1:T)];
l_t   = [xstar(T+1:2*T)];
eta_t = [xstar(2*T+1:3*T)];
ch    = xstar(3*T+1);

if max(abs(Fval))>0.0001
    disp('no convergence')
end
opt = eqvar(ch,l_t,pi_t,tau,b0,p,psi,Upsilon,vxphi,sigma,gamma,omega,beta,betavec);
opt.eta_t = eta_t;


%% Parameters and grid
a_e = 0.11; a_h = 0.03; % production rates
rho_0 = 0.04; % time preference
rho_e_d = 0.01;rho_h_d = 0.01;% death rates
rho_e = rho_0 + rho_e_d;      % expert 's discount rate
rho_h = rho_0 + rho_h_d;      % household 's discount rate
zeta = 0.05;                  % probability of becoming an expert 
delta = 0.05; sigma = 0.1;    % decay rate/volatility
phi = 10; alpha = 0.5;        % adjustment cost/equity constraint
          
N = 501;                          % grid size
eta = linspace(0.0001,0.999,N)';  % grid for \eta. eta is between 0 and 1.

%% Solution
% Solve for q(0), which is when eta is 0.
q0 = (1 + a_h*phi)/(1 + rho_h*phi);

%% Inner loop
[Q, SSQ, Kappa, Chi, Iota] = inner_loop_log(eta, q0, a_e, a_h, rho_e, rho_h,
sigma, phi, alpha);
S = (Chi - eta).*SSQ;              % \sigma_{\eta^e} -- arithmetic volatility of \eta^e
Sg_e = S./eta;                     % \sigma^{\eta^e} -- geometric volatility of \eta^e
Sg_h = -S./(1-eta);                % \sigma^{\eta^h} -- geometric volatility of \eta^h

VarS_e = Chi./eta.*SSQ;             % \varsigma^e -- experts' price of risk
VarS_h = (1-Chi)./(1-eta).*SSQ;     % \varsigma^h -- households' price of risk

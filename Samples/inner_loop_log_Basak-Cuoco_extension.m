function [Q, SSQ, Kappa, Chi, Iota] = inner_loop_log(eta, q0, a_e, a_h,rho_e, rho_h, sigma, phi, alpha)

N = length(eta);
deta = [eta(1); diff(eta)]; % imposes the correct grid step for numerical derivative at \eta^e = 0

% variables
Q = ones(N,1); % price of capital q
SSQ = zeros(N,1); % \sigma + \sigma^q
Kappa = zeros(N,1); % capital fraction of experts \kappa

Rho = eta*rho_e + (1-eta)*rho_h; % auxiliary variable: average consumption-to-networth ratio

% Initiate the loop
kappa=0;q_old=q0;q=q0;ssq=sigma;

% Iterate over eta
% At each step apply Newton's method to F(z) = 0 where z = [q, kappa, ssq]'
% Use chi = alpha*kappa
fori=1:N
% Compute F(z_{n-1})
F = [kappa*(a_e - a_h) + a_h - (q-1)/phi - q*Rho(i);
ssq*(q - (q - q_old)/deta(i) * (alpha*kappa - eta(i))) - sigma*q;
a_e - a_h - q*alpha*(alpha*kappa - eta(i))/(eta(i)*(1-eta(i)))*ssq

function var = eqvar(ch,l_t,pi_t,tau,b0,p,psi,Upsilon,vxphi,sigma,gamma,omega,beta,betavec)

% compute all the variables given ch and l
T = length(betavec);
theta_t = ((omega+(1-omega).*((1-omega)./(omega.*p.*(1+tau))).^(gamma-1))).^(gamma/(gamma-1)); % HANDY EXPRESSION obtained when combining static optimality with c_t bundle. (see handw. notes).

ch_t = ch .*(theta_t./theta_t(1)).^(sigma/gamma-1);          % EULER EQ. c_t^f. (see handw. notes).
cf_t = ch_t .*((1-omega)./(omega.*p.*(1+tau))).^gamma;       % STATIC OPTIMALITY EQ, where p is ratio of foreign goods price to home goods price. p is exog for small country.
y_t  = l_t;                                                  % PRODUCTION FUNCTION
tb_t = (1-Upsilon.*vxphi/2.* pi_t.^2).*y_t - ch_t - p.*cf_t; % TRADE BALANCE = EXPORTS - IMPORTS (p.8)

b_t = b0*ones(T,1);                                          % FOREIGN BOND setup: b_t is a column vector of length T, with every entry set to the value of b0.
R   = 1/beta;                                                % EQUILIBRIUM CONDITION FROM EULER EQ.
for t=1:T                                                    % TRADE BALANCE = CAPITAL OUTFLOWS (based on holdings of foreign assets)
    b_t(t+1) = R* (b_t(t) +tb_t(t));
end

mrs_t = theta_t.^(1/sigma-1/gamma) .*ch_t.^(1/sigma).* l_t.^psi;    % MRS: MRS= W_t/P_ft (see handw. notes)
lw_t  = 1-mrs_t;                                                    % LABOUR WEDGE

wp = mrs_t;                                                         % WILLINGNESS TO PAY?

% pre-tariff prices
pH0 = 1;                                                                            % HOME GOOD PRICE NORMALIZED TO 1 in st.st.
P0  = pH0.* (omega^gamma +(1-omega)^gamma.*p.^(1-gamma)).^(1/(1-gamma));            % CES PRICE INDEX FORMULA in st.st. (t=0) ???

pH_t = (1+pi_t)*pH0;
for t=2:T
    pH_t(t) = (1+pi_t(t)).*pH_t(t-1);
end
P_t = pH_t .*(omega^gamma +(1-omega)^gamma.*(p.*(1+tau)).^(1-gamma)).^(1/(1-gamma)); % CES PRICE INDEX FORMULA ???
cpi_t = [P_t(1)./P0-1; P_t(2:end)./P_t(1:end-1)-1];                                  % CPI: vector of P_t / P_t-1 from time 0 all the way down to time T-1.


c_t = omega.*ch_t.^(1-1/gamma) + (1-omega).*cf_t.^(1-1/gamma);                       % Define consumption bundle inside exponents
c_t = c_t.^(gamma/(gamma-1));                                                        % Apply exponent to obtain the definition of consumption bundle c_t.
if sigma==1
    u_c = log(c_t);
else
    u_c = c_t.^(1-1/sigma)./(1-1/sigma);   	                 % Hh utility function over consumption
end
util = u_c -omega .*l_t.^(1+psi)./(1+psi);                   % HH utils
welf = sum(betavec.*util) + beta^T/(1-beta) .*util(end);     % Lifetime discounted utility.

var.ch_t = ch_t;    % consumption of home goods
var.cf_t = cf_t;    % consumption of foreign goods
var.pi_t = pi_t;    % inflation rate of home-produced goods (PPI)
var.tb_t = tb_t;    % trade balance = exports - imports (s.8)
var.lw_t = lw_t;    % labor wedge, defined as 1-mrs_t. positive labor wedge indicates underutilization of labor.
var.pH_t = pH_t;    % price of home good c_h

var.l_t  = l_t;     % labour supply
var.y_t  = y_t;     % production 
var.b_t  = b_t;     % foreign bond
var.c_t  = c_t;     % consumption bundle
var.P_t  = P_t;
var.cpi_t= cpi_t;   % CPI rate
var.wp = wp;

var.welf = welf;

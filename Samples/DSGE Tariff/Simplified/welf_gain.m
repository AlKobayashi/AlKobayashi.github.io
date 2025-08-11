function dev = welf_gain(x,var1,var2,beta,betavec,psi,omega,sigma)

T = length(betavec);

    util = 1/(1-1/sigma) .*var1.c_t.^(1-1/sigma) ...
            - omega.*var1.l_t.^(1+psi)./(1+psi);

welf = sum(betavec.*util)  + beta^T./(1-beta) .*util(end);

    util0 = 1/(1-1/sigma) .*((1+x).*var2.c_t).^(1-1/sigma) ...
            - omega.*var2.l_t.^(1+psi)./(1+psi);
 
welf0 = sum(betavec.*util0)  + beta^T./(1-beta) .*util0(end);


 
dev = welf-welf0;

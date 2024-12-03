
function u = NormalizedBasisFunction(T,x,xExp)

    rho = UnnormalizedBasisFunction(T,x,xExp);
    den = sum(rho);
    u = rho / den;
    check = sum(u);
end


% Unnormalized Basis Function
function rho = UnnormalizedBasisFunction(T,x,xExp)

    [betaScale,yStar,nu] = RBNParameters_NN_u(T);
    
    numBasis = length(xExp(:,1));
    
    rho = zeros(1,numBasis);
    tiny = 1e-6;
    for i=1:numBasis
            dxCenters = x - xExp(i,:);
            arg = - betaScale * dot(dxCenters,dxCenters);
            rho(i) = exp(arg);
            rho(i) = max(rho(i),tiny);
    end   
end

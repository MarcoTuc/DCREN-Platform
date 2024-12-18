
function ukij = NormalizedBasisFunction(DataStruct,xCenterj)
    rho = UnnormalizedBasisFunction(DataStruct,xCenterj);
    ukij = rho / sum(rho);
end


% Unnormalized Basis Function
function rho = UnnormalizedBasisFunction(DataStruct,xCenterj)
    betaScale = DataStruct.hyperStruct.betaScale;
    numBasis = DataStruct.hyperStruct.numBasis;
    rho = zeros(1,numBasis);
    tiny = 1e-3;
    for i=1:numBasis
            dxCenters = (xCenterj - DataStruct.xBasisCenters(i,:)) / DataStruct.CenterNormalization ;
            arg = - betaScale * dot(dxCenters,dxCenters);
            rho(i) = exp(arg);
            rho(i) = max(rho(i),tiny);
    end   
end

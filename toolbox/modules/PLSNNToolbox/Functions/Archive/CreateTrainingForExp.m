function xBasisCenters = CreateTrainingForExp(T,yPLS,RMSEPLS) % Normalizes and calculates basis centers
    % called from NNRegression
    
    [numBasis,numSamples,ncomp,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);
    
    xCenterControlled = CalculateCentersControlledUncontrolled(T,numSamples);
    xCenterPLS = CalculateCentersPLS(yPLS,RMSEPLS,numSamples);

    xBasisCenters = [xCenterControlled,xCenterPLS];  % Include controlled and PLS centers
end




function xExp = CreateBasisCenters(T,yPLS,RMSEPLS)
    % Called from NNRegression
    
    [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);
    
    % Create the basis centers
    xCenterControlled = CalculateCentersControlledUncontrolled(T,numSamples);
    xCenterControlled = transpose(xCenterControlled);
    xCenterPLS = CalculateCentersPLS(yPLS,RMSEPLS,numSamples);
    xExp = [xCenterControlled,xCenterPLS];
end

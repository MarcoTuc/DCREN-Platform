function [ACC,SE,SP] = Persistance(T)
    [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);

    xName = 'x';
    x_CD_UCD = DataGeneratingRoutineForBasisFunctions(xName,T);
    xCenterControlled = zeros(numSamples,1);
    for j=1:numSamples
        if(x_CD_UCD(j) == "controlled")
                xCenterControlled(j) = -1;
            else
                xCenterControlled(j) = 1;
        end
    end
    
    xName = "DEGFR_2"; % The value of DEGFR at visit 1
    yPER = DataGeneratingRoutineForBasisFunctions(xName,T);
    
    
    
end

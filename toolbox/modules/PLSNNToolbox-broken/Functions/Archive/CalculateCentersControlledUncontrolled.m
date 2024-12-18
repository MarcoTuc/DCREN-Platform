
function xCenterControlled = CalculateCentersControlledUncontrolled(T,numSamples) % CD/UCD inputs
    % Called from CreateTrainingForExp
    
    [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);
    
    xName = "x"; % Name of the column in the data that holds the controlled/uncontrolled flag
    x_CD_UCD = DataGeneratingRoutineForBasisFunctions(xName,T);
    
    %L = numSamples;
    xCenterControlled = zeros(numSamples,1);
    for i=1:numSamples
        if(x_CD_UCD(i) == "controlled")
                xCenterControlled(i) = -1;
            else
                xCenterControlled(i) = 1;
        end
    end
    
    xCenterControlled = xCenterControlled / CDNormalizationFactor; % Normalization CD/UCD
end


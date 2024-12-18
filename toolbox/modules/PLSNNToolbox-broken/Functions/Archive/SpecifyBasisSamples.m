function [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn,NNCubeFlag] = SpecifyBasisSamples(T)
    
    % Called from NNRegression and other places
    
    [betaScale,nu,numBasis,xName] = RBNParameters_NN_u(T);

    xSample = DataGeneratingRoutineForBasisFunctions(xName,T);
    numSamples = length(xSample) - 1; % Number of samples
    ncomp = 5; % number of PLS components
    nameControlColumn = 'x';
    numCrossValidation =5;
    arg = 1/nu;
    numCyclesThroughTrainingData = ceil(arg);
    NNCubeFlag = 1;
end
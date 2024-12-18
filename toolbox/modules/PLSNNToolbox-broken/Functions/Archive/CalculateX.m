function [X,XTest] = CalculateX(xNamePLS,T,numSamples)
        
        LVariable = length(xNamePLS);
        LSample = numSamples + 1;
        XWithTest = zeros(LSample,LVariable); % Initialize the input matrix
        X = zeros(numSamples,LVariable); % Initialize the input matrix
        
        for k=1:LVariable % Create input matrix X
            XWithTest(:,k) = DataGeneratingRoutineForBasisFunctions(xNamePLS(k),T); % Grab the raw data 
        end
        
        for j=1:numSamples
            X(j,:) = XWithTest(j,:);
        end
        
        XTest = XWithTest(LSample,:);
end
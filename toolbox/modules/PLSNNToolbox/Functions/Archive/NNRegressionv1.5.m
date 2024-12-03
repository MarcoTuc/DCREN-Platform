function [yNN,errorTestNN] = NNRegression(T,xD,xDTest,yD,yDTest,bPLS,yPLS,yPLSTest)
        % Called from CrossValidation
        
        % Create the basis centers for both training and test sets
        %[xBasisCenters,xBasisCentersTest] = CreateTrainingForExp(T,yD,yTestPLS,RMSEPLS); % Normalizes and calculates basis centers

        % Train the network
        aki = InitializeAki(T,bPLS); % ai is an array of size (ncomp + 1 , numBasis)
        [yNN,errorTestNN] = Training(T,xD,xDTest,yD,yDTest,bPLS,yPLS,yPLSTest,aki); % Train the data for the NN        
end

% **************************************************************************** 
% Training Algorithms
% **************************************************************************** 

% Train the data set
function [yNN,yNNTest,errorTestNN] = Training(T,xD,xDTest,yD,yDTest,bPLS,yPLS,yPLSTest,aki)
        %s = "Entering Training"

        % Hyperparameters
        [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);
        
        
        % Run through the training data numCyclesThroughTrainingData times
        for l = 1:numCyclesThroughTrainingData
            
            % Calculate the basis centers
            [xBasisCenters,xBasisCentersTest,yDNormalization] = CreateTrainingForExp(T,yD,yPLS,yPLSTest); % Centers for basis functions. [numSamples,1]
            
            % Identify the testing patient
            
            yNN = yPLS;
            % One run through training data
            for j = 1:numSamples
                % Calculate NN output for sample j
                [vkij,ynnj] = CalculateYNN(T,j,aki,xD,bPLS,xBasisCenters);
                yNN(j) = ynnj;
                yDj = yD(j);
                % One update of the learning rates aki
                aki = LearningRoutine(T,aki,vkij,yDj,ynnj);
            end
            
            yNNTest = CalculateYNNTest(T,aki,xDTest,bPLS,yD,yDTest,yPLS,yPLSTest);
            errorTestNN = yDTest - yNNTest;
        end
end
    
function aki = LearningRoutine(T,aki,vkij,yDj,ynnj)

    [betaScale,nu,numBasis,xName,checkThreshold] = RBNParameters_NN_u(T);

    v2 = vkij .* vkij;
    den = sum(v2,'all');
    projectionFactor = vkij / den; % projectionFactor is a horizontal vector of length numBasis
    error = yDj - ynnj;

    dai = nu * error .* projectionFactor; % dai is a horizontal vector of length numBasis
    aki = aki + dai; % ai is a horizontal vector of length numBasi

end
    
function [vkij,ynnj] = CalculateYNN(T,j,aki,xD,bPLS,xBasisCenters)
        [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);
                
                AA = ones(numSamples,1);
                xDD = [AA,xD];

                xCenterj = xBasisCenters(j,:); % x is a 2D vector used as basis center for sample j
                ukij = NormalizedBasisFunction(T,xBasisCenters,xCenterj); % u is a horizontal vector of length numBasis
                xPLSj = xDD(j,:);
                bT = transpose(bPLS);
                xMkj = bT .* xPLSj;
                xT = transpose(xMkj);
                vkij = xT .* ukij;
                
                A = aki .* vkij;
                ynnj = sum(A,'all');
end
        
function ynnj = CalculateYNNTest(T,aki,xDTest,bPLS,yD,yDTest,yPLS,yPLSTest)

        % Called from CalculateTestError      
        [xBasisCenters,xBasisCentersTest,yDNormalization] = CreateTrainingForExp(T,yD,yPLS,yPLSTest); % Centers for basis functions. [numSamples,1]

        % Use yPLSTest as a guess for yDTest
            numRecurrent = 1;
            for l=1:numRecurrent 
                xCenterj = xBasisCentersTest;            
                ynnj = NeuralNetworkOutput(T,xBasisCenters,xCenterj,xDTest,bPLS,aki);
                xBasisCentersTest(1) = ynnj / yDNormalization;
            end
end

function ynnj = NeuralNetworkOutput(T,xBasisCenters,xCenterj,xDTest,bPLS,aki)
     bT = transpose(bPLS);
     xDTest = [1,xDTest];
     xMkj = bT .* xDTest;
     ukij = NormalizedBasisFunction(T,xBasisCenters,xCenterj); % u is a horizontal vector of length numBasis
     xT = transpose(xMkj);
     vkij = xT .* ukij;        
     A = aki .* vkij;
     ynnj = sum(A,'all');
end

function [xBasisCenters,xBasisCentersTest,yDNormalization] = CreateTrainingForExp(T,yD,yPLS,yPLSTest) % Normalizes and calculates basis centers
    % called from NNRegression
    
    % Create training and testing centers
    [xCenterPLS,xCenterPLSTest] = CalculateCentersPLS(T,yPLS,yPLSTest);
    % Use yPLSTest for initial guess of yDTest
    [xCenterD,xCenterDTest,yDNormalization] = CalculateCentersD(T,yD,yPLSTest); %calculates a basis center for each of all numSamples
    
    xBasisCenters = [xCenterD,xCenterPLS] ;
    xBasisCentersTest = [xCenterDTest,xCenterPLSTest];
end

function [xCenterD,xCenterDTest,yDNormalization] = CalculateCentersD(T,yD,yPLSTest) % Centers based on actual data yD
    % Called from  CreateTrainingForExp here
    % Picks centers from first numSamples values of yD
    [numBasis,numSamples,ncomp,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);
    
    yDNormalization = std(yD);
    xCenterD = zeros(numSamples,1);
    for i=1:numSamples
        xCenterD(i) = yD(i) / yDNormalization;
    end
    
    % Use yPLSTest as a guess for yDTest
    xCenterDTest = yPLSTest / yDNormalization;
end

function [xCenterPLS,xCenterPLSTest] = CalculateCentersPLS(T,yPLS,yPLSTest)
    % Called from  CreateTrainingForExp
    
    % Picks centers from first numSamples values of yD
    [numBasis,numSamples,ncomp,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);

    normalization = std(yPLS);
    xCenterPLS = zeros(numSamples,1);
    for i=1:numSamples
        xCenterPLS(i) = yPLS(i) / normalization;
    end

    xCenterPLSTest = yPLSTest / normalization;
end

function  aki = InitializeAki(T,bPLS) % Initialize the weights
        numVariables = length(bPLS);
        [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn,CDNormalizationFactor] = SpecifyBasisSamples(T);
        aki = ones(numVariables,numBasis);
    end







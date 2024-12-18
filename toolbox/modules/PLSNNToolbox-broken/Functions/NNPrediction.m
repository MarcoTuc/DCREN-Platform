function DataStruct = NNPrediction(k,DataStruct)
        DataStruct.xNameData = transpose(DataStruct.xNameData);
        DataStruct = Evaluate(k,DataStruct); % Evaluate the data for the NN 
        DataStruct.yNN = transpose(DataStruct.yNN);
end
% **************************************************************************** 
% Training Algorithms
% **************************************************************************** 
function DataStruct = Evaluate(k,DataStruct) % Train the data set
        %DataStruct.aki = InitializeAkiEst(DataStruct); % Initialize the learning weights. aki is an array of size (ncomp + 1 , numBasis)
        %DataStruct = RunThroughTrainingDataManyTimes(DataStruct); % numCyclesThroughTrainingData 
        DataStruct = OnceThroughTrainingData(DataStruct);
        DataStruct = CalculateTestOutput(k,DataStruct); % Calculate test output 

end


function DataStruct = RunThroughTrainingDataManyTimes(DataStruct) % numCyclesThroughTrainingData 
    DataStruct = GetPatientID(DataStruct); % Get patient ID
    DataStruct = CreateTrainingForExp(DataStruct); % Calculate the basis centers. One basis center based on yPLS and one based on yD
    for l = 1:DataStruct.hyperStruct.numCyclesThroughTrainingData % Run through the training data numCyclesThroughTrainingData times
        DataStruct = OnceThroughTrainingData(DataStruct); 
    end
end


function DataStruct = OnceThroughTrainingData(DataStruct) % DataStruct.hyperStruct.numSamples 
    for j = 1:DataStruct.hyperStruct.numSamples % Go once through the samples
        [vkij,DataStruct.yNN(j)] = CalculateYNN(j,DataStruct); % ynnj is the NN output for YNN
        
        %{
        if(DataStruct.IDL ~= DataStruct.ID(j)) % Do not train on test patient
            %DataStruct = LearningRoutine(j,DataStruct); % Learning Routine: One update of the learning rates aki 
        end
        %}
    end 
end


function DataStruct = LearningRoutine(j,DataStruct)
    [vkij,DataStruct.yNN(j)] = CalculateYNN(j,DataStruct); % ynnj is the NN output for YNN
    projectionFactor = vkij / sum(vkij .* vkij,'all');
    error = DataStruct.yD(j) - DataStruct.yNN(j);
    dai = DataStruct.hyperStruct.nu * error .* projectionFactor; % The change in learning weights
    DataStruct.aki = DataStruct.aki + dai; % Update the learning weights
end



function [vkij,ynnj] = CalculateYNN(j,DataStruct) % ynnj is the NN output for YNN
    xCenterj = CalculatexCenterInput(j,DataStruct); % These are the input values that are compared with basis centers in u
    ukij = NormalizedBasisFunction(DataStruct,xCenterj); % u is a horizontal vector of length numBasis
    vkij = DataStruct.bPLS .* transpose(DataStruct.xPLS(j,:)) .* ukij;
    A = DataStruct.aki .* vkij;
    ynnj = sum(A,'all');
end


function xCenterj = CalculatexCenterInput(j,DataStruct)
    xCenterj = [DataStruct.yD(j),DataStruct.yPLS(j)]; % x is a 2D vector used as basis center for sample j. Normalize.
end


function DataStruct = CalculateTestOutput(k,DataStruct) 
    RFlag = false; % RFlag = true means that ynnj is calculated for yR. RFlag = false means that ynnj is calculated for yNN 
    [ynnj, DataStruct] = CalculateYNNTest(DataStruct,RFlag);
    DataStruct.yNNTestArray(k) = ynnj;
    RFlag = true;
    [ynnj, DataStruct] = CalculateYNNTest(DataStruct,RFlag);
    DataStruct.yRTestArray(k) = ynnj;
    
    DataStruct.yDTestArray(k) = DataStruct.yDTest;
    DataStruct.errorTestNN(k) = DataStruct.yDTest - DataStruct.yNNTestArray(k);
end
    
function [ynnj, DataStruct] = CalculateYNNTest(DataStruct,RFlag) % If T~=TR AND RFlag=true then ynnj=yR. Otherwise ynnj = yNN.
        xCenterj = [DataStruct.yTestPLS, DataStruct.yTestPLS]; % x is a 2D vector used as basis center for sample j. Normalize.
        for i=1:1
            ynnj = NeuralNetworkOutput(xCenterj, DataStruct, RFlag); % Calculate the output
            if(DataStruct.hyperStruct.NNCubeFlag)
                L = length(DataStruct.xDTest(1,:));
                L1 = L - 1;
                DataStruct.xTestPLS(:,L) = ynnj.^3;
                DataStruct.xTestPLS(:,L1) = ynnj.^2;
                xCenterj = [ynnj, DataStruct.yTestPLS];
            end 
        end
end

function ynnj = NeuralNetworkOutput(xCenterj, DataStruct, RFlag)    
     if(DataStruct.TName == "TR")
         aki = DataStruct.aki;
         bPLS = DataStruct.bPLS;
     else
         if(RFlag) % RFlag = true means that ynnj is calculated for yR. RFlag = false means that ynnj is calculated for yNN
            aki = DataStruct.DataStructR.aki;
            bPLS = DataStruct.DataStructR.bPLS;
         else
            aki = DataStruct.aki;
            bPLS = DataStruct.bPLS;
         end
     end
     ukij = NormalizedBasisFunction(DataStruct,xCenterj); % u is a horizontal vector of length numBasis
     A = aki .* bPLS .* transpose(DataStruct.xTestPLS) .* ukij;
     ynnj = sum(A,'all');
end
  
function DataStruct = GetPatientID(DataStruct)
    xName = "ID";
    IDCell = DataGeneratingRoutineForBasisFunctions(xName,DataStruct.T); % Get the patient ID for each patient j
    DataStruct.ID = string(IDCell); % Covert the ID into a string 
    L = length(DataStruct.ID);
    DataStruct.IDL = DataStruct.ID(L); % IDL is the ID of the test patient
end

function [DataStruct] = CreateTrainingForExp(DataStruct) % Normalizes and calculates basis centers
    [xCenterPLS,xCenterPLSTest] = CalculateCentersPLS(DataStruct.hyperStruct, DataStruct.yPLS, DataStruct.yTestPLS);
    [xCenterD,xCenterDTest] = CalculateCentersD(DataStruct.hyperStruct, DataStruct.yD, DataStruct.yTestPLS); %calculates a basis center for each of all numSamples 
    DataStruct.xBasisCenters = [xCenterD,xCenterPLS] ;
    DataStruct.xBasisCentersTest = [xCenterDTest,xCenterPLSTest];
    DataStruct.CenterNormalization = std(xCenterD);
end

function [xCenterPLS,xCenterPLSTest] = CalculateCentersPLS(hyperStruct,yPLS,yTestPLS)
    % Called from  CreateTrainingForExp
    xCenterPLS = zeros(hyperStruct.numSamples,1);
    for i=1:hyperStruct.numSamples % Run through samples
        xCenterPLS(i) = yPLS(i);
    end
    xCenterPLSTest = yTestPLS ;
end

function [xCenterD,xCenterDTest] = CalculateCentersD(hyperStruct,yD,yDTest) % Centers based on actual data yD
    % Called from  CreateTrainingForExp here
    % Picks centers from first numSamples values of yC
    xCenterD = zeros(hyperStruct.numSamples,1);
    for i=1:hyperStruct.numSamples
        xCenterD(i) = yD(i);
    end
    xCenterDTest = yDTest; 
end


function  aki = InitializeAkiEst(DataStruct) % Initialize the weights
        numVariables = length(DataStruct.xPLS(1,:));
        numBasis = DataStruct.hyperStruct.numBasis;
        aki = ones(numVariables,numBasis);
end

 
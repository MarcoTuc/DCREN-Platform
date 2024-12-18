function DataStruct = CrossValidation(DataStruct) % Called from main program 
    %s="CrossValidation"
    DataStruct = LoopThroughValidationSet(DataStruct); % Loop through validation set. 
end

function DataStruct = LoopThroughValidationSet(DataStruct)
    DataStruct = InitializeArrays(DataStruct);
    for k=1:DataStruct.hyperStruct.numCrossValidation % Scroll through cross-validation set
        DataStruct = ReadAndPrepareData(DataStruct);
        DataStruct = PLSRegression(k,DataStruct); %***********************************
        DataStruct = NNRegression(k,DataStruct); %***********************************
    end
    DataStruct = UpdateErrors(DataStruct);
end

function DataStruct = ReadAndPrepareData(DataStruct)
        DataStruct = RandomizeAndRotateData(DataStruct); % Prepare data for trainig
        DataStruct = RetrieveActualData(DataStruct); % Read in actual data
            % Read in data to input PLSRegression
                % DataStruct.xD is the first numSamples of input data x
                % DataStruct.xDTest is the numSample + 1 of input data x
                % DataStruct.yD is the first numSamples of output data y
                % DataStruct.yDTest is the numSample + 1 of output data y
                % DataStruct.hyperStruct.ncomp is the number of PLS components
end

function DataStruct = InitializeArrays(DataStruct)
    DataStruct = InitializeBeforeRunningThroughTraining(DataStruct); % Initialize before running through the training sets
    [DataStruct.errorTestPLSVec,DataStruct.errorTestNNVec] = InitializeError(DataStruct);
    DataStruct.xNameDataExt = [DataStruct.xNameData,["yD^2","yD^3"]];
end

function DataStruct = UpdateErrors(DataStruct)
    DataStruct.QualityParameters.RMSEPLS = rms(DataStruct.errorTestPLS);
    DataStruct.QualityParameters.RMSENN = rms(DataStruct.errorTestNN);
end

function [errorTestPLSVec,errorTestNNVec] = InitializeError(DataStruct)
    errorTestPLSVec = zeros(DataStruct.hyperStruct.numCrossValidation,1);
    errorTestNNVec = zeros(DataStruct.hyperStruct.numCrossValidation,1);
end

function DataStruct = RandomizeAndRotateData(DataStruct)
    DataStruct.T = RandomizeRows(DataStruct);
    DataStruct.T = RotateT(DataStruct); % Rotate the data set. Move the first visit to the last. Move each visit to the one before.
end

function DataStruct = InitializeBeforeRunningThroughTraining(DataStruct)
    DataStruct.yDTestArray = zeros(1,DataStruct.hyperStruct.numCrossValidation); 
    DataStruct.yPLSTestArray = zeros(1,DataStruct.hyperStruct.numCrossValidation); 
    DataStruct.yNNTestArray = zeros(1,DataStruct.hyperStruct.numCrossValidation); 
    DataStruct.yRTestArray = zeros(1,DataStruct.hyperStruct.numCrossValidation); 
    DataStruct.errorTestPLSVec = zeros(DataStruct.hyperStruct.numCrossValidation,1); 
    DataStruct.errorTestNNVec = zeros(DataStruct.hyperStruct.numCrossValidation,1);  
end

function T = RandomizeRows(DataStruct)
    T = DataStruct.T ;
    L = length(DataStruct.hyperStruct.xSample);
    T = T(randperm(L),:);
end

function T = RotateT(DataStruct)
        T = DataStruct.T; % Get the initial configuration of the data set
        T = RotateData(T); % Choose a holdout data point       
end





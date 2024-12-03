
function DataStruct = RunTheCodePrediction(DataStruct)
        %s="RunTheCodePrediction"
        if(DataStruct.hyperStruct.RASiAloneFlag) % RUN THE CODE
            DataStruct = RunModels(DataStruct);   
        else
            DataStruct.DataStructR = load('MasterOutput/DataStructR.mat');
            DataStruct = RunModels(DataStruct);
        end
end

function DataStruct = RunModels(DataStruct) % Read data, call the regression routines
        DataStruct = CrossValidation(DataStruct); % Start the engine
        DataStruct = QualityOfFit(DataStruct); % Calculate quality parameters; 
end

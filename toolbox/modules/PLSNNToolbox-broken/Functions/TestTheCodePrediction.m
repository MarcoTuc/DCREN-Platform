
function DataStructPrediction = TestTheCodePrediction(DataStructPrediction)

        if(DataStructPrediction.hyperStruct.RASiAloneFlag) % RUN THE CODE
            DataStructPrediction = RunModels(DataStructPrediction);   
        else
            DataStructPrediction.DataStructR = load('MasterOutput/DataStructR.mat');
            DataStructPrediction = RunModels(DataStructPrediction);
        end
end

function DataStructPrediction = RunModels(DataStructPrediction) % Read data, call the regression routines
        DataStructPrediction = TestValidation(DataStructPrediction); % Start the engine
        %DataStructPrediction = QualityOfFit(DataStructPrediction); % Calculate quality parameters; 
end

function DataStruct = RunModels(DataStruct) % Read data, call the regression routines
        DataStruct = CrossValidation(DataStruct); % Start the engine
        DataStruct = QualityOfFit(DataStruct); % Calculate quality parameters; 
end

 
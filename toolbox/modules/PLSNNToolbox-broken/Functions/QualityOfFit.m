function DataStruct = QualityOfFit(DataStruct) % Calculate quality parameters
    %s="QualityOfFit"
        DataStruct = CalculateQualityParameters(DataStruct);
        S = LoadTableStruct(DataStruct); % Load the table structure
        DataStruct.TOut = struct2table(S); % Convert the structure to a table
end

function S = LoadTableStruct(DataStruct)
        
        S.ModelType = ["PLS";"NN"];
        S.InputData = [DataStruct.xNameDataSet; DataStruct.xNameDataSet];
        S.Treatment = [DataStruct.hyperStruct.treatment; DataStruct.hyperStruct.treatment];
        S.RMSE = [DataStruct.QualityParameters.RMSEPLS; DataStruct.QualityParameters.RMSENN]; % Root mean square error on the test set
        S.ACC = [DataStruct.QualityParameters.accuracyPLS;DataStruct.QualityParameters.accuracyNN];
        S.SE = [DataStruct.QualityParameters.sensitivityPLS; DataStruct.QualityParameters.sensitivityNN];
        S.SP = [DataStruct.QualityParameters.specificityPLS; DataStruct.QualityParameters.specificityNN];
        S.Sum = S.SE + S.SP; 
end

function DataStruct = CalculateQualityParameters(DataStruct)
        testFlag = "Train";
        [numberOfSamplesPLS,sensitivityPLS,specificityPLS,accuracyPLS] = SensitivitySpecificityAccuracy_NN(DataStruct, DataStruct.yPLS, testFlag);
        testFlag = "Test";
        [numberOfSamplesNN,sensitivityNN,specificityNN,accuracyNN] = SensitivitySpecificityAccuracy_NN(DataStruct, DataStruct.yNNTestArray, testFlag);
        DataStruct.QualityParameters.numberOfSamplesPLS = numberOfSamplesPLS;
        DataStruct.QualityParameters.sensitivityPLS = sensitivityPLS;
        DataStruct.QualityParameters.specificityPLS = specificityPLS;
        DataStruct.QualityParameters.accuracyPLS = accuracyPLS;
        DataStruct.QualityParameters.numberOfSamplesNN = numberOfSamplesNN;
        DataStruct.QualityParameters.sensitivityNN = sensitivityNN;
        DataStruct.QualityParameters.specificityNN = specificityNN;
        DataStruct.QualityParameters.accuracyNN = accuracyNN;
end


function [numberOfSamples,sensitivity,specificity,accuracy] = SensitivitySpecificityAccuracy_NN(DataStruct, yNNTestArray, testFlag)
    if( testFlag == "Train")
        yDTestArray = DataStruct.yD;
    else
        yDTestArray = DataStruct.yDTestArray;
    end
    L = length(yDTestArray);

    % Calculate sensitivity, specificity, and accuracy
    % Initialize Total number of visits with CD and UCD at visit 1
    num_D_CD = 0;
    num_F_CD_CD = 0;
    num_F_CD_UCD = 0;
    num_D_UCD = 0;
    num_F_UCD_CD = 0;
    num_F_UCD_UCD = 0;
    
    % Calculate numbers for CD
    for i=1:L
                % Count numbers from initial visit of controlled disease
                if(yDTestArray(i) > -5)
                        num_D_CD = num_D_CD + 1; % Number of actual CD
                        if(yNNTestArray(i) > -5)
                            num_F_CD_CD = num_F_CD_CD + 1; % Number of outcomes predicted to be CD that are CD
                        elseif(yNNTestArray(i) < -10)
                            num_F_CD_UCD = num_F_CD_UCD + 1; % Number of outcomes predicted to be UCD that are CD
                        end
                end
                if(yDTestArray(i) < -10)
                    num_D_UCD = num_D_UCD + 1; % Number of actual UCD
                    if(yNNTestArray(i) < -10)
                        num_F_UCD_UCD = num_F_UCD_UCD + 1; % Number of outcomes predicted to be UCD that are UCD
                    elseif(yNNTestArray(i) > -5)
                        num_F_UCD_CD = num_F_UCD_CD + 1; % Number of outcomes predicted to be CD that are UCD
                    end
                end 
    end
    % CD
    DataStruct.num_D_CD = num_D_CD; % Number of actual samples that are CD
    DataStruct.num_F_CD_CD = num_F_CD_CD; % Number of outcomes predicted to be CD that are CD
    DataStruct.num_F_CD_UCD = num_F_CD_UCD; % Number of outcomes predicted to be UCD that are CD
    % UCD
    DataStruct.num_D_UCD = num_D_UCD; % Number of actual samples that are UCD
    DataStruct.num_F_UCD_UCD = num_F_UCD_UCD; % Number of outcomes predicted to be UCD that are UCD
    DataStruct.num_F_UCD_CD = num_F_UCD_CD; % Number of outcomes predicted to be CD that are UCD
    % Output to the routine
    numberOfSamples = NumberOfSamples( num_D_CD,num_D_UCD ); % Number of actual outcomes in either CD or UCD
    sensitivity = Sensitivity(num_F_UCD_UCD,num_D_UCD); % Fraction of predicted UCD that are correct
    specificity = Specificity(num_F_CD_CD,num_D_CD); % Fraction of predicted CD that are correct
    accuracy = Accuracy( num_F_UCD_UCD,num_F_CD_CD,num_D_UCD,num_D_CD); % Fraction of correct predictions
end


function numberOfSamples = NumberOfSamples( num_D_CD,num_D_UCD )
    numberOfSamples = num_D_CD + num_D_UCD;
end

function sensitivity = Sensitivity(num_F_UCD_UCD,num_D_UCD)
    tiny = 1e-6;
    sensitivity = (num_F_UCD_UCD ) / (num_D_UCD + tiny) ;
end

function specificity = Specificity(num_F_CD_CD,num_D_CD)
    tiny = 1e-6;
    specificity = (num_F_CD_CD ) / (num_D_CD + tiny);
end

function accuracy = Accuracy( num_F_UCD_UCD,num_F_CD_CD,num_D_UCD,num_D_CD)
    tiny = 1e-6;
    accuracy = (num_F_UCD_UCD + num_F_CD_CD ) / (num_D_UCD + num_D_CD + tiny);
end


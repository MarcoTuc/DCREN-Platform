function [DataStruct] = RetrieveActualData(DataStruct)
    xName = "DEGFR_2"; % The value of DEGFR at visit 2
    DataStruct = ReduceSingleDataByOne(xName,DataStruct);
    DataStruct = ReduceInputDataByOne(DataStruct);
    DataStruct = StandardizeData(DataStruct);
end

function DataStruct = StandardizeData(DataStruct)
    DataStruct.xDNorm = zeros(DataStruct.hyperStruct.numSamples, DataStruct.numDataVariables);
    for j=1:DataStruct.numDataVariables
        DataStruct.xDNorm(:,j) = (DataStruct.xD(:,j) - DataStruct.xDMean(j)) / DataStruct.xDStd(j);
        DataStruct.xDTestNorm(j) = (DataStruct.xDTest(j) - DataStruct.xDMean(j)) / DataStruct.xDStd(j);
    end
    DataStruct.yDNorm = ( DataStruct.yD - DataStruct.yDMean) / DataStruct.yDStd;
    DataStruct.yDTestNorm = ( DataStruct.yDTest - DataStruct.yDMean) / DataStruct.yDStd;
end


function DataStruct = ReduceSingleDataByOne(xName,DataStruct)
    yT = DataGeneratingRoutineForBasisFunctions(xName,DataStruct.T); % Get the data of type xName
    DataStruct.yD = zeros(DataStruct.hyperStruct.numSamples,1); % NumSamples is one less than the total number of samples
    for i=1:DataStruct.hyperStruct.numSamples % Run through data for variable xName and copy all but last entry into variable x
        DataStruct.yD(i) = yT(i);
    end
    DataStruct.yDMean = mean(DataStruct.yD);
    DataStruct.yDStd = std(DataStruct.yD);
    L = DataStruct.hyperStruct.numSamples + 1;
    DataStruct.yDTest = yT(L); % Copy the last sample into variable xTest
end


function DataStruct = ReduceInputDataByOne(DataStruct)
    DataStruct.numDataVariables = length(DataStruct.xNameData);
    L = DataStruct.hyperStruct.numSamples + 1;
    DataStruct.xD = zeros(DataStruct.hyperStruct.numSamples,DataStruct.numDataVariables);
    xT = zeros(L,DataStruct.numDataVariables);
    for j=1:DataStruct.numDataVariables
        xName = DataStruct.xNameData(j);
        xT(:,j) = DataGeneratingRoutineForBasisFunctions(xName,DataStruct.T);
    end
    for i=1:DataStruct.hyperStruct.numSamples
        DataStruct.xD(i,:) = xT(i,:);
    end
    for j=1:DataStruct.numDataVariables
        DataStruct.xDMean(j) = mean(DataStruct.xD(:,j));
        DataStruct.xDStd(j) = std(DataStruct.xD(:,j));
    end
    DataStruct.xDTest = xT(L,:); % The input for the test point is the value of the input vector for the last data point in the data set
end
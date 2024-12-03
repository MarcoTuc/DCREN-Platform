function DataStruct = AgeSeries(DataStruct) % Sort data by age and create buckets. 
    DataStruct = SortRowsByAge(DataStruct); % Sort rows by age. Youngest first. DataStruct.biomarkersNormByAge
    DataStruct = SmoothTheData(DataStruct); % Smooth the data. DataStruct.biomarkersNormByAgeSmooth
    DataStruct = ClusterEveryBucket(DataStruct); % Cluster every bucket and write to csv file. DataStruct.ArrayOfClusters 
end



function DataStruct = SortRowsByAge(DataStruct)
    A = DataStruct.biomarkersNorm;
    B = sortrows(A,12); % Age is column 12
    DataStruct.biomarkersNormByAge = B;
end


function DataStruct = SmoothTheData(DataStruct)
    hyperStructClusters = HyperStructClusters(); % Get hyperparameters
    B = DataStruct.biomarkersNormByAge;
    smoothingSize = hyperStructClusters.smoothingSize;
    DataStruct.biomarkersNormByAgeSmooth = smoothdata(B,"lowess",smoothingSize);
end


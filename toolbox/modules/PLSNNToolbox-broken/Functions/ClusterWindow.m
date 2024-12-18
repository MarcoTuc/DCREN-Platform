
function DataStruct = ClusterWindow(DataStruct) % Cluster every bucket
        %s = "Entering ClusterEveryBucket"
        DataStruct = CalculateNumberOfAgeBuckets(DataStruct);
        firstBucket = DataStruct.numSamplesPerBucket;
        lastBucket = DataStruct.numAgeBuckets * DataStruct.numSamplesPerBucket - DataStruct.numSamplesPerBucket;
        L = DataStruct.numAgeBuckets - 1; % The number of clustering cells 
        C = cell(2,L); % Initialize array
        k = 1; % Initialize the cell index
        for i=firstBucket:DataStruct.numSamplesPerBucket:lastBucket % 
            bucketStart = i - DataStruct.numSamplesPerBucket + 1;
            bucketEnd = i + DataStruct.numSamplesPerBucket;
            [idCluster,kMatrix] = ClusterASpecificBucket(DataStruct,bucketStart,bucketEnd,i); % Cluster the bucket
            C(1,k) = {idCluster};
            C(2,k) = {kMatrix};
            k = k + 1; % Augment the cell index
        end
        DataStruct.ArrayOfClusters = C;
        
        % Operate on clusters
        CC = cell2mat(C(1,1));
        KK = cell2mat(C(2,1));
        DD = [CC,KK];
        
        % Calculate cluster frequencies
        [N,edges] = histcounts(CC);
        N;
        [val, idx] = max(N);
        N(idx) = 0;
        N;
        [val, idx] = max(N);

end


function [idCluster,kMatrix] = ClusterASpecificBucket(DataStruct,bucketStart,bucketEnd,i,j) % Cluster one bucket
    %s = "Entering ClusterASpecificBucket"
    hyperStructClusters = HyperStructClusters(); % Get hyperparameters
    % Define the data for the clustering
    markers = DataStruct.biomarkersNormByAge(bucketStart:bucketEnd,:);
    
    %markers = transpose(markers);
    % *********************************************************
        % CLUSTER THE DATA
        iStart = 1;
        iEnd = bucketEnd - bucketStart + 1;
        B = transpose(iStart:iEnd);
        kMatrix = [markers(B,1),markers(B,2),markers(B,3),markers(B,4),markers(B,5)];
        % Assign a cluster id to each sample point
        % Calculate the center C for each cluster
        [idCluster,C] = kmeans(kMatrix,DataStruct.numClusters);
        % *********************************************************
    
    % Write the clustered buckets to a csv file
end



function DataStruct = CalculateNumberOfAgeBuckets(DataStruct)
    hyperStructClusters = HyperStructClusters(); % Get hyperparameters
    DataStruct.numAgeBuckets = hyperStructClusters.numAgeBuckets;
    DataStruct.numSamplesPerBucket = floor( DataStruct.numSamples / DataStruct.numAgeBuckets ) ;
end

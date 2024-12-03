function DataStruct = ClusterWindowData(DataStruct)
        markers = DataStruct.window.biomarkersNorm;
        kMatrix = [markers(:,1),markers(:,2),markers(:,3),markers(:,4),markers(:,5)]; % CLUSTER THE DATA
        DataStruct.window.numClusters = length(kMatrix(1,:));
        [idCluster,C] = kmeans(kMatrix,DataStruct.numClusters); % Assign a cluster id to each sample point. Calculate the center C for each cluster
        idCluster = idCluster(~isnan(idCluster)); % Clean idCluster
        DataStruct.window.idCluster = idCluster;
        DataStruct.window.clusterCenters = C;
        clusterLabels = unique(idCluster); % clusterLabels = 1,2,3,4,5
        DataStruct.window.clusterLabels = clusterLabels(~isnan(clusterLabels));
        CC = categorical(idCluster,clusterLabels);
        DataStruct.window.numSamplesEachCluster = histcounts(CC); % Count the number of samples in each cluster
        DataStruct = SeparateClusters(DataStruct);
end
    
function DataStruct = SeparateClusters(DataStruct) % Separate Clusters 
        indCluster = zeros(DataStruct.window.numSamples,DataStruct.window.numBiomarkers,DataStruct.window.numClusters);
        for i = 1:DataStruct.window.numSamples
            for j=1:DataStruct.window.numClusters
                if(DataStruct.window.idCluster(i) == j)
                    indCluster(i,:,j) = DataStruct.window.biomarkersNorm(i,:);
                end
            end
        end
        %  Divide data into individual clusters
        DataStruct.window.individualClusters = {};
        for j=1:DataStruct.window.numClusters
            arg = indCluster(:,:,j);
            idx = (arg == 0);
            [delRows,~] = find(idx);
            arg(delRows,:) = [];
            DataStruct.window.individualClusters(j,:) = {arg};
        end      
end
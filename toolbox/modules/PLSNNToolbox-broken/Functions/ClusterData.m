function DataStruct = ClusterData(markers,DataStruct)
        s = "Calculate DataStruct"

        % *********************************************************
        % CLUSTER THE DATA
        kMatrix = [markers(:,1),markers(:,2),markers(:,3),markers(:,4),markers(:,5)];
        % Assign a cluster id to each sample point
        % Calculate the center C for each cluster
        [idCluster,C] = kmeans(kMatrix,DataStruct.numClusters);
        % *********************************************************
        
        % Update the structure DataStruct
        % Assign IDs and centers to DataStruct
        DataStruct.idCluster = idCluster;
        DataStruct.clusterCenters = C;

        % clusterLabels = 1,2,3,4,5
        clusterLabels = unique(idCluster);
        clusterLabels = clusterLabels(~isnan(clusterLabels));
        DataStruct.clusterLabels = clusterLabels;
        idCluster
        idCluster = idCluster(~isnan(idCluster))

        C = categorical(idCluster,clusterLabels);
        DataStruct.numSamplesEachCluster = histcounts(C);

        % Separate Clusters
        indCluster = zeros(DataStruct.numSamples,DataStruct.numBiomarkers,DataStruct.numClusters);
        for i = 1:DataStruct.numSamples
            for j=1:DataStruct.numClusters
                if(idCluster(i) == j)
                    indCluster(i,:,j) = DataStruct.biomarkers(i,:);
                end
            end
        end

        %  Divide data into individual clusters
        DataStruct.individualClusters = {};
        for j=1:DataStruct.numClusters
            arg = indCluster(:,:,j);
            idx = (arg == 0);
            [delRows,~] = find(idx);
            arg(delRows,:) = [];
            DataStruct.individualClusters(j,:) = {arg};
        end
    end
function DataStruct = CreateDataStruct()
        %s = " Make all data have sample length = numSamples"
        
        hyperStructClusters = HyperStructClusters();
        numClusters = hyperStructClusters.numClusters;
        
        clusterStruct = load("ClusterInput/clusterStructR.mat"); %*******************************
        L = length(clusterStruct.yD);
        for i=1:L
            T(i,:) = clusterStruct.T(i,:);
        end
        DataStruct = CollectData(T,clusterStruct); % Normalize data to std
        DataStruct.numClusters = numClusters;
    end
    
    
    
    function DataStruct = CollectData(T,clusterStruct)
        %s = " Form the data structure"

        DataStruct.T = T;
        
        % Calculate number of samples
        xName = "EGFR_1";
        EGFR_1 = DataGeneratingRoutineForBasisFunctions(xName,T);
        DataStruct.numSamples = length(EGFR_1);
        numSamples = DataStruct.numSamples;
        
        % Biomarkers plus yD and YNN
        DataStruct.biomarkerNames = ["yD","yNN","EGFR_1","UACR_1","ADIPOQ_LUM_num_1","ICAM1_LUM_num_1","BMI_1","SBP_1","DBP_1","HBA1C_1","TOTCHOL_1","HB_1","AGEV_1"];
        DataStruct.numBiomarkers = length(DataStruct.biomarkerNames);
        numBiomarkers = DataStruct.numBiomarkers;
        DataStruct.biomarkers = zeros(numSamples,numBiomarkers);
        
        DataStruct.mean_Biomarkers = zeros(1,numBiomarkers);
        DataStruct.std_Biomarkers = zeros(1,numBiomarkers);
        
        DataStruct.biomarkers(:,1) = clusterStruct.yD;
        yD = DataStruct.biomarkers(:,1);
        mean_yD = mean(yD);
        DataStruct.mean_Biomarkers(1) = mean_yD;
        std_yD = std(yD);
        DataStruct.std_Biomarkers(1) = std_yD;
        
        DataStruct.biomarkers(:,2) = clusterStruct.yNN;
        yNN = DataStruct.biomarkers(:,2);
        mean_yNN = mean(yNN);
        DataStruct.mean_Biomarkers(2) = mean_yNN;
        std_yNN = std(yNN);
        DataStruct.std_Biomarkers(2) = std_yNN;
        
        xName = "EGFR_1";
        j=3;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy); 
        
        xName = "UACR_1";
        j=4;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "ADIPOQ_LUM_num_1";
        j=5;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "ICAM1_LUM_num_1";
        j=6;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "BMI_1";
        j=7;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "SBP_1";
        j=8;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "DBP_1";
        j=9;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "HBA1C_1";
        j=10;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "TOTCHOL_1";
        j=11;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "HB_1";
        j=12;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
        xName = "AGEV_1";
        j=13;
        DataStruct.biomarkers(:,j) = DataGeneratingRoutineForBasisFunctions(xName,T);
        yy = DataStruct.biomarkers(:,j);
        DataStruct.mean_Biomarkers(j) = mean(yy); 
        DataStruct.std_Biomarkers(j) = std(yy);
        
            

        DataStruct.biomarkersNorm = DataStruct.biomarkers * 0;
        for i=1:numSamples
            for j=1:numBiomarkers
                DataStruct.biomarkersNorm(i,j) = (DataStruct.biomarkers(i,j) - DataStruct.mean_Biomarkers(j)) / DataStruct.std_Biomarkers(j);
            end
        end
    end
    
function DataStruct = SelectDataInWindow(DataStruct)
        outMatrix = readmatrix('MasterOutput/OutMatrixR.csv');
        yNNTestArray = outMatrix(:,1);
        yDTestArray = outMatrix(:,2);
        ii = 1;
        for i=1:DataStruct.numSamples
            if(yDTestArray(i) >= DataStruct.window.yDmin)
                if(yNNTestArray(i) >= DataStruct.window.yNNmin)
                    if(yDTestArray(i) <= DataStruct.window.yDmax)
                        if(yNNTestArray(i) <= DataStruct.window.yNNmax)
                            DataStruct.window.biomarkersWindow(ii,1) = yDTestArray(i);
                            DataStruct.window.biomarkersWindow(ii,2) = yNNTestArray(i);
                            DataStruct.window.visitID(ii) = i;
                            DataStruct = AddToWindowData(ii,i,DataStruct);
                            ii = ii + 1;
                        end
                    end
                end
            end
        end
        for j=1:length(DataStruct.biomarkerNames)
            DataStruct.window.mean(j) = mean(DataStruct.window.biomarkersWindow(:,j));
            DataStruct.window.std(j) = std(DataStruct.window.biomarkersWindow(:,j));
            DataStruct.window.biomarkersNorm(:,j) = (DataStruct.window.biomarkersWindow(:,j) - DataStruct.window.mean(j)) / DataStruct.window.std(j) ;
        end
        DataStruct.window.numSamples = length(DataStruct.window.biomarkersNorm(:,1));
    end
    
    
    function DataStruct = AddToWindowData(ii,i,DataStruct)
        DataStruct.window.numBiomarkers = length(DataStruct.biomarkerNames);
        for j=3:DataStruct.window.numBiomarkers
            xName = DataStruct.biomarkerNames(j);
            T = DataStruct.T;
            xx = DataGeneratingRoutineForBasisFunctions(xName,T);
            DataStruct.window.biomarkersWindow(ii,j) = xx(i);
        end
    end
        
    
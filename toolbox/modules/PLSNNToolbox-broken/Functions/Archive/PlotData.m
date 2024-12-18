
    function [xNN,yNN,RMSENN] = PlotData(T,yD,yPLS,RMSEPLS,numBasis,numSamples)
        % Called from IterateModels
        
        %s = "PlotData"

        % Neural Network
        [xNN,yNN,RMSENN] = CreateDataForPlots_NN1(T,yD,yPLS,RMSEPLS,numBasis,numSamples);
 
    end
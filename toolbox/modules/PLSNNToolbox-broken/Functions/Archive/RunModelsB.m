function DataStruct = RunModelsB(DataStruct) % Read data, call the regression routines
        %s = "RunModels"
        
        hyperStruct = DataStruct.hyperStruct ;
        TName = DataStruct.TName ;
 
        % T is the chosen data set for drug T
        % xNameData is the list of markers from T to use as inputs to PLS
        DataStruct = CrossValidation(DataStruct); % ********************

        xNameDataSet = hyperStruct.xNameDataSet;
        xNameData = hyperStruct.xNameData;
        
        explanationPLS = DataStruct.explanationPLS;
        explanationPLS = transpose(explanationPLS);
        SPLS.ExpPLS = [explanationPLS];
        TExpPLS = struct2table(SPLS);
        
        WriteOutputTables(TName,xNameDataSet,TExpPLS);

        NNCubeFlag = hyperStruct.NNCubeFlag;
        if(NNCubeFlag)
            yNameCube = ["yD2","yD3"];
            xNameData = [xNameData,yNameCube];
        end

        xNameDataS = transpose(xNameData);
        vipScore = DataStruct.vipScore;
        TVIP = table(xNameDataS(:,1),vipScore(:,1));
        writetable(TVIP,'Graphs/VIPScores.csv');

        % Calculate quality parameters for all the models
        TOut = QualityOfFit(DataStruct); % Calculate quality parameters;
        DataStruct.TOut = TOut; % ********************
        % PLOT OUTPUT
            Plots(DataStruct); % ********************
end
    

    
    function WriteOutputTables(TName,xNameDataSet,TExpPLS)
        if(xNameDataSet == "xNameE0ShortList")
            if(TName == "TR")
                writetable(TExpPLS,'Graphs/ExplanationPLS_R_E.csv');
            elseif(TName == "TG")
                writetable(TExpPLS,'Graphs/ExplanationPLS_G_E.csv');
            elseif(TName == "TM")
                writetable(TExpPLS,'Graphs/ExplanationPLS_M_E.csv');
            elseif(TName == "TS")
                writetable(TExpPLS,'Graphs/ExplanationPLS_S_E.csv');
            end
        end
        
        if(xNameDataSet == "xNameJoinedList")
            if(TName == "TR")
                writetable(TExpPLS,'Graphs/ExplanationPLS_R_J.csv');
                %writetable(TExpNN,'Graphs/ExplanationNN_R_J.csv');
            elseif(TName == "TG")
                writetable(TExpPLS,'Graphs/ExplanationPLS_G_J.csv');
            elseif(TName == "TM")
                writetable(TExpPLS,'Graphs/ExplanationPLS_M_J.csv');
            elseif(TName == "TS")
                writetable(TExpPLS,'Graphs/ExplanationPLS_S_J.csv');
            end
        end
    end
    
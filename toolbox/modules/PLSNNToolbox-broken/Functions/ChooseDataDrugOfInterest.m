function DataStruct = ChooseDataDrugOfInterest(treatment,DataStruct) % Input Drug Treatment, TR, TG , TM , or TS
        % SELECT INPUT VARIABLES
        % This routine defines a set of marker names that will be put into
        % a short list of markers to examine.
        % xNameE0ShortList is the basic set of continuous variables from
        % experts
        % xNameJoinedList is the total set of continuous variables from
        % PROVALID
        [TR,TG,TM,TS] = ReadDataIntoTables1(); % Read in data
        DataStruct.AllInputData = {TR,TG,TM,TS}; % Put data into dataStruct
        %DataStruct.T = treatment;% CHOOSE the data for the drug of interest
        DataStruct.TName = treatment;
        if(treatment == "TR")
            DataStruct.T = TR;
        elseif(treatment == "TG")
            DataStruct.T = TG;
        elseif(treatment == "TM")
            DataStruct.T = TM;
        elseif(treatment == "TS")
            DataStruct.T = TS;
        end
end
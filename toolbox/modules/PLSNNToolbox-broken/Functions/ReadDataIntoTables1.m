function [TR,TG,TM,TS] = ReadDataIntoTables1()
        % HiFU means number of total fllow-ups is four or greater
        % R stands for RASI only
        % G stands for RASI + GLP-1
        % R stands for RASI + SGLT2i
        % G stands for RASI + MACR
        TR = readtable('DebDataWithID_R.csv');
        TG = readtable('DebDataWithID_G.csv');
        TM = readtable('DebDataWithID_M.csv');
        TS = readtable('DebDataWithID_S.csv');
    end
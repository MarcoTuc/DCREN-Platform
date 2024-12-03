function [TR,TS,TM,TG] = ReadDataIntoTablesExplore()
        % HiFU means number of total fllow-ups is four or greater
        % R stands for RASI only
        % G stands for RASI + GLP-1
        TR = readtable('221213_R.csv');
        TG = readtable('221215_G.csv');
        TS = readtable('221215_S.csv');
        TM = readtable('221215_M.csv');
    end
function [TCDR,TUCDR,TCDG,TUCDG,TCDS,TUCDS,TCDM,TUCDM,TR] = ReadDataIntoTables()
        % HiFU means number of total fllow-ups is four or greater
        % R stands for RASI only
        % G stands for RASI + GLP-1
        TCDR = readtable('221210_CD_R.csv');
        TUCDR = readtable('221210_UCD_R.csv');
        TCDG = readtable('221210_CD_G.csv');
        TUCDG = readtable('221210_UCD_G.csv');
        TCDS = readtable('221210_CD_S.csv');
        TUCDS = readtable('221210_UCD_S.csv');
        TCDM = readtable('221210_CD_M.csv');
        TUCDM = readtable('221210_UCD_M.csv');
        TR = readtable('221213_R.csv');
    end
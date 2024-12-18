
function xCenterPLSTest = CalculateCentersPLSTest(yFPLS,RMSEPLS1)
        L = length(yFPLS);
        xCenterPLSTest = yFPLS(L) / RMSEPLS1;
end




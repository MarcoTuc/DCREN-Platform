function [xTestExp] = CreateTestingForExp(T,yFPLS,RMSEPLS1)
    %s = "CreateTestingForExp"

    xCenterControlledTest = CalculateCentersControlledUncontrolledTest(T);

    xCenterPLSTest = CalculateCentersPLSTest(yFPLS,RMSEPLS1);
        
    xTestExp = [xCenterControlledTest,xCenterPLSTest];
end

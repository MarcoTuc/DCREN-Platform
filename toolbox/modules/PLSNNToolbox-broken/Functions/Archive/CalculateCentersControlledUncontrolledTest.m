function xCenterControlledTest = CalculateCentersControlledUncontrolledTest(T)
    xName = "x"; % Name of the column in the data that holds the controlled/uncontrolled flag
    x_CD_UCD = DataGeneratingRoutineForBasisFunctions(xName,T);
    L = length(x_CD_UCD);

        if(x_CD_UCD(L) == "controlled")
                xCenterControlledTest = -1;
            else
                xCenterControlledTest = 1;
        end
    den = 1;
    xCenterControlledTest = xCenterControlledTest / den;
    return
end


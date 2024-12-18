function x = DataGeneratingRoutineForBasisFunctions(xName,T)
        if(xName == "TC_1")
            s = "DataGeneratingRoutineForBasisFunctions"
        end
        x1 = T(:,xName);
        x = table2array(x1);
end


    
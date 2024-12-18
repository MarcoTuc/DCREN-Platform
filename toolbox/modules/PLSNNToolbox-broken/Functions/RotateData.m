function T = RotateData(T)
    xName = "EGFR_1";
    xD = DataGeneratingRoutineForBasisFunctions(xName,T);
    L = length(xD);
    TNew = T;
    for i=2:L
        TNew((i-1),:) = T(i,:);
    end
    TNew(L,:) = T(1,:);
    T = TNew;
end

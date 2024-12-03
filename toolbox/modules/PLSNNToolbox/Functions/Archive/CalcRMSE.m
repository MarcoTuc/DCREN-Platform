function RMSE = CalcRMSE(yD,yFit)
    %s = "Entering CalcRMSE"
    R = yD - yFit;
    RMSE = rms(R);
end

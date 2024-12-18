    % **************************************************************************** 
    % Parameters
    % **************************************************************************** 
    
% Parameters for basis functions
%%
function [betaScale,yStar,yHat,ai0,nu] = RBNParameters(T)
    betaScale = 1;
    %xi =1;
    beta = [ 118.2790, -0.9077, 0.0, -0.0010, -0.0713, -31.4884 ];  
    
    xName1 = "DEGFR_2";
    xInput = DataGeneratingRoutineForBasisFunctions(xName1,T);

    yName = "DEGFR_2";
    yStar = DataGeneratingRoutineForBasisFunctions(yName,T);
    yStar = transpose(yStar);
    yHat0 = 1;
    L = length(yStar);
    yHat = yHat0 * ones(1,L);
    error = yStar - yHat;
    ai0 = ones(length(xInput),1);
    nu = 0.1;
end




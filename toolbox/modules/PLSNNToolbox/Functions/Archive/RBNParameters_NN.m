    % **************************************************************************** 
    % Parameters
    % **************************************************************************** 
    
% Parameters for basis functions
%%
function [betaScale,yStar,nu] = RBNParameters_NN(T)

    betaScale = 1; 

    yName = "DEGFR_2";
    yStar = DataGeneratingRoutineForBasisFunctions(yName,T);
    yStar = transpose(yStar);
    nu = 0.1;
end




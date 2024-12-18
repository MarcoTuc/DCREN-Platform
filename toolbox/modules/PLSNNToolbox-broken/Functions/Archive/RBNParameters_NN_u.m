    % **************************************************************************** 
    % Parameters
    % **************************************************************************** 
    
% Parameters for basis functions
%%
function [betaScale,nu,numBasis,xName,checkThreshold] = RBNParameters_NN_u(T)
    betaScale = 1; 
    numBasis = 30; % Default value for S,G,M
    xName = "EGFR_1";
    yName = "DEGFR_2";
    nu = 0.1;
    checkThreshold = 100;
end




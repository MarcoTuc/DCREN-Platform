
function xCenterPLS = CalculateCentersPLS(yPLS,RMSEPLS,numSamples)
    % Called from  CreateTrainingForExp
    % Picks centers from first numbasis values of yPLS
    %L  = numSamples + 1;
    xCenterPLS = zeros(numSamples,1);
    for i=1:numSamples
        xCenterPLS(i) = yPLS(i) / RMSEPLS;
    end
end




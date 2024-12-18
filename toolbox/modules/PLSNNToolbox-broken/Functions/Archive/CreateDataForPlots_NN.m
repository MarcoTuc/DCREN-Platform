% Create Data for Plots
    function [xHatPlot,yHatTime,errorRMS] = CreateDataForPlots_NN(T,yFPLS,numBasis,numSamples)
        s = "CreateDataForPlots_NN"
    
        yFPLS = transpose(yFPLS);

        [betaScale,yStar,nu,numBasis,xName] = RBNParameters_NN_u(T);
 
        % Retrieve the EGFR data
        xName1 = "EGFR_1"; % The EGFR at visit 1
        xEGFR = DataGeneratingRoutineForBasisFunctions(xName1,T);
        xEGFR = transpose(xEGFR);

        % Create the basis centers
        xExp = CreateBasisCenters(T,numBasis,yFPLS);
        xTrainExp = CreateTrainingForExp(T,yFPLS);

        % Train the network
        [ai,yHatTime] = Training(T,xExp,yFPLS);
        
        %L = length(xEGFR);
        yHatTime = zeros(1,numSamples);

        for j=1:numSamples % Calculate predicted values of output
            yHatTime(j) = ExpectationOfY(T,xTrainExp(j,:),xExp,ai,yFPLS);
        end

        xHatPlot = xEGFR;
        
        s = "NN"
        RMSE = CalculateRMSE(yStar,xEGFR,yHatTime,T);
        
        errorY = yStar - yHatTime;
        errorRMS = rms(errorY);  
        
        s = "end CreateDataForPlots_NN"
    end
    
    
    
    % **************************************************************************** 
    % Training Algorithms
    % **************************************************************************** 

    % Expectation Value of output
    function yHat = ExpectationOfY(T,x,xExp,ai,yFPLS)

        [betaScale,yStar,nu,numBasis,xName] = RBNParameters_NN_u(T);
        
        numBasis = length(xExp(:,1));
       
        u = NormalizedBasisFunction(T,x,xExp);
        arg = zeros(1,numBasis);
        for i=1:numBasis
            arg(i) = ai(i) * yFPLS(i) * u(i);
        end
        
        yHat = sum(arg);
    end

    
    % Train the data set
    function [ai,yHatTime] = Training(T,xExp,yFPLS)
    
    
        
        numBasis = length(xExp(:,1));
        yHatTime = zeros(1,numBasis);
        ai =  ones(1,numBasis);
        for j = 1:numBasis
            x = xExp(j,:);
            ai = LearningRoutine(ai,T,x,xExp,yFPLS);
            yHatTime(j) = ExpectationOfY(T,x,xExp,ai,yFPLS);
           
            break;
        end
        yHatTime;
    end


function ai = LearningRoutine(ai,T,x,xExp,yFPLS)

    [betaScale,yStar,nu,numBasis,xName] = RBNParameters_NN_u(T);
    
    numBasis = length(xExp(:,1));
    xName = "EGFR_1";
    xSample = DataGeneratingRoutineForBasisFunctions(xName,T);
    numSamples = length(xSample) % Number of samples
    
    u = NormalizedBasisFunction(T,x,xExp);
    yStarBasis = zeros(1,numBasis);
    for i=1:numBasis
        yStarBasis(i) = yFPLS(i);
    end
    
    for j=1:numSamples
    v = yStarBasis .* u;
    den = dot(v,v);
    projectionFactor = v / den;
    yHat = ExpectationOfY(T,x,xExp,ai,yFPLS);
    
        error = yStar(j) - yHat;
        dai = nu * error .* projectionFactor;
        ai = ai + dai;
        yHat = ExpectationOfY(T,x,xExp,ai,yFPLS);
    end
end


% Creation of basis functions
function u = NormalizedBasisFunction(T,x,xExp)

    rho = UnnormalizedBasisFunction(T,x,xExp);
    den = sum(rho);
    u = rho / den;
    check = sum(u);
end


% Unnormalized Basis Function
function rho = UnnormalizedBasisFunction(T,x,xExp)
    
    [betaScale,yStar,nu,numBasis,xName] = RBNParameters_NN_u(T);
    
    numBasis = length(xExp(:,1));
    
    rho = zeros(1,numBasis);
    tiny = 1e-6;
    for i=1:numBasis
            dxCenters = x - xExp(i,:);
            arg = - betaScale * dot(dxCenters,dxCenters);
            rho(i) = exp(arg);
            rho(i) = max(rho(i),tiny);
    end   
end


function xTrainExp = CreateTrainingForExp(T,yFPLS)
    numSample = length(yFPLS);
    xCenterControlled = CalculateCentersControlledUncontrolled(T,numSample);
    xCenterControlled = transpose(xCenterControlled);
    xCenterPLS = CalculateCentersPLS(yFPLS,numSample);
    xTrainExp = [xCenterControlled,xCenterPLS];
end


function xExp = CreateBasisCenters(T,numBasis,yFPLS)
    xCenterControlled = CalculateCentersControlledUncontrolled(T,numBasis);
    xCenterControlled = transpose(xCenterControlled);
    xCenterPLS = CalculateCentersPLS(yFPLS,numBasis);
    xExp = [xCenterControlled,xCenterPLS];
end


function xCenterControlled = CalculateCentersControlledUncontrolled(T,numBasis)
    xName = "TC_1";
    x_CD_UCD = DataGeneratingRoutineForBasisFunctions(xName,T);
    
    xCenterControlled = zeros(numBasis,1);
    for i=1:numBasis
        if(x_CD_UCD(i) == "controlled")
                xCenterControlled(i) = -1;
            else
                xCenterControlled(i) = 1;
        end
    end
    den = 1;
    xCenterControlled = xCenterControlled / den;
    xCenterControlled = transpose(xCenterControlled);
end


function xCenterPLS = CalculateCentersPLS(yFPLS,numBasis)
    xCenterPLS = zeros(numBasis,1);
    for i=1:numBasis
        xCenterPLS(i) = yFPLS(i);
    end
end







    function [xNN,yNN,RMSENN] = CreateDataForPlots_NN1(T,yD,yPLS,RMSEPLS,numBasis,numSamples)
        % Called from PlotData
        
        %s = "CreateDataForPlots_NN1"

        yPLS = transpose(yPLS);
 
        % Retrieve the EGFR data
        xName1 = "EGFR_1"; % The EGFR at visit 1
        xEGFR = DataGeneratingRoutineForBasisFunctions(xName1,T);
        xEGFRCV = zeros(numSamples,1);
        for j=1:numSamples
            xEGFRCV(j) = xEGFR(j);
        end
        
        xNN = transpose(xEGFRCV);

        % Create the basis centers
        xExp = CreateBasisCenters(T,numBasis,yPLS,RMSEPLS); % Set up the basis centers
        xTrainExp = CreateTrainingForExp(T,yPLS,RMSEPLS); % 

        % Train the network
        ai =  ones(1,numBasis); % ai is a horizontal vector of length numBasis
        [ai,yNN] = Training(T,xExp,yPLS,RMSEPLS,ai); % Train the data for the NN

        yHatTime = zeros(1,numSamples);
        for j=1:numSamples % Calculate predicted values of output
            yHatTime(j) = ExpectationOfY(T,xTrainExp(j,:),xExp,ai,yPLS);
        end

        errorY = yD - yNN;
        RMSENN = rms(errorY);
    end
    
    
    
    % **************************************************************************** 
    % Training Algorithms
    % **************************************************************************** 

    % Train the data set
    function [ai,yHatTime] = Training(T,xExp,yFPLS,RMSEPLS1,ai)
    
        [betaScale,yStar,nu] = RBNParameters_NN_u(T);
        
        [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn] = SpecifyBasisSamples(T);

        [xTrainExp,yFPLS] = CreateTrainingForExp(T,yFPLS,RMSEPLS1); % Centers for basis functions. Includes all samples. [numSamples,2]
  
        yHatTime = zeros(1,numSamples);

        for k = 1:numCyclesThroughTrainingData
            for j = 1:numSamples
                x = xTrainExp(j,:); % x is a 2D vector used as basis center for sample j
                y = yFPLS(j);
                ai = LearningRoutine(ai,T,j,x,y,xExp,yFPLS);
                yHatTime(j) = ExpectationOfY(T,x,xExp,ai,yFPLS);
            end
        end
        ai;
        yHatTime;
    end


function ai = LearningRoutine(ai,T,j,x,y,xExp,yFPLS)

    [betaScale,yStar,nu] = RBNParameters_NN_u(T);
    
    [numBasis,numSamples,ncomp,nameControlColumn] = SpecifyBasisSamples(T);
    
    u = NormalizedBasisFunction(T,x,xExp); % u is a horizontal vector of length numBasis
    
    yStarBasis = y; % yStarBasis is a vertical vector of length numSamples
    
    v = yStarBasis * u; % v is a horizontal vector of length numBasis
    den = dot(v,v);
    projectionFactor = v / den; % projectionFactor is a horizontal vector of length numBasis
    yHat = ExpectationOfY(T,x,xExp,ai,yFPLS); % yHat is a scalar
    error = yStar(j) - yHat;
    
    nu;
    error;
    v;
    sqrden = sqrt(den);
    projectionFactor;
    dai = nu * error .* projectionFactor; % dai is a horizontal vector of length numBasis
    ai = ai + dai; % ai is a horizontal vector of length numBasi
end









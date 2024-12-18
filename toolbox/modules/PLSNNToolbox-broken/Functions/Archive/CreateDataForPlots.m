% Create Data for Plots
    function [xHatPlot,yHatTime,errorRMS] = CreateDataForPlots(T,xiPLS)
        %s = "Entering CreateDataForPlots"
        
        xiPLS
        
        % Generate the basis function centers xi, the initial estimate for
        % the neural net output yHat, and the actual output for the input
        
        [betaScale,yStar,yHat,ai0,nu] = RBNParameters(T);
        
        xi = xiPLS;
        xiT = transpose(xi);

        % Train the network
        [ai,yHatTime] = Training(T,xi);
                
        xName1 = "EGFR_1"; % The EGFR at visit 1
        xData = DataGeneratingRoutineForBasisFunctions(xName1,T);
        xData = transpose(xData);

        %xiT = transpose(xi);
        L = length(xData);
        yHatTest = zeros(1,L);
        error = zeros(1,L);
        
        for j=1:L % Calculate predicted values of output
            j;
            yHatTime(j) = ExpectationOfY(j,xiT(:,j),ai,yStar,T,xiPLS);
        end

        xHatPlot = xData;
        
        errorY = yStar - yHatTest;
        errorRMS = rms(errorY);     
    end
    
    
    
    % **************************************************************************** 
    % Training Algorithms
    % **************************************************************************** 

    % Expectation Value
    function yHat = ExpectationOfY(j,xjj,ai,yStar,T,xiPLS)
        u = NormalizedBasisFunction(j,xjj,T,xiPLS);
        u = transpose(u);
        yStarT = transpose(yStar);
        arg = ai .* yStarT .* u;
        
        yHat = sum(arg);
    end


    function [ai,yHatTime] = Training(T,xiPLS)
        [betaScale,yStar,yHat,ai0,nu] = RBNParameters(T);
        xi = xiPLS;
        ai0 = ones(length(xi),1);
        ai = ai0;
        xiT = transpose(xi);
        L = length(xiT(1,:));
        yHatTime = ones(1,L);
        for j = 1:L
            ai = LearningRoutine(ai,j,xiT(:,j),yStar,nu,T,xiPLS);
            yHatTime(j) = ExpectationOfY(j,xiT(:,j),ai,yStar,T,xiPLS);
            ai;
            yHatTime(j);
            %error = yStar(j) - yHatTime(j)
        end
end


function ai = LearningRoutine(ai,j,xjj,yStar,nu,T,xiPLS)
    yStarT = transpose(yStar);
    u = NormalizedBasisFunction(j,xjj,T,xiPLS);
    v = yStarT .* u;
    den = dot(v,v);
    projectionFactor = v / den;
    yHat = ExpectationOfY(j,xjj,ai,yStar,T,xiPLS);
    error = yStar(j) - yHat;
    dai = nu * error * projectionFactor;
    ai = ai + nu * error * projectionFactor;
end


% Creation of basis functions
function u = NormalizedBasisFunction(j,xjj,T,xiPLS)

    [betaScale,yStar,yHat,ai0,nu] = RBNParameters(T);
    
    xi = xiPLS;
    rho = UnnormalizedBasisFunction(betaScale,j,xjj,xi);
    den = sum(rho);
    u = rho / den;
    check = sum(u);
end


% Unnormalized Basis Function
function rho = UnnormalizedBasisFunction(beta,j,xjj,xi)
    xnj = transpose(xjj);
    xnj = min(11,xnj);
    L = length(xi(:,1));
    rho = zeros(1,L);
    for i=1:L
        
        xni = xi(i,:);
        xni = min(11,xni);
        xni = max(-11,xni);
        
        dx = xnj - xni;
        arg = - beta * dot(dx,dx);
        rho(i) = exp(arg);
        tiny = 1e-6;
        rho(i) = max(rho(i),tiny);
    end
end




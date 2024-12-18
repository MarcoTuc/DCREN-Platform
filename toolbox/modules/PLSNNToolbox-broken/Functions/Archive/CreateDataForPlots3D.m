% Create Data for Plots
    function [xHatPlot,yHatPlot,zHatTest,errorY,errorRMS] = CreateDataForPlots3D(T,scenario,xiPLS,addMarker)
        s = "Entering CreateDataForPlots"
    
        % Generate the basis function centers xi, the initial estimate for
        % the neural net output yHat, and the actual output for the input
        % xi
        [beta,xi,zStar,yHat,ai0,nu] = RBNParameters(T,scenario);
        xi = xiPLS;
        
        
        zStarT = transpose(zStar) ;

        [ai,zTrained] = Training3D(T,scenario,xiPLS);
        
        xName1 = "EGFR_1"; % The EGFR at visit 1
        xData = DataGeneratingRoutineForBasisFunctions(xName1,T);
        xData = transpose(xData);
        
        yName1 = addMarker;
        yData = DataGeneratingRoutineForBasisFunctions(yName1,T);
        yData = transpose(yData);
        
        xiT = transpose(xi);
        L = length(xData);
        zHatTest = zeros(L,1);
        error = zeros(L,1);
        
        
        for j=1:L % Train the neural network
            zHatTest(j) = ExpectationOfY3D(j,xiT(:,j),ai,zStar,T,scenario,xiPLS);
        end
        
        xHatPlot = xData(1,:);
        yHatPlot = yData(1,:);
        zHatTest;
        errorY = zStarT - zHatTest;
        
        errorRMS = rms(errorY);
        
    end
    

     % **************************************************************************** 
    % Training Algorithms
    % **************************************************************************** 

    % Expectation Value
    function yHat = ExpectationOfY3D(j,xjj,ai,zStar,T,scenario,xiPLS)
        u = NormalizedBasisFunction3D(j,xjj,T,scenario,xiPLS);
        u = transpose(u);
        zStarT = transpose(zStar);
        arg = ai .* zStarT .* u;
        yHat =sum(arg);
    end

    
    
    function [ai,zHatTime] = Training3D(T,scenario,xiPLS)
    [beta,xi,zStar,yHat,ai0,nu] = RBNParameters(T,scenario);
    xi = xiPLS;
    
    ai = ai0;
    
    xj = transpose(xi);
    L = length(xj(1,:));
    zHatTime = ones(1,L);
    for j = 1:L
        ai = LearningRoutine(ai,j,xj(:,j),zStar,nu,T,scenario,xiPLS);
        zHatTime(j) = ExpectationOfY3D(j,xj(:,j),ai,zStar,T,scenario,xiPLS);
        ai;
        zHatTime(j);
    end
    ai;
    zHatTime;
end


function ai = LearningRoutine(ai,j,xjj,zStar,nu,T,scenario,xiPLS) % Weight ai training
    zStarT = transpose(zStar);
    u = NormalizedBasisFunction3D(j,xjj,T,scenario,xiPLS);
    v = zStarT .* u;
    den = dot(v,v);
    projectionFactor = v / den;
    yHat = ExpectationOfY3D(j,xjj,ai,zStar,T,scenario,xiPLS);
    error = zStar(j) - yHat;
    dai = nu * error * projectionFactor;
    ai = ai + nu * error * projectionFactor;
end





% Creation of basis functions
function u = NormalizedBasisFunction3D(j,xjj,T,scenario,xiPLS)

    [beta,xi,zStar,yHat,ai0,nu] = RBNParameters(T,scenario);
    xi = xiPLS;
    
    rho = UnnormalizedBasisFunction(beta,j,xjj,xi);
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
    rho;
end


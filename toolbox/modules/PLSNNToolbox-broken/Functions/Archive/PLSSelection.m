function [xF,yF,xiPLS,residuals,betaPLS] = PLSSelection(T,xName) % Runs the Partial Least Squares algorithm on the inputs defined by xName
    %s = "PLSSelection"
    
    xName;
    yName = "DEGFR_2"; % The value of DEGFR at visit 1
    yD = DataGeneratingRoutineForBasisFunctions(yName,T);
    
    [numBasis,numSamples,ncomp] = SpecifyBasisSamples(T);
    
    [xF,yF,xiPLS,residuals,betaPLS] = PLSR(xName,yD,T,ncomp); % Call the PLSR routine

end



function [xF,yF,xiPLS,residuals,betaPLS] = PLSR(xName,yD,T,ncomp)
    %s = "PLSR"
    
    

    L = length(yD); % Number of samples
    
    X = zeros(L,ncomp); % Initialize the input matrix
    for j=1:ncomp % Create input matrix X
        X(:,j) = DataGeneratingRoutineForBasisFunctions(xName(j),T); % Grab the raw data 
    end
    X(isnan(X)) = 0; % Deal with NaN

    [XL,yl,XS,YS,betaPLS,PCTVAR,MSE,stats] = plsregress(X,yD,ncomp); % Call the internal MATLAB PLS function
    
    pct = cumsum(100*PCTVAR(2,:));  % Calculate the degree of explanation vs number of components

    [xF,yF,xiPLS] = FitData(X,yD,betaPLS); % Located in this file
    y = transpose(yD);
    
    %[RMSE1,RMSE2] = CalculateRMSE(yD,xF,yF,T);
    
    residuals = PlotResiduals(y,yF);
    %[vipScore,indVIP] = PlotVIPScore(XL,XS,yl,stats);
    %s = "end PLSR"

end





function [xfit,yfit,xiPLS] = FitData(X,y,betaPLS) % Fit the data
    %s = "FitData"
    XX = [ones(size(X,1),1) X]; % The first column  is the y intercept
    yfit = XX * betaPLS;
    yy = XX .* transpose(betaPLS); % Create input data for neural network
    yy1 =  sum(yy(1,:)); % Check
    residual = y - yfit;
    xscale = rms(residual);
    xiPLS = yy / xscale;
    
    % Plot the fit
    yfit = transpose(yfit);
    xfit = X(:,1);
    %plot(xfit,yfit,'d');
    %xlabel('eGFR');
    %ylabel('% \Delta');
end



function [vipScore,indVIP] = PlotVIPScore(XL,XS,yl,stats) % Rank the inputs
    %s = "PlotVIPScore"
    W0 = stats.W ./ sqrt(sum(stats.W.^2,1));
    p = size(XL,1);
    sumSq = sum(XS.^2,1).*sum(yl.^2,1);
    vipScore = sqrt(p* sum(sumSq.*(W0.^2),2) ./ sum(sumSq,2));
    indVIP = find(vipScore >= 1);
    
    %scatter(1:length(vipScore),vipScore,'kx')
    %hold on
    %scatter(indVIP,vipScore(indVIP),'rx')
    %plot([1 length(vipScore)],[1 1],'--k')
    %hold off
    %axis tight
    %xlabel('Predictor Variables')
    %ylabel('VIP Scores')
    %s = " end PlotVIPScore"
end


function residuals = PlotResiduals(y,yfit) % Plot residuals
    %s = "residuals"
    residuals = y - yfit;
    RMSError = rms(residuals);
    %stem(residuals);
    %xlabel('Observations');
    %ylabel('Residuals');
    %s = "end residuals"
end



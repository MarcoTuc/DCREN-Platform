function DataStruct = PLSRegression(k,DataStruct)
        if(~DataStruct.hyperStruct.RASiAloneFlag)
            DataStruct.bPLSR = DataStruct.DataStructR.bPLS;
        end

        % Calculate the PLS regression with a polynomial term based on yD
        yCube = [DataStruct.yDNorm.^2, DataStruct.yDNorm.^3]; % 
        yCubeTest = [DataStruct.yDTestNorm.^2,DataStruct.yDTestNorm.^3]; %
        DataStruct.xP = [DataStruct.xDNorm, yCube];
        DataStruct.xTestP = [DataStruct.xDTestNorm, yCubeTest];
        %----------------------------------------------------
        [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(DataStruct.xP, DataStruct.yD, DataStruct.hyperStruct.ncomp); % Run PLS Regression
        DataStruct.vipScorePLS = transpose( VIPScores(XL,YL,XS,stats) );
        DataStruct.explanationPLS = VarianceExplanation(PCTVAR);
        %----------------------------------------------------
        DataStruct.bPLS = beta;
        DataStruct.xPLS = [ones(length(DataStruct.xP(:,1)), 1), DataStruct.xP];
        DataStruct.xTestPLS = [1, DataStruct.xTestP];
        DataStruct.yPLS = DataStruct.xPLS * beta;
        DataStruct.yTestPLS = DataStruct.xTestPLS * DataStruct.bPLS;
        DataStruct.yPLSTestArray(k) = DataStruct.yTestPLS;
        DataStruct.errorTestPLS(k) = DataStruct.yDTest - DataStruct.yTestPLS;
        DataStruct.vipScorePLS = VIPScores(XL,YL,XS,stats);
        DataStruct.explanationPLS = VarianceExplanation(PCTVAR);
        DataStruct = EvaluateRecurrentPLS(DataStruct); % Evaluate the arecurrent PLS network for the training set
end

function explanation = VarianceExplanation(PCTVAR)
    explanation = cumsum(100*PCTVAR(2,:));
end

function vipScore = VIPScores(XL,YL,XS,stats)
    W0 = stats.W ./ sqrt(sum(stats.W.^2,1));
    p = size(XL,1);
    sumSq = sum(XS.^2,1).*sum(YL.^2,1);
    vipScore = sqrt(p* sum(sumSq.*(W0.^2),2) ./ sum(sumSq,2));
end


function DataStruct = EvaluateRecurrentPLS(DataStruct)
    L = length( DataStruct.xPLS(1,:) );
    L1 = L - 1;
    yPLSEvalNorm = 0; % Initial guess for solution
    yCube1 = [yPLSEvalNorm.^2, yPLSEvalNorm.^3];
    xPLS1 = DataStruct.xPLS;
    xPLS1(:,L1) = yCube1(1);
    xPLS1(:,L) = yCube1(2);
    for i=1:10 % Iteratively update map to a fixed point
        yPLSApprox = xPLS1 * DataStruct.bPLS;
        yPLSApproxNorm = ( yPLSApprox - DataStruct.yDMean ) / DataStruct.yDStd;
        yCube1 = [yPLSApproxNorm.^2, yPLSApproxNorm.^3];
        xPLS1(:,L1) = yCube1(1);
        xPLS1(:,L) = yCube1(2);
    end
    DataStruct.yPLSApprox = yPLSApprox; % Approximation based on recurrence
    yPLSEval = DataStruct.xPLS * DataStruct.bPLS; % The evaluation of PLS for exact yD inputs for polynomial terms
    DataStruct.DyPLSApprox = yPLSEval - yPLSApprox; % Difference in recurrence evaluation approximation and perfect evaluation
end





function DataStruct = RunPLSRegression(DataStruct,xD,yD,ncomp) % Keep this around for spare parts
        %----------------------------------------------------
        [XL,YL,XS,YS,beta,PCTVAR,MSE,stats] = plsregress(xD, yD, ncomp); % Run PLS Regression
        %----------------------------------------------------
        bPLS = beta;
        yPLS = DataStruct.XXPLS * beta;
        yPLSTest = DataStruct.XXTestPLS * beta;
        errorTestPLS = DataStruct.yDTest - yPLSTest;
        vipScore = VIPScores(XL,YL,XS,YS,beta,PCTVAR,MSE,stats);
        explanationPLS = VarianceExplanation(DataStruct.hyperStruct.ncomp,PCTVAR); 
        DataStruct.yPLS = yPLS;
        DataStruct.yPLSTest = yPLSTest;
        DataStruct.errorTestPLS = errorTestPLS;
        DataStruct.bPLS = bPLS;
        if(DataStruct.hyperStruct.RASiAloneFlag)
            DataStruct.bPLSR = bPLS;
        else
            DataStruct.DelbPLSR = DataStruct.bPLS - DataStruct.bPLSR ;
        end
        xNameData = transpose(DataStruct.xNameData);
        xNameData = [DataStruct.xNameData, ["yD^2","yD^3"]];
        vipScore = transpose(vipScore);
        DataStruct.vipScore = vipScore;
        DataStruct.TVIP = table([xNameData; DataStruct.vipScore]);
        TVIP = DataStruct.TVIP;
        DataStruct.explanationPLS = explanationPLS;
end


function [yLR,errorTestLR,correlationMatrix] = LinearRegression(xD,xDTest,yD,yDTest)

        correlationMatrix = corrcoef(xD);
        
        [bLR,bint,r,rint,stats] = regress(yD,xD);
        yLR = xD * bLR;
        yLRTest = xDTest * bLR;
        
        errorTestLR = yDTest - yLRTest;
end


    


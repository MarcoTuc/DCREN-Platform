
    function yHat = ExpectationOfY(T,x,XX,xBasisCenters,ai,yPLS)
        XX
        
        [numBasis,numSamples,ncomp,nameControlColumn] = SpecifyBasisSamples(T);
       
        u = NormalizedBasisFunction(T,x,xBasisCenters);
        arg = zeros(1,numBasis);
        for i=1:numBasis
            arg(i) = ai(i) * yPLS(i) * u(i);
        end
        
        yHat = sum(arg);
    end


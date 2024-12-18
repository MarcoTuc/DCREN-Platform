function [numberOfSamples,sensitivity,specificity,accuracy] = SensitivitySpecificityAccuracy_NN(T,yD,yF)
    %s = "SensitivitySpecificityAccuracy_NN"

    % Calculate sensitivity, specificity, and accuracy
    
    [numBasis,numSamples,ncomp,numCrossValidation,numCyclesThroughTrainingData,nameControlColumn] = SpecifyBasisSamples(T);
   
    xName = nameControlColumn;

    xD = DataGeneratingRoutineForBasisFunctions(xName,T);
    yD;
    yF = transpose(yF) ;
    LyD = length(xD) - 1;

    % Total number of visits with CD at visit 1
    num_D_CD = 0;
    num_D_CD_CD = 0;
    num_F_CD_CD = 0;
    num_D_CD_UCD = 0;
    num_F_CD_UCD = 0;
    
    num_D_UCD = 0;
    num_D_UCD_CD = 0;
    num_F_UCD_CD = 0;
    num_D_UCD_UCD = 0;
    num_F_UCD_UCD = 0;
    
    % Calculate numbers for CD
    for i=1:LyD
         % Count numbers from initial visit of controlled disease
        if(xD(i) == "controlled")
            % Total number of actual controlled disease at visit 1
            num_D_CD = num_D_CD + 1;
                % Number of CD at visit 1 who are still CD at visit 2
                if(yD(i) > -5)
                        num_D_CD_CD = num_D_CD_CD + 1;
                        if(yF(i) > -5)
                                num_F_CD_CD = num_F_CD_CD + 1;
                        end
                end
                
                % Number of CD at visit 1 who have become UCD at visit 2
                if(yD(i) < -10)
                    num_D_CD_UCD = num_D_CD_UCD + 1;
                    if(yF(i) < -10)
                        num_F_CD_UCD = num_F_CD_UCD + 1;
                    end
                end
        end       
    end
    
    
    
    for i=1:LyD
        
         % Count numbers from initial visit of controlled disease
        if(xD(i) == "uncontrolled")
            % Total number of actual controlled disease at visit 1
            num_D_UCD = num_D_UCD + 1;
                % Number of CD at visit 1 who are still CD at visit 2
                if(yD(i) > -5)
                        num_D_UCD_CD = num_D_UCD_CD + 1;
                        
                        if(yF(i) > -5)
                            num_F_UCD_CD = num_F_UCD_CD + 1;
                        end
                end
  
                % Number of CD at visit 1 who have become UCD at visit 2
                if(yD(i) < -10)
                    num_D_UCD_UCD = num_D_UCD_UCD + 1;
                    if(yF(i) < -10)
                        num_F_UCD_UCD = num_F_UCD_UCD + 1;
                    end
                end
        end  
    end

    % Counts
    % CD
    num_D_CD;
    num_D_CD_CD;
    num_F_CD_CD;
    num_D_CD_UCD;
    num_F_CD_UCD;
    % UCD
    num_D_UCD;
    num_D_UCD_UCD;
    num_F_UCD_UCD;
    num_D_UCD_CD;
    num_F_UCD_CD;
    
    % Output to the routine
    numberOfSamples = NumberOfSamples( num_D_CD,num_D_UCD );
    sensitivity = Sensitivity(num_F_UCD_UCD,num_F_CD_UCD,num_D_UCD_UCD,num_D_CD_UCD);
    specificity = Specificity(num_F_CD_CD,num_F_UCD_CD,num_D_CD_CD,num_D_UCD_CD);
    accuracy = Accuracy( num_F_UCD_UCD,num_F_CD_UCD,num_F_CD_CD,num_F_UCD_CD,num_D_UCD_UCD,num_D_CD_UCD,num_D_CD_CD,num_D_UCD_CD);
  
end

function numberOfSamples = NumberOfSamples( num_D_CD,num_D_UCD )
    numberOfSamples = num_D_CD + num_D_UCD;
end

function sensitivity = Sensitivity(num_F_UCD_UCD,num_F_CD_UCD,num_D_UCD_UCD,num_D_CD_UCD)
    sensitivity = (num_F_UCD_UCD + num_F_CD_UCD) / (num_D_UCD_UCD + num_D_CD_UCD) ;
end

function specificity = Specificity(num_F_CD_CD,num_F_UCD_CD,num_D_CD_CD,num_D_UCD_CD)
    specificity = (num_F_CD_CD + num_F_UCD_CD) / (num_D_CD_CD + num_D_UCD_CD);
end

function accuracy = Accuracy( num_F_UCD_UCD,num_F_CD_UCD,num_F_CD_CD,num_F_UCD_CD,num_D_UCD_UCD,num_D_CD_UCD,num_D_CD_CD,num_D_UCD_CD)
    accuracy = (num_F_UCD_UCD + num_F_CD_UCD + num_F_CD_CD + num_F_UCD_CD) / (num_D_UCD_UCD + num_D_CD_UCD + num_D_CD_CD + num_D_UCD_CD);
end
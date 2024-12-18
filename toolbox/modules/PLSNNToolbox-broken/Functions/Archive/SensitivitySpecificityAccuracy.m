function [numberOfSamples,sensitivity,specificity,accuracy] = SensitivitySpecificityAccuracy(TCD,TUCD,yDCD,yFCD,yDUCD,yFUCD)

    % Calculate sensitivity, specificity, and accuracy
   
    xName = "x"
    
    % CD at visit 1 
    xCD = DataGeneratingRoutineForBasisFunctions(xName,TCD);
    yDCD;
    yFCD = transpose(yFCD); 
    LyCD = length(xCD)
    
    % UCD at visit 1
    xUCD = DataGeneratingRoutineForBasisFunctions(xName,TUCD);
    yDUCD;
    yFUCD = transpose(yFUCD); 
    LyUCD  = length(xUCD)

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
    for i=1:LyCD
         % Count numbers from initial visit of controlled disease
        if(xCD(i) == "controlled")
            
            % Total number of actual controlled disease at visit 1
            num_D_CD = num_D_CD + 1;

                % Number of CD at visit 1 who are still CD at visit 2
                if(yDCD(i) > -5)
                        num_D_CD_CD = num_D_CD_CD + 1;
                        if(yFCD(i) > -5)
                                num_F_CD_CD = num_F_CD_CD + 1;
                        end
                end
                
                % Number of CD at visit 1 who have become UCD at visit 2
                if(yDCD(i) < -10)
                    num_D_CD_UCD = num_D_CD_UCD + 1;
                    if(yFCD(i) < -10)
                        num_F_CD_UCD = num_F_CD_UCD + 1;
                    end
                end
        end       
    end
    
    
    
    for i=1:LyUCD
        
         % Count numbers from initial visit of controlled disease
        if(xUCD(i) == "uncontrolled")
            
            % Total number of actual controlled disease at visit 1
            num_D_UCD = num_D_UCD + 1;

                % Number of CD at visit 1 who are still CD at visit 2
                if(yDCD(i) > -5)
                        num_D_UCD_CD = num_D_CD_CD + 1;
                        
                        if(yFUCD(i) > -5)
                            num_F_UCD_CD = num_F_UCD_CD + 1;
                        end
                end
  
                % Number of CD at visit 1 who have become UCD at visit 2
                if(yDUCD(i) < -10)
                    num_D_UCD_UCD = num_D_UCD_UCD + 1;
                    
                    if(yFUCD(i) < -10)
                        num_F_UCD_UCD = num_F_UCD_UCD + 1;
                    end
                end
        end  
    end

    % Counts
    % CD
    num_D_CD
    num_D_CD_CD
    num_F_CD_CD
    num_D_CD_UCD
    num_F_CD_UCD
    % UCD
    num_D_UCD
    num_D_UCD_UCD
    num_F_UCD_UCD
    num_D_UCD_CD
    num_F_UCD_CD
    
    % Output to the routine
    numberOfSamples = num_D_CD + num_D_UCD;
    sensitivity = (num_F_UCD_UCD + num_F_CD_UCD) / (num_D_UCD_UCD + num_D_CD_UCD) ;
    specificity = (num_F_CD_CD + num_F_UCD_CD) / (num_D_CD_CD + num_D_UCD_CD);
    accuracy = (num_F_UCD_UCD + num_F_CD_UCD + num_F_CD_CD + num_F_UCD_CD) / (num_D_UCD_UCD + num_D_CD_UCD + num_D_CD_CD + num_D_UCD_CD);
    
end
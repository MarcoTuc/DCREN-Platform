function DataStruct = SelectInputData(xNameDataSet)
        % Expert Data base E0 from Gregorich, M., Heinzel, A., Kammer, M., Meiselbach, H., Böger,
        %C., Eckardt, K.U., Mayer, G., Heinze, G., Oberbauer, R., 2021. A
        %prediction model for the decline in renal function in people with type 2
        %diabetes mellitus: study protocol. Diagnostic and Prognostic Research
        %5, 1–9.
        
                % Various possibilities for data inputs
                %  Very Short List
                %DataStruct.xNameVeryShortList = ["EGFR_1"]; % eGFR

                % Expert data set published
                %DataStruct.xNameE0ShortList = ["BMI_1","EGFR_1","SBP_1","DBP_1","HBA1C_1","TOTCHOL_1","HB_1","UACR_1","AGEV_1"]; % Expert

                % Short List from Gert
                % Bayes
                %DataStruct.xNameGertShortList = ["EGFR_1","STRIG_1","BMI_1","TNFRSF1A_LUM_num_1","TOTCHOL_1","HB_1","LGALS3_LUM_num_1","UCREA_1","AGEV_1","BG_1","HDLCHOL_1","LDLCHOL_1","SBP_1","DBP_1","EGF_MESO_num_norm_1","FGF21_MESO_num_norm_1","UACR_1","HBA1C_1","CRP_1","ADIPOQ_LUM_num_1","SPOT_1","CST3_num_1","SALB_1","SCR_1","MABP_1"];

                % Short List from MGA
                % MGA
                %DataStruct.xNameMGAShortList = ["EGFR_1","LDLCHOL_1","UACR_1","VEGFA_LUM_num_1","ADMD","SCR_1","TOTCHOL_1","HB_1","SALB_1","CA_CL_num_1","HAVCR1_MESO_num_norm_1","HTDAV"];

                % Joined List
                % PRO
                %DataStruct.xNameJoinedList = ["EGFR_1","STRIG_1","BMI_1","TNFRSF1A_LUM_num_1","TOTCHOL_1","HB_1","LGALS3_LUM_num_1","UCREA_1","AGEV_1","AGER_LUM_num_1","LEP_LUM_num_1","ICAM1_LUM_num_1","IL18_LUM_num_1","BG_1","FGF21_MESO_num_norm_1","DPP4_LUM_num_1","UNA24H_1","POT_CL_num_1","HDLCHOL_1","LDLCHOL_1","SBP_1","DBP_1","EGF_MESO_num_norm_1","UACR_1","HBA1C_1","CRP_1","ADIPOQ_LUM_num_1","ADMD","SCR_1","PP_1","VEGFA_LUM_num_1","HTDAV","SPOT_1","CST3_num_1","SALB_1","MABP_1","CA_CL_num_1","HAVCR1_MESO_num_norm_1","HEIGHT","AHDT","DDMAV","DDMT","DHTT","BW_1","LDLHDLR_1","EVLDLCHOL_1","ELDLCHOL_1","ELDLHDLR_1","PHOS_CL_num_1","CST3_num_1","CPEP_CL_num_1","FFA_CL_num_1","UA_CL_num_1","SO_CL_num_1","CHL_CL_num_1","TAH_1","TAD_1","TLL_1","TEPO_1","TDIU_1","MMP7_LUM_num_1","SERPINE1_LUM_num_1","IL6_MESO_num_norm_1","CCL2_MESO_num_norm_1","MMP2_MESO_num_norm_1","MMP9_MESO_num_norm_1","LCN2_MESO_num_norm_1","NPHS1_MESO_num_norm_1","THBS1_MESO_num_norm_1"];
                % numberOfContinuousProvalidVariables = length(DataStruct.xNameJoinedList);


                % Composite
                %DataStruct.CompositeListR = ["EGFR_1","LGALS3_LUM_num_1","FGF21_MESO_num_norm_1","UACR_1","TNFRSF1A_LUM_num_1","STRIG_1","LEP_LUM_num_1","DPP4_LUM_num_1","HB_1","ADIPOQ_LUM_num_1","AGEV_1","UNA24H_1","SBP_1","IL18_LUM_num_1","VEGFA_LUM_num_1","UCREA_1","TOTCHOL_1","BMI_1","BG_1","HTDAV","ADMD","HAVCR1_MESO_num_norm_1","DBP_1","LDLCHOL_1","HBA1C_1"];
                %DataStruct.CompositeListG = ["EGFR_1","IL18_LUM_num_1","LGALS3_LUM_num_1","LEP_LUM_num_1","HB_1","UACR_1","ADIPOQ_LUM_num_1","TOTCHOL_1","LDLCHOL_1","FGF21_MESO_num_norm_1","CHL_CL_num_1","SO_CL_num_1","HDLCHOL_1","AGEV_1","DPP4_LUM_num_1","BG_1","VEGFA_LUM_num_1","DBP_1","STRIG_1","ICAM1_LUM_num_1","TNFRSF1A_LUM_num_1","BMI_1","HTDAV","UCREA_1","ADMD"];
                %DataStruct.CompositeListM = ["EGFR_1","TNFRSF1A_LUM_num_1","UACR_1","EGFR_1","LDLCHOL_1","AGER_LUM_num_1","TOTCHOL_1","ADIPOQ_LUM_num_1","SBP_1","UNA24H_1","DPP4_LUM_num_1","IL18_LUM_num_1","HDLCHOL_1","LEP_LUM_num_1","HB_1","DBP_1","HTDAV","HBA1C_1","LGALS3_LUM_num_1","ICAM1_LUM_num_1","STRIG_1","AGEV_1","BMI_1","UCREA_1","VEGFA_LUM_num_1","SERPINE1_LUM_num_1"];
                %DataStruct.CompositeListS = ["EGFR_1","FGF21_MESO_num_norm_1","SBP_1","TOTCHOL_1","LEP_LUM_num_1","UCREA_1","SERPINE1_LUM_num_1","LDLCHOL_1","HB_1","STRIG_1","ADIPOQ_LUM_num_1","DPP4_LUM_num_1","TNFRSF1A_LUM_num_1","AGER_LUM_num_1","BG_1","DBP_1","UNA24H_1","BMI_1","LGALS3_LUM_num_1","PP_1","HAVCR1_MESO_num_norm_1","AGEV_1","MABP_1","UACR_1","POT_CL_num_1"];

                %  Experimental List
                %DataStruct.experimental = ["EGFR_1","ADIPOQ_LUM_num_1","ICAM1_LUM_num_1","TOTCHOL_1"]; % Exp

                %DataStruct.Exp3 = ["EGFR_1","UACR_1","AGEV_1","ADIPOQ_LUM_num_1","ICAM1_LUM_num_1"]; % Exp3 good for R. "ADIPOQ_LUM_num_1","ICAM1_LUM_num_1" are the best predictors 
                %DataStruct.Exp4 = ["EGFR_1","UACR_1","DBP_1","ADIPOQ_LUM_num_1","ICAM1_LUM_num_1"]; %

                % ADIPOQ
                %DataStruct.ADIPOQ = ["ADIPOQ_LUM_num_1"];
                %DataStruct.ICAM = ["ICAM1_LUM_num_1"];
                %DataStruct.ADICAM = ["ADIPOQ_LUM_num_1","ICAM1_LUM_num_1"];
                %DataStruct.ADIDEGFR = ["ADIPOQ_LUM_num_1",];
        
        DataStruct.InputData.PLSNNPaper = ["EGFR_1","AGEV_1","SBP_1","TOTCHOL_1","DPP4_LUM_num_1","ICAM1_LUM_num_1","LEP_LUM_num_1","ADIPOQ_LUM_num_1","SERPINE1_LUM_num_1"]; % Exp2
        DataStruct.xNameDataSet = xNameDataSet;
        if(DataStruct.xNameDataSet == "Exp3")
            DataStruct.xNameData = DataStruct.Exp3;
        elseif(DataStruct.xNameDataSet == "xNameJoinedList")
            DataStruct.xNameData = DataStruct.xNameJoinedList;
        elseif(DataStruct.xNameDataSet == "xNameE0ShortList")
            DataStruct.xNameData = DataStruct.xNameE0ShortList;
        elseif(DataStruct.xNameDataSet == "xNameGertShortList")
            DataStruct.xNameData = DataStruct.xNameGertShortList;
        elseif(DataStruct.xNameDataSet == "PLSNNPaper")
            DataStruct.xNameData = DataStruct.InputData.PLSNNPaper;
        end
        %DataStruct.hyperStruct.NumberOfPLSVariables = length(DataStruct.xNameDataSet); % length of the input data 
end


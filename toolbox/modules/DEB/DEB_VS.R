library(psych)
library(bnlearn)


#Importo i dati, nella versione multiline con due istanti successivi temporali (vedi Mail Claudio del 25 Novembre 2022)
d<-read.csv("toolbox/modules/DEB/preprocess/in_data_transformed.csv",stringsAsFactors = T,na.strings = "")


#Seleziono le variabili d'interesse (variabili in giallo nel file proposto da Gert + TCOMB + DEGFR +TC + MSLV, escludendone alcune a causa di valori sbilanciati- vedi file excel Venice_BN_DCX-ren variables ranking of significance 07062022.xlsx )
name<-c(
  "GE",
  "HEIGHT",
  "ADMD",
  "AHDT",
  "SDMAV",
  "DDMAV",
  "DDMT",
  "HTDAV",
  "SHTAV",
  "DHTT",
  "PHDRB",
  "PHRDB",
  "PHHFB",
  "PHCADB",
  "PHPADB",
  "PHCVDB",
  "SMOK",
  #"PHMB",
  "FHRD",
  "FHHT",
  "FHDM",
  "FHCVD",
  "FHM",
  "BW_1",
  "SBP_1",
  "DBP_1",
  "AGEV_1",
  "BMI_1",
  "MABP_1",
  "PP_1",
  "BG_1",
  "HBA1C_1",
  "SCR_1",
  "TOTCHOL_1",
  "LDLCHOL_1",
  "HDLCHOL_1",
  "STRIG_1",
  "SPOT_1",
  "HB_1",
  "SALB_1",
  "CRP_1",
  "EGFR_1",
  "UACR_1",
  "LDLHDLR_1",
  "EVLDLCHOL_1",
  "ELDLCHOL_1",
  "ELDLHDLR_1",
  "UCREA_1",
  "CA_CL_num_1",
  "PHOS_CL_num_1",
  "CST3_num_1",
  "CPEP_CL_num_1",
  "FFA_CL_num_1",
  "UA_CL_num_1",
  "SO_CL_num_1",
  "POT_CL_num_1",
  "CHL_CL_num_1",
  "UNA24H_1",
  "NIDR_1",
  "NIMI_1",
  "NIS_1",
  "NIHF_1",
  "NICAD_1",
  "NICVD_1",
  "NIPAD_1",
  #"AHRI_1",
  "AHBB_1",
  "AHCA_1",
  "AHCAAH_1",
  "AHARB_1",
  "AHDV_1",
  "ADSU_1",
  "ADPPI_1",
  "ADGL_1",
  "ADGLIT_1",
  "ADMET_1",
  "ADAGI_1",
  "ADI_1",
  "LLCFA_1",
  "LLSTAT_1",
  #"LLAER_1",
  #"LLNA_1",
  "LLOTHER_1",
  "APASA_1",
  "APTPD_1",
  #"APDIP_1",
  #"APGPI_1",
  "APOTHER_1",
  "VDAC_1",
  #"VDCT_1",
  "VDCCF_1",
  #"VDPC_1",
  "EPODA_1",
  #"EPOEA_1",
  "EPOEB_1",
  #"EPOET_1",
  #"EPOEZ_1",
  #"EPOOTHER_1",
  "IO_1",
  #"IIV_1",
  "PBCB_1",
  #"PBSB_1",
  #"PBMB_1",
  #"PBAB_1",
  #"PBLB_1",
  #"PBOTHER_1",
  "DLOOP_1",
  "DTH_1",
  "DPS_1",
  #"CC_1",
  #"NSAID_1",
  "AC_1",
  "ASC_1",
  "TAH_1",
  "TAD_1",
  "TADI_1",
  "TLL_1",
  "TEPO_1",
  "TDIU_1",
  #"MMP7_LUM_1",
  #"VEGFA_LUM_1",
  #"AGER_LUM_1",
  #"LEP_LUM_1",
  #"ICAM1_LUM_1",
  #"TNFRSF1A_LUM_1",
  #"IL18_LUM_1",
  #"DPP4_LUM_1",
  #"LGALS3_LUM_1",
  #"SERPINE1_LUM_1",
  #"ADIPOQ_LUM_1",
  #"EGF_MESO_1",
  #"FGF21_MESO_1",
  #"IL6_MESO_1",
  #"HAVCR1_MESO_1",
  #"CCL2_MESO_1",
  #"MMP2_MESO_1",
  #"MMP9_MESO_1",
  #"LCN2_MESO_1",
  #"NPHS1_MESO_1",
  #"THBS1_MESO_1",
  #"EGF_MESO_norm_1",
  #"FGF21_MESO_norm_1",
  #"IL6_MESO_norm_1",
  #"HAVCR1_MESO_norm_1",
  #"CCL2_MESO_norm_1",
  #"MMP2_MESO_norm_1",
  #"MMP9_MESO_norm_1",
  #"LCN2_MESO_norm_1",
  #"NPHS1_MESO_norm_1",
  #"THBS1_MESO_norm_1",
  "MMP7_LUM_num_1",
  "VEGFA_LUM_num_1",
  "AGER_LUM_num_1",
  "LEP_LUM_num_1",
  "ICAM1_LUM_num_1",
  "TNFRSF1A_LUM_num_1",
  "IL18_LUM_num_1",
  "DPP4_LUM_num_1",
  "LGALS3_LUM_num_1",
  "SERPINE1_LUM_num_1",
  "ADIPOQ_LUM_num_1",
  #"EGF_MESO_num_1",
  #"FGF21_MESO_num_1",
  #"IL6_MESO_num_1",
  #"HAVCR1_MESO_num_1",
  #"CCL2_MESO_num_1",
  #"MMP2_MESO_num_1",
  #"MMP9_MESO_num_1",
  #"LCN2_MESO_num_1",
  #"NPHS1_MESO_num_1",
  #"THBS1_MESO_num_1",
  "EGF_MESO_num_norm_1",
  "FGF21_MESO_num_norm_1",
  "IL6_MESO_num_norm_1",
  "HAVCR1_MESO_num_norm_1",
  "CCL2_MESO_num_norm_1",
  "MMP2_MESO_num_norm_1",
  "MMP9_MESO_num_norm_1",
  "LCN2_MESO_num_norm_1",
  "NPHS1_MESO_num_norm_1",
  "THBS1_MESO_num_norm_1",
  "TC_2",
  "DEGFR_2",
  "TCOMB_1",
  "TCOMB_2",
  "MSLV_2")

dati.vs<-d[,name] 

#Ai fini dell'analisi si è deciso di escludere alcune ulteriori variabili
datiDE<-dati.vs[,!names(dati.vs) %in% c("TC_2","MSLV_2")]
#Si identifica la target di interesse
target<-c("DEGFR_2")

#copia del dataset finale da usare
dati.vs1<-datiDE

#Pre-processing
#trasformo in fattori (variabili categoriali) le variabili non strettamente numeriche
dati.vs1[,c("TAH_1","TAD_1","TADI_1","TLL_1","TEPO_1","TDIU_1")]<-lapply(dati.vs1[,c("TAH_1","TAD_1","TADI_1","TLL_1","TEPO_1","TDIU_1")],as.factor)

#Trasformo in classe numeric tutte le variabili classificate come integer (servirà per le analisi successive) 
dati.vs1[, names(which(sapply(dati.vs1[,], is.integer)))]<-lapply(dati.vs1[, names(which(sapply(dati.vs1[,], is.integer)))],as.numeric)

#Elimino tutte le righe dove è presente almeno un dato mancante al fine di avere un dataset senza missing data
dati.vs1.noNA<-na.omit(dati.vs1)

#Uso una trasformazione logaritmica (con aggiunta di +0.01 ai valori per ovviare al problema dei valori pari a 0) seguendo il seguente procedimento:
#1.calcolo le principali statistiche per le variabili numeriche
describe(dati.vs1.noNA[, names(which(sapply(dati.vs1.noNA[,], is.numeric)))]) #library(psych)
#2.identifico quali sono le variabili che sono da trasformare guardando i valori di skew e Kurtosis; nello specifico seleziono le variabili che hanno congiuntamente valori (in termini assoluti) eccedenti rispettivamente 3 (Skew) e 10 (Kurtosis)
# questa parte andrebbe automatizzata, io ad ora ho individuato manualmente le variabili essendo relativamente poche
tr<-c("CRP_1","UACR_1","MMP7_LUM_num_1","VEGFA_LUM_num_1","EGF_MESO_num_norm_1","IL6_MESO_num_norm_1","HAVCR1_MESO_num_norm_1","CCL2_MESO_num_norm_1","MMP2_MESO_num_norm_1","MMP9_MESO_num_norm_1","LCN2_MESO_num_norm_1",
      "NPHS1_MESO_num_norm_1","THBS1_MESO_num_norm_1")
#Faccio una copia dei dati e successivamente trasformo le variabili selezionate
dati.log<-dati.vs1.noNA
dati.log[,tr]<-log(dati.log[, tr]+0.01)


###########################################################
#####VARIABLE SELECTION####################################
###Costruisco l'insieme delle relazioni a priori, secondo lo schema fornito da Gert (vedi file DC-ren-obs-network-20210517.pdf, pagina 3)

prior_fu1_c<- matrix(ncol=2)
colnames(prior_fu1_c) <- c("From", "To")
prior_fu1_c[1,]<- c("BG_1","HBA1C_1")
prior_fu1_c <- rbind(prior_fu1_c,c("BG_1","STRIG_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BG_1","TOTCHOL_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BG_1","HDLCHOL_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HBA1C_1","SPOT_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HBA1C_1", "HB_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BG_1","CRP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BG_1" , "SALB_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HBA1C_1","CRP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HBA1C_1","SALB_1"))
prior_fu1_c <- rbind(prior_fu1_c,c( "CRP_1" ,"SALB_1"))
prior_fu1_c <- rbind(prior_fu1_c,c( "SBP_1" , "DBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c( "SBP_1"  , "SPOT_1"))
prior_fu1_c <- rbind(prior_fu1_c,c( "DBP_1" , "SPOT_1"))
prior_fu1_c <- rbind(prior_fu1_c,c( "SBP_1","HB_1"))
prior_fu1_c <- rbind(prior_fu1_c,c( "DBP_1" , "HB_1"))
prior_fu1_c <- rbind(prior_fu1_c,c( "TOTCHOL_1", "SBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("TOTCHOL_1", "DBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HDLCHOL_1", "SBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HDLCHOL_1", "DBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("STRIG_1" ,  "SBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("STRIG_1",   "DBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("TOTCHOL_1", "CRP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("STRIG_1",  "CRP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BMI_1",  "BG_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BMI_1","HBA1C_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BMI_1","SBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BMI_1","DBP_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BMI_1","TOTCHOL_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BMI_1","HDLCHOL_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("BG_1","UACR_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HBA1C_1","UACR_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("UACR_1","EGFR_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("SPOT_1","EGFR_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("HB_1","EGFR_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("AGEV_1","EGFR_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("GE","EGFR_1"))
prior_fu1_c <- rbind(prior_fu1_c,c("SCR_1","EGFR_1"))

#Nomino alcune variabili come parte dei vari box presenti nello schema fornito
#Core mechanism
core<-c("SBP_1","DBP_1","BG_1","HBA1C_1","TOTCHOL_1","LDLCHOL_1",
        "HDLCHOL_1","STRIG_1","SPOT_1","HB_1","SALB_1","CRP_1")
#Behaviour mechanism
beha<-c("BMI_1","UACR_1")
#Target related
tar<-c("AGEV_1","GE","SCR_1","EGFR_1")


# Processo di variable selection secondo la procedura basata sul Markov Blanket
# Vedi file "Proposal for variable selection_14NOV2022.doc" 
# Alla fine del processo è stato scelto di usare le variabili che compongono la rete dell'ultima Figura
# Num of nodes: 30.
# Num of arcs: 105

# faccio una copia dei dati da utilizzare per il processo 
dati1<-dati.log
# Stimo una rete - hybrid Bayesian networks (mixed categorical and normal variables) - attraverso procedura bootstrap con R=100 replicazioni del processo, procedura hc e score BIC
set.seed(17) # il processo si basa su Bootstrap -campionamento casuale- per renderlo riproducibile fisso la seed di partenza

############################################################# TIMECONSUMING STEP
rete.A<-boot.strength(dati1, R = 100, algorithm = "hc")
############################################################# TIMECONSUMING STEP

#seleziono gli archi della rete che hanno threshold pari a 0.5
rete.A.2<-averaged.network(rete.A,threshold = 0.25)

#identifico il MarkovBlanket della target
mb.A.2 <- mb(rete.A.2, target)

# CUSTOM: salvo la markov blanket come variable selection finale
write.csv(mb.A.2, 'toolbox/modules/DEB/input_data/variable-selection.csv')

#identifico le variabili che appartengo al markov Blanket di tutte le variabili del MB della Target
# Tmb.A.2<-c()

# for (i in 1:length(mb.A.2)){
#   print(mb.A.2[i])
#   Tmb.A.2<-c(Tmb.A.2, mb(rete.A.2,mb.A.2[i]))
# }
# #Il vettore delle variabili selezionate è l'oggetto selected
# selected<-unique(Tmb.A.2)
# #Si aggiungono le variabili presenti nelle relazioni a priori in quanto considerate importanti per il sistema
# selected_and_prior<-unique(c(selected,core, beha, tar))
# #Le variabili selezionate sono le seguenti
# #Sono quelle evidenziate nel file "Variables selected by BN.xlsx"
# selected_and_prior

# write.csv(selected_and_prior, 'toolbox/modules/DEB/input_data/variable-selection.csv')


library(psych, help, pos=2, lib.loc=NULL)

sink(stdout(), type="message") 

#Importo i dati, nella versione multiline con due istanti successivi temporali (vedi Mail Claudio del 25 Novembre 2022)
d<-read.csv("toolbox/modules/DEB/preprocess/in_data_transformed.csv", stringsAsFactors=T, na.strings="")

# actual_cols <- names(d)
# missing_cols <- name[!(name %in% actual_cols)]
# print("Missing columns:")
# print(missing_cols)
# common_cols <- name[name %in% actual_cols]
# print("Columns present in both:")
# print(common_cols)
# # Save missing and common columns to text files
# write.table(missing_cols, "toolbox/modules/DEB/input_data/missing_columns.txt", row.names=FALSE, col.names=FALSE)
# write.table(common_cols, "toolbox/modules/DEB/input_data/common_columns.txt", row.names=FALSE, col.names=FALSE)

dati.vs<-d 
datiDE<-dati.vs[,!names(dati.vs) %in% c("TC_2","MSLV_2")]

# #Si identifica la target di interesse
# target<-c("DEGFR_2")

# #copia del dataset finale da usare
dati.vs1<-datiDE

# #Trasformo in classe numeric tutte le variabili classificate come integer (servirà per le analisi successive) 
dati.vs1[, names(which(sapply(dati.vs1[,], is.integer)))]<-lapply(dati.vs1[, names(which(sapply(dati.vs1[,], is.integer)))],as.numeric)

# #Elimino tutte le righe dove è presente almeno un dato mancante al fine di avere un dataset senza missing data
# dati.vs1.noNA<-na.omit(dati.vs1)

# #Uso una trasformazione logaritmica (con aggiunta di +0.01 ai valori per ovviare al problema dei valori pari a 0) seguendo il seguente procedimento:
# #1.calcolo le principali statistiche per le variabili numeriche
# describe(dati.vs1.noNA[, names(which(sapply(dati.vs1.noNA[,], is.numeric)))]) #library(psych)
# #2.identifico quali sono le variabili che sono da trasformare guardando i valori di skew e Kurtosis; nello specifico seleziono le variabili che hanno congiuntamente valori (in termini assoluti) eccedenti rispettivamente 3 (Skew) e 10 (Kurtosis)
# # questa parte andrebbe automatizzata, io ad ora ho individuato manualmente le variabili essendo relativamente poche
# tr<-c("CRP_1","UACR_1","MMP7_LUM_num_1","VEGFA_LUM_num_1","EGF_MESO_num_norm_1","IL6_MESO_num_norm_1","HAVCR1_MESO_num_norm_1","CCL2_MESO_num_norm_1","MMP2_MESO_num_norm_1","MMP9_MESO_num_norm_1","LCN2_MESO_num_norm_1",
#       "NPHS1_MESO_num_norm_1","THBS1_MESO_num_norm_1")
# #Faccio una copia dei dati e successivamente trasformo le variabili selezionate
# dati.log<-dati.vs1.noNA
# dati.log[,tr]<-log(dati.log[, tr]+0.01)

write.csv(dati.vs1, 'toolbox/modules/DEB/input_data/deb_preprocessed.csv')
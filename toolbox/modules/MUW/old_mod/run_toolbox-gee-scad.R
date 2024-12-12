# Author: Michael Kammer, MUW

# Requirements -----------------------------------------------------------------
# mice (>3.12)
# exported model .rds

# Helper functions -------------------------------------------------------------

#' Load CSV Data.
#' 
#' @param path_input
#' Path to input file conforming to the csv_multiline format of the 
#' PROVALID data socket.
load_input <- function(path_input) {
    read.csv(path_input, na.strings = c("NA", ""))
}

#' Load model information.
#' 
#' @param path_model
#' Path to rds file storing model information.
load_model <- function(path_model) {
    readRDS(path_model)
}

#' Data pre-processing.
#' 
#' @param d 
#' Data.frame with data conforming to the format of the data socket. 
#' @param m
#' Loaded model data.
process_data <- function(d, m) {
    # define extra variables used during modeling
    d$log2_UACR = ifelse(d$UACR == 0, NA, log2(d$UACR))
    d$EGFR_t = d$EGFR
    d$GE = ifelse(d$GE %in% "Female", "1", ifelse(d$GE %in% "Male", "0", NA))
    d$SMOK_b = ifelse(d$SMOK_b %in% "True", 1, ifelse(d$SMOK_b %in% "False", 0, NA))
    d$PHDRB = ifelse(d$PHDRB %in% "True", 1, ifelse(d$PHDRB %in% "False", 0, NA))
    d$PHHFB = ifelse(d$PHHFB %in% "True", 1, ifelse(d$PHHFB %in% "False", 0, NA))
    d$PHCADB = ifelse(d$PHCADB %in% "True", 1, ifelse(d$PHCADB %in% "False", 0, NA))
    d$PHCVDB = ifelse(d$PHCVDB %in% "True", 1, ifelse(d$PHCVDB %in% "False", 0, NA))
    # some simple renamings to conform to my names
    d$CST3_CL_num = d$CST3_num
    
    for (v in c("TADI", "FHHT", "FHCVD", "FHM", 
                "APASA", "APTPD", "SDMAV"))
        d[, v] = ifelse(d[[v]] == "True", TRUE, ifelse(d[[v]] == "False", FALSE, NA))

    # some transformations
    for (v in c("POT_CL_num", "UA_CL_num", "PHOS_CL_num")) 
        d[[v]] = log2(d[[v]])
    
    for (v in c("CRP"))
        d[[v]] = log2(d[[v]] + 0.01)
    
    # change variable types 
    # all variables which express categories but are not characters
    for (v in c("GE", "SMOK_b", 
                "SGLT2I", "MCRA", "GLP1A",
                # personal history yes no na
                "PHDRB", "PHRDB", "PHCADB", "PHPADB", "PHCVDB", 
                # family history yes no na
                "FHHT", "FHCVD", "FHM", 
                "APASA", "APTPD", "VDCCF", 
                # others relevant for modeling
                "TADI", "SDMAV", "SHTAV"))
        d[[v]] = as.factor(d[[v]])
    
    # log2 for proteins
    for (v in names(d)[grepl("_LUM_num|MESO_num", names(d))])
        d[[v]] = ifelse(d[[v]] > 0, log2(d[[v]]), NA)
    
    d[, m$vars]
}

#' Imputate missing data using saved model.
#' 
#' @param d 
#' Output of `process_data`.
impute_data <- function(d, m_imp) {
    mice::complete(mice::mice.mids(m_imp, newdata = d, printFlag = FALSE), 1)
}

#' @title Applies extracted scale to data.frame
#' 
#' @param d
#' Data.frame
#' @param scaler
#' List of scalers
#' 
#' @details 
#' All columns not found in scaler are left as they are.
#' 
#' @return 
#' Scaled data.frame
apply_scale <- function(d, scaler) {
    d_scaled = d
    
    for (i in seq_along(scaler)) {
        s = scaler[[i]]
        if (is.na(s[[1]])) next
        v = names(scaler)[i]
        d_scaled[[v]] = apply_scale_variable(d[[v]], s)
    }
    
    d_scaled
}

#' Predict from saved model.
#' 
#' @param d_in
#' Output of `load_input`.
#' @param m_pred
#' Saved prediction model stored in output of `load_model`.
predict_data <- function(d_in, m_pred) {
    d_pred = process_data(d_in, m_pred)
    d_pred = impute_data(d_pred, m_pred$m_imp)
    
    # prepare model matrix
    f_prep = as.formula(m_pred$f)
    f_prep = update(f_prep, NULL ~ .)
    
    # now return predictions for each medication
    res = list()
    med_vals = list(
        RASI = c(0, 0, 0), 
        RASI_SLGT2 = c(1, 0, 0), 
        RASI_GLP1A = c(0, 1, 0), 
        RASI_MCRA = c(0, 0, 1)
    )
    for (v in seq_along(med_vals)) {
        d_pred$SGLT2I = med_vals[[v]][1]
        d_pred$GLP1A = med_vals[[v]][2]
        d_pred$MCRA = med_vals[[v]][3]
        
        mat_pred = model.matrix(f_prep, d_pred)
        linpred = 0
        for (col in 1:ncol(mat_pred)) {
            vname = colnames(mat_pred)[col]
            linpred = linpred + mat_pred[, col] * m_pred$coefs[vname, "coefficient_clean_unscaled"]
        }
        
        res[[v]] = rbind(
            data.frame(
                test_id = d_in$AGGID, 
                therapy = names(med_vals)[v],
                predicted_variable = "deltaEGFR",
                predicted_value = (linpred - d_pred$EGFR_t) / 
                    d_pred$EGFR_t * 100
            ), 
            data.frame(
                test_id = d_in$AGGID, 
                therapy = names(med_vals)[v],
                predicted_variable = "TC",
                predicted_value = ((linpred - d_pred$EGFR_t) / 
                                       d_pred$EGFR_t * 100) < -10
            )
        )
    }
    
    Reduce(rbind, res)
}

#' Write predictions to CSV.
#' 
#' @param pred
#' Data.frame with predictions produced by `predict_data`.
#' 
#' @param path_output
#' Path to output file conforming to the specifications outlined by Claudio
#' Silvestri. 
export_data <- function(pred, path_output) {
    write.csv(pred, path_output)
}

# main functionality -----------------------------------------------------------
args = commandArgs(trailingOnly = TRUE)
paths = list(
    input = args[which(args == "--input") + 1], 
    output = args[which(args == "--output") + 1], 
    model = args[which(args == "--model") + 1] 
)

d_in = load_input(paths$input)
m_pred = load_model(paths$model)
pred = predict_data(d_in, m_pred)
export_data(pred, paths$output)

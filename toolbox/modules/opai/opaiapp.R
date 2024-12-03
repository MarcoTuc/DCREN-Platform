
#' Gets the similarities between a prediction state and the model states
getStateSimilarities <- function(inputData, state) {

    # make a new dataframe holding the state vectors for the states of the OO with
    # the state vector of the prediction state as the final row
    statesModel <- subset(inputData$modelStates, select=-c(ASID, VSID))
    statePrediction <- subset(inputData$predictionInput[inputData$predictionInput$TID == state,], select=-c(TID))
    colnames(statePrediction) <- colnames(statesModel) # HACK: this is a hack to make the column names the same so that rbind works but this should already have been done in a previous step
    states <- rbind(statesModel, statePrediction)
    
    # get the similarities as a matrix
    w <- inputData$predictionControls[,'ASVARWEIGHT']
    similarityMatrix <- 1 - as.matrix(FD::gowdis(states, w))

    # get just the similarities between the prediction state and the model states
    # this is just the final row of the matrix since that is the similarity of this state
    # to other states, and remove final element since that would be its self-similarity
    similaritiesVS <- similarityMatrix[nrow(similarityMatrix),1:(ncol(similarityMatrix)-1)]
    
    # output error message if there are no non-na similarities
    if (all(is.na(similaritiesVS))) {
        stop(paste0("ERROR: Similarities between prediction state '", state, "' and model states contain NAs."))
    }

    return(similaritiesVS)
}

#' Gets the similarity between a prediction state and a virtual state
getSimilarityVirtualState <- function(inputData, method, similarities, vs) {
    similaritiesVS <- similarities[which(inputData$modelStates[,'VSID'] == vs)]
    if (method == "min") {
        return(min(similaritiesVS, rm.na=TRUE))
    } else if (method == "mean") {
        return(mean(similaritiesVS, rm.na=TRUE))
    } else if (method == "max") {
        maxNoNA <- function(x) ifelse( !all(is.na(x)), max(x, na.rm=T), NA)
        return(maxNoNA(similaritiesVS))
    }
}

#' Gets the similarities between the prediction state and the virtual states
getSimilaritiesVirtualStates <- function(inputData, method, similarities) {
    vsIDs <-unique(inputData$modelStates[,'VSID'])
    similaritiesVS <- sapply(vsIDs, function(vs) getSimilarityVirtualState(inputData, method, similarities, vs))
    names(similaritiesVS) <- vsIDs
    return(similaritiesVS)
}

#' Matches a prediction state to a virtual state in the observation object
matchStateVirtualState <- function(inputData, method, state) {

    # get similirities between the prediction state and virtual states
    similarities <- getStateSimilarities(inputData, state)
    similaritiesVS <- getSimilaritiesVirtualStates(inputData, method, similarities)

    # get the virtual state with the highest similarity
    vsMatch <- names(which.max(similaritiesVS))
    return(vsMatch)
}

#' Does the main calculation
runPrediction <- function(inputData, method, progressFile) {
    message <- "Running prediction"
    writeProgressStepStart(progressFile, message)

    # get the prediction states and the cases to do
    message2 <- "  Getting prediction states and cases to do"
    writeProgressStepStart(progressFile, message2)
    statesPrediction <- inputData$predictionInput[,'TID']
    modelColumns <- colnames(inputData$model)
    cases <- modelColumns[2:length(modelColumns)]
    writeProgressStepDone(progressFile, message2)

    # match each of the prediction states to virtual states
    message2 <- "  Matching prediction states to virtual states"
    writeProgressStepStart(progressFile, message2)
    vsMatch <- sapply(statesPrediction, function(state) matchStateVirtualState(inputData, method, state))
    names(vsMatch) <- statesPrediction
    writeProgressStepDone(progressFile, message2)

    # do predictions for each case for each prediction state and save in a matrix
    message2 <- "  Doing predictions"
    writeProgressStepStart(progressFile, message2)
    predictionsMatrix <- matrix(NA, nrow=length(vsMatch), ncol=length(cases))
    rownames(inputData$model) <- inputData$model[,1]
    for (i in 1:length(vsMatch)) {
        predictionsMatrix[i,] <- as.matrix(inputData$model[vsMatch[i],2:ncol(inputData$model)])
    }
    writeProgressStepDone(progressFile, message2)

    # convert the matrix to a data frame and set the row and column names
    message2 <- "  Finalising predictions"
    writeProgressStepStart(progressFile, message2)
    predictions <- data.frame(predictionsMatrix)
    colnames(predictions) <- cases
    rownames(predictions) <- statesPrediction
    writeProgressStepDone(progressFile, message2)

    writeProgressStepDone(progressFile, message)
    return(list(
        vsMatch = vsMatch,
        predictions = predictions
    ))
}

#' Checks if the input directory exists
validateInputDirectory <- function(inputDir, progressFile) {
    message <- "Checking input directory exists"
    writeProgressStepStart(progressFile, message)

    # check for existence input directory
    if (!file.exists(inputDir)) {
        stop("ERROR: Input directory does not exist.")
    }

    # check for existence of required files
    requiredFiles <- c(
        "OPAi-model.csv",
        "OPAi-model-state-vectors.csv",
        "OPAi-prediction-input.csv",
        "OPAi-prediction-control.csv"
    )
    for (file in requiredFiles) {
        if (!file.exists(paste0(inputDir, file))) {
            stop(paste0("ERROR: Required file '", file, "' not found in input directory."))
        }
    }

    writeProgressStepDone(progressFile, message)
}

#' Sets up the output directory
setupOutputDirectory <- function(outputDir) {
    if (file.exists(outputDir)) {
        unlink(outputDir, recursive=TRUE)
    }
    dir.create(outputDir, recursive=TRUE)
}

#' Reads the input data
readInputData <- function(inputDir, progressFile) {
    message <- "Reading input data"
    writeProgressStepStart(progressFile, message)
    inputData <- list(
        model = read.csv(paste0(inputDir, "OPAi-model.csv")),
        modelStates = read.csv(paste0(inputDir, "OPAi-model-state-vectors.csv")),
        predictionInput = read.csv(paste0(inputDir, "OPAi-prediction-input.csv")),
        predictionControls = read.csv(paste0(inputDir, "OPAi-prediction-control.csv"))
    )
    writeProgressStepDone(progressFile, message)
    return(inputData)
}

#' Sets up a path (makes sure there is a / on the end)
setupPath <- function(path) {
    if (substr(path, nchar(path), nchar(path)) != "/") {
        path <- paste0(path, "/")
    }
    return(path)
}

#' Sets up an output path 
setupOutputPath <- function(path) {
    path <- setupPath(path)
    pathFull <- paste0(path)#, format(Sys.time(), "%Y-%m-%d %H-%M-%S"), "/")
    return(pathFull)
}

#' Checks the input data
checkInputData <- function(inputData, progressFile) {}

#' Determines from the input data which variables to include and which are extra (defined as
#' being in the ASVARLIST column but NULL in the TSVARLIST column)
getIncludeVariables <- function(inputData) {
    asVarList <- inputData$predictionControls[,'ASVARLIST']
    asVarList <- sapply(asVarList, as.character)
    tsVarList <- inputData$predictionControls[,'TSVARLIST']
    tsVarList <- sapply(tsVarList, as.character)
    includeVariables <- list(ASID=asVarList[which(tsVarList != "NULL")], TSID=tsVarList[which(tsVarList != "NULL")])
    extraVariables <- list(ASID=asVarList[which(tsVarList == "NULL")], TSID=tsVarList[which(tsVarList == "NULL")])
    return(list(includeVariables=includeVariables, extraVariables=extraVariables))
}

#' Applies the upper and lower bounds to the prediction input
applyUpperLowerBounds <- function(dataInput, predictionControls, includeVariables, varNameColumn) {
    for (var in includeVariables) {
        index <- which(predictionControls[,varNameColumn] == var)
        lower <- predictionControls[index,'LB']
        upper <- predictionControls[index,'UB']
        dataInput[,var] <- sapply(dataInput[,var], function(value) {
            if (is.na(value)) {
                return(value)
            } else if (value < lower) {
                return(lower)
            } else if (value > upper) {
                return(upper)
            } else {
                return(value)
            }
        })
    }
    return(dataInput)
}

#' Applies log transformations to the input state vectors
applyLogTransformations <- function(inputData, includeVariables) {
    for (i in 1:length(includeVariables$ASID)) {
        varAS <- includeVariables$ASID[i]
        varTS <- includeVariables$TSID[i]
        if (inputData$predictionControls[i, 'transform'] == 'y') {
            if (min(inputData$modelStates[,varAS]) <= 0.0) {
                stop(paste0("ERROR: Cannot apply log transformation to training variable '", varAS, "' because it contains values <= 0.0."))
            }
            if (min(inputData$predictionInput[,varTS]) <= 0.0) {
                stop(paste0("ERROR: Cannot apply log transformation to prediction input variable '", varTS, "' because it contains values <= 0.0."))
            }
            inputData$modelStates[,varAS] <- log10(inputData$modelStates[,varAS])
            inputData$predictionInput[,varTS] <- log10(inputData$predictionInput[,varTS])
        }
    }
    return(inputData)
}

# Preprocesses the input data
preprocessInputData <- function(inputData, progressFile) {
    message <- "Preprocessing input data"
    writeProgressStepStart(progressFile, message)

    # get variables to include
    message2 <- "  Get variables to include"
    writeProgressStepStart(progressFile, message2)
    temp <- getIncludeVariables(inputData)
    includeVariables <- temp$includeVariables
    extraVariables <- temp$extraVariables
    writeProgressStepDone(progressFile, message2)

    # remove variables not to be included 
    # this also puts the columnsn for variable values in the same order
    message2 <- "  Remove variables not to be included and order columns"
    writeProgressStepStart(progressFile, message2)
    inputData$modelStates <- inputData$modelStates[, c("ASID", "VSID", includeVariables$ASID)]
    inputData$predictionInput <- inputData$predictionInput[, c("TID", includeVariables$TSID)]
    writeProgressStepDone(progressFile, message2)
    inputData$predictionControls <- inputData$predictionControls[which(inputData$predictionControls[,'ASVARLIST'] %in% includeVariables$ASID),]

    # deal with values above and below the upper and lower bounds in the prediction input
    message2 <- "  Apply upper and lower bounds"
    writeProgressStepStart(progressFile, message2)
    inputData$modelStates <- applyUpperLowerBounds(inputData$modelStates, inputData$predictionControls, includeVariables$ASID, "ASVARLIST")
    inputData$predictionInput <- applyUpperLowerBounds(inputData$predictionInput, inputData$predictionControls, includeVariables$TSID, "TSVARLIST")
    writeProgressStepDone(progressFile, message2)

    # deal with any transformation of the variables
    message2 <- "  Apply log transformations"
    writeProgressStepStart(progressFile, message2)
    inputData <- applyLogTransformations(inputData, includeVariables)
    writeProgressStepDone(progressFile, message2)

    writeProgressStepDone(progressFile, message)
    return(list(
        model = inputData$model,
        modelStates = inputData$modelStates,
        predictionInput = inputData$predictionInput,
        predictionControls = inputData$predictionControls,
        includeVariables = includeVariables,
        extraVariables = extraVariables
    ))
}

#' Outputs the prediction output
outputOutput <- function(outputDir, predictions) {
    predictionsOut <- data.frame(TID = rownames(predictions), predictions)
    filenameOut <- paste0(outputDir, "OPAi-prediction-output.csv")
    write.csv(predictionsOut, filenameOut, row.names=FALSE)
}

#' Outputs the prediction details
outputDetails <- function(outputDir, vsMatch) {
    vsMatchOut <- data.frame(value=vsMatch, row.names=names(vsMatch))
    vsMatchOut <- data.frame(TID=rownames(vsMatchOut), vsMatchOut)
    colnames(vsMatchOut) <- c("TID", "VSID")
    filenameOut <- paste0(outputDir, "OPAi-assignment-details.csv")
    write.csv(vsMatchOut, filenameOut, row.names=FALSE)
}

#' Outputs the variable details
outputVariableDetails <- function(outputDir, inputData, inputDataPP) {

    # initialise the stats data frame
    stats <- data.frame(tsvarlist=numeric(0), mean=numeric(0), median=numeric(0), min=numeric(0), max=numeric(0), null=numeric(0), countLB=numeric(0), countUB=numeric(0))

    # add row to stats for each variable in the prediction input
    tsidAll <- colnames(inputDataPP$predictionInput)[2:length(colnames(inputDataPP$predictionInput))]
    for (var in tsidAll) {
        values <- inputData$predictionInput[,var]
        lower <- inputData$predictionControls[which(inputData$predictionControls[,'TSVARLIST'] == var),"LB"]
        upper <- inputData$predictionControls[which(inputData$predictionControls[,'TSVARLIST'] == var),"UB"]
        statsVar <- c(
            var,
            round(mean(values, na.rm=TRUE), digits=2),
            round(median(values, na.rm=TRUE), digits=2),
            round(min(values, na.rm=TRUE), digits=2),
            round(max(values, na.rm=TRUE), digits=2),
            sum(is.na(values), na.rm=TRUE),
            sum(values < lower, na.rm=TRUE),
            sum(values > upper, na.rm=TRUE)
            )
        stats[nrow(stats)+1,] <- statsVar
    }

    # add rows for the extra variables
    for (var in inputDataPP$extraVariables$ASID) {
        statsVar <- c(
            var,
            "ndef",
            "ndef",
            "ndef",
            "ndef",
            nrow(inputData$predictionInput),
            "ndef",
            "ndef"
            )
        stats[nrow(stats)+1,] <- statsVar
    }

    colnames(stats) <- c("TSVARLIST", "mean", "median", "min", "max", "NULL", "countLB", "countUB")
    filenameOut <- paste0(outputDir, "OPAi-variable-details.csv")
    write.csv(stats, filenameOut, row.names=FALSE, quote=FALSE)
}

#' Outputs the results
outputResults <- function(outputDir, inputData, inputDataPP, results, progressFile) {
    message <- "Outputting results"
    writeProgressStepStart(progressFile, message)
    
    outputOutput(outputDir, results$predictions)
    outputDetails(outputDir, results$vsMatch)
    outputVariableDetails(outputDir, inputData, inputDataPP)
    
    writeProgressStepDone(progressFile, message)
}

#' Writes a full message to the progress file
writeProgressStepFull <- function(progressFile, message) {
    messageToWrite <- paste0(message, "\n")
    append <- file.exists(progressFile)
    cat(messageToWrite, file = progressFile, append = append)
}

#' Writes the start of a message to the progress file
writeProgressStepStart <- function(progressFile, message) {
    messageToWrite <- paste0(message, "...\n")
    append <- file.exists(progressFile)
    cat(messageToWrite, file = progressFile, append = append)
}

#' Writes DONE to a started message in the progress file
writeProgressStepDone <- function(progressFile, message) {
    messageOriginal <- paste0(message, "...")
    messageToWrite <- paste0(message, "...DONE")
    lines <- readLines(progressFile)
    index <- which(lines == messageOriginal)
    lines[index] <- messageToWrite
    writeLines(lines, progressFile)
}

#' Runs the main part of the app
runApp <- function(clp, inputDir, outputDir, progressFile) {
    writeProgressStepFull(progressFile, "Starting OPAi.App")

    # get arguments and check if they are valid
    validateInputDirectory(inputDir, progressFile)

    # read, check, and preprocess input data
    inputData <- readInputData(inputDir, progressFile)
    checkInputData(inputData, progressFile)
    inputDataPP <- preprocessInputData(inputData, progressFile)

    # do the work
    results <- runPrediction(inputDataPP, clp$method, progressFile)

    # output
    outputResults(outputDir, inputData, inputDataPP, results, progressFile)

    writeProgressStepFull(progressFile, "Finished OPAi.App")
}

#' Main function
main <- function(clp) {

    # check if help was requested
    if (clp$doNothing) {
        return(0)
    }

    # setup the input and output directory paths
    inputDir <- setupPath(clp$inputDir)
    outputDir <- setupOutputPath(clp$outputDir)

    # setup the output directory
    setupOutputDirectory(outputDir)

    # setup the progress file path
    progressFile <- paste0(outputDir, "OPAi-app-progress.txt")

    # function for writing an error message to the progress file
    write_error <- function(e) {
        cat(as.character(e$message), file = progressFile, append = TRUE)
        print(e$message)
    }

    # do the run
    tryCatch({
        status <- runApp(clp, inputDir, outputDir, progressFile)
    }, error = write_error)

    return(outputDir)
}

#' Determines if the user gave the correct number of arguments
checkNumberOfArguments <- function(args) {
    if (length(args) < 4) {
        stop("Not enough arguments given.")
    }
}

#' Gets input directory from user arguments
#' 
#' @param args The user arguments in a vector of strings
#' @param argName The name of the argument to get the value of
#' @param hasValue Whether the argument has a value or is a flag
#' @param required Whether the argument is required to be set by the user
#' @param defaultValue The default value to use if the argument is not required and not set by the user
#' @param allowedValues The values that the argument can take (NA for no restriction)
#' @return The value of the argument
getArgument <- function(args, argName, hasValue, required, defaultValue, allowedValues) {
    
    # find the index in the args vector of this argument
    found <- FALSE
    for (i in 1:length(args)) {
        if (args[i] == argName) {
            found <- TRUE
            iArg <- i
            break
        }
    }

    if (hasValue) {

        # give error if not found
        if (required & !found) {
            stop(paste0("Argument '", argName, "' not found."))
        }

        # return default value if not found
        if (!required & !found) {
            return(defaultValue)
        }

        # the argument value should be the next one in the vector
        iArg <- iArg + 1

        # give error if no argument value given
        if (iArg > length(args)) {
            stop(paste0("No argument value given for argument '", argName, "'."))
        }

        # get argument value and make sure it does not start with -
        argValue <- args[iArg]
        if (substr(argValue, 1, 1) == "-") {
            stop(paste0("Argument value '", argValue, "' for argument '", argName, "' cannot start with '-'."))
        }

        # give error if argument value not allowed
        if (!all(is.na(allowedValues)) & !(argValue %in% allowedValues)) {
            stop(paste0("Argument value '", argValue, "' for argument '", argName, "' not allowed."))
        }

        # return the argument value
        return(argValue)

    } else {
        return(found)
    }
}

displayHelp <- function() {
    cat("Usage: opaiapp.R -i <input directory> -o <output directory> [-m <method>]\n")
    cat("Options:\n")
    cat("  -i <input directory>   The directory containing the input files.\n")
    cat("  -o <output directory>  The directory to output the results to.\n")
    cat("  -m <method>            The method to use to match prediction states to virtual states. Can be 'min', 'mean', or 'max'. Default is 'mean'.\n")
}

#' Parses the user arguments
parseArgs <- function(args) {

    # check if no arguments given (should do nothing)
    if (length(args) == 0) {
        return(list(doNothing=TRUE))
    }

    # check if help was requested
    if ((length(args) == 1) & (args[1] == "-h")) {
        displayHelp()
        return(list(doNothing=TRUE))
    }

    # parse the arguments
    checkNumberOfArguments(args)
    return(list(
        doNothing = FALSE,
        inputDir = getArgument(args, "-i",  TRUE, TRUE, NA, NA),
        outputDir =  getArgument(args, "-o", TRUE, TRUE, NA, NA),
        method =  getArgument(args, "-m", TRUE, FALSE, "mean", c("min", "mean", "max"))
    ))

}

args <- commandArgs(trailingOnly=TRUE)
clp <- parseArgs(args)
outputDir <- main(clp)

#!/usr/bin/env Rscript

source(paste0(getwd(),"/mlapps/OPAi/opaiapp.R"))
library('testthat')

#' Runs a specific test case
runTestCase <- function(testDir, expectedDir, method) {

    # do run
    args <- c("-i", paste0(testDir, "input/"), "-o", paste0(testDir, "temp_output/"), "-m", method)
    clp <- parseArgs(args)
    outputDir <- main(clp)

    # make filenames for expected and actual output files
    assignmentActual <- paste0(outputDir,           "OPAi-assignment-details.csv")
    assignmentExpect <- paste0(testDir, expectedDir,"OPAi-assignment-details.csv")
    predictionActual <- paste0(outputDir,           "OPAi-prediction-output.csv")
    predictionExpect <- paste0(testDir, expectedDir,"OPAi-prediction-output.csv")
    variablesActual <-  paste0(outputDir,           "OPAi-variable-details.csv")
    variablesExpect <-  paste0(testDir, expectedDir,"OPAi-variable-details.csv")

    # cat("This is the path of assignmentActual -->", assignmentActual, "\n")
    # cat("This is the path of assignmentExpect -->", assignmentExpect, "\n")
    # cat("This is the path of predictionActual -->", predictionActual, "\n")
    # cat("This is the path of predictionExpect -->", predictionExpect, "\n")
    # cat("This is the path of variablesActual -->", variablesActual, "\n")
    # cat("This is the path of variablesExpect -->", variablesExpect, "\n")

    # test exit status and existence of output files
    expect_true(file.exists(assignmentActual))
    expect_true(file.exists(predictionActual))
    expect_true(file.exists(variablesActual))

    # test output files against expected output
    expect_equal(read.csv(assignmentActual), read.csv(assignmentExpect))
    expect_equal(read.csv(predictionActual), read.csv(predictionExpect))
    expect_equal(read.csv(variablesActual), read.csv(variablesExpect))

    # remove run output directory
    unlink(paste0(testDir, "temp_output"), recursive=TRUE)

}

generalDir = paste0(getwd(),'/mlapps/OPAi/tests/')

# The end-to-end test cases
test_that("Test end-to-end case 1",         {runTestCase(paste0(generalDir,"test1/"), "outputexpected/", "mean")})
test_that("Test end-to-end case 2",         {runTestCase(paste0(generalDir,"test2/"), "outputexpected/", "mean")})
test_that("Test end-to-end case 3 (min)",   {runTestCase(paste0(generalDir,"test3/"), "outputexpectedMin/", "min")})
test_that("Test end-to-end case 3 (mean)",  {runTestCase(paste0(generalDir,"test3/"), "outputexpectedMean/", "mean")})
test_that("Test end-to-end case 3 (max)",   {runTestCase(paste0(generalDir,"test3/"), "outputexpectedMax/", "max")})
test_that("Test end-to-end case 4",         {runTestCase(paste0(generalDir,"test4/"), "outputexpected/", "mean")})
test_that("Test end-to-end case 5",         {runTestCase(paste0(generalDir,"test5/"), "outputexpected/", "mean")})
test_that("Test end-to-end case 6",         {runTestCase(paste0(generalDir,"test6/"), "outputexpected/", "mean")})
test_that("Test end-to-end case 7",         {runTestCase(paste0(generalDir,"test7/"), "outputexpected/", "mean")})


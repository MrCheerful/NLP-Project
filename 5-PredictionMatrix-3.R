#---
# author: "MrCheerful"
# date: "2017-06-04"
#---
# file: 5-PredictionMatrix-3.R

# Objective - script to build the prediction matrix

# 2017-06-04 Developing 
#   1. Recoded many functions to run more efficiently.

## SET UP ENVIRONMENT

#library(ggplot2); 
#library(parallel); 
#library(dplyr); 
#library(RWeka); 
#library(magrittr); 
#library(tm); 
library(stringi)
#library(slam)
library(stringr)

#------------------------------------
# Ensure the latest functions are being used.
source('~/R Zone/2017-04 John Hopkins Data Science Program Notes/10_Capstone Project/A-Functions.R')

# Regenerate the complex convesions data frame
# rm(complex.df)
# unlink("complex.Rdata")
# complex.df <- gen.complex.df()

# Ensure complex diction is loaded
complex.df <- get.complex.df()

# Ensure word to code dictionary is loaded
word.dict <- get.word.dict()

# Load existing p.df (prediction matrix)
p.df <- get.p.df()

#-----------------------------------

process.text <- function(textcorpus, p.df, logname){
      
      wordvector <- character(0)
      wordlist <- list()
      codevector <- integer(0)
      codelist <- list()
      t.df <- data.frame(w2 = integer(), w1 = integer(), w0 = integer(), wp = integer(), freq = integer())
      
      ## Step 1. Parse the training set into word vectors
      cat("1")
      s1 <- system.time({
            for (i in seq_along(textcorpus)){
                  wordlist <- c(wordlist, text2word(textcorpus[i]))
            }  
      })
      
      ## Step 2. Convert word vectors to code vectors
      cat("2")
      s2 <- system.time({
            for (i in seq_along(wordlist)){
                  wordvector <- unlist(wordlist[i])
                  codevector <- word2code(wordvector, word.dict)
                  codelist <- c(codelist,list(codevector))
            }  
      })
      
      ## Step 3. Convert code vectors to 4gram dataframes
      cat("3")
      s3 <- system.time({
            for (i in seq_along(codelist)){
                  codevector <- unlist(codelist[i])
                  t.df <- rbind(t.df, code2df(codevector))
            } 
      })
      
      ## Step 4. Compact t.df
      cat("4")
      s4 <- system.time({
            p.df <- add2p.df(t.df, p.df)
      })

      ## Step 5. Save log info
      cat("5 ")
      # retrieve log file
      logfile <- "5-PredictM-3-log.Rdata"
      if (file.exists(logfile)){
            load(logfile)
      } 
      # format new row for log file
      nlog <- data.frame (log=logname, s1=s1[3], s2=s2[3], s3=s3[3], s4=s4[3])
      row.names(nlog) <- date()
      # append or store log
      if (exists("time.log")){ 
            time.log <- rbind(time.log,nlog) 
      } else  time.log <- nlog 
      save(time.log, file=logfile)            
      
      ## return revised p.df
      p.df
}


#----------------------------------------------------------------------

# Select the training sets to be processed
FileList <- data.frame(name=as.character(dir('data-3-split')), stringsAsFactors=FALSE)
#FileListV <- c(FileList[4:8,1], FileList[12:16,1], FileList[20:24,1])
FileListV <- c(FileList[c(12,4,20,13,5,21),1])
               
# Loop around training set files

for ( a in seq_along(FileListV)) {
      
      ## Load the training dataset
      con <- file(paste0('./data-3-split/',FileListV[a]))
      #text <- readLines(con, warn=FALSE, encoding='UTF-8' )
      textV <- readLines(con, warn=FALSE, encoding='latin-1' )
      close(con)
      rm(con)

      cat("Processing: ",FileListV[a],". " )
      
      p.df <- process.text(textV, p.df, FileListV[a])

      save(p.df, file="predictmatrix.Rdata")
      cat("Completed: ", FileListV[a],".")
      print("")
      load("5-PredictM-3-log.Rdata")
      print(time.log)
}

# Convert it to a list of matricies for quicker retrieval   Warning takes a long time to run

list.pdf <- pdf2listpdf(p.df)
save(list.pdf, file="predictlist.Rdata")

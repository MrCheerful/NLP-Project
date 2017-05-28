#---
# author: "MrCheerful"
# date: "May 7, 2017"
#---

# version -2  2017-05-27 Need to redo cleaning including 1 and 2 character words.
# the resulting TDM's will be only used to generate the top 1000 (or other quantity)
# words for the prediction matrix.


#library(ggplot2); 
library(parallel); 
#library(dplyr); 
library(RWeka); 
#library(magrittr); 
library(tm); 
#library(stringi)
library(slam)

# 2017-05-12 Cleaning process is set up as a function

# input is to be the text file from the split dataset

preclean <- function(in.file, out.file=NULL,
                     in.path="./data-3-split/",
                     out.path="./data-4-cleaned-2/",
                     routine=1){

      # set the name for the object
      varname <- paste(strsplit(in.file,"[.]")[[1]][1],"-m",routine,sep="")
      if (is.null(out.file)){
            out.file <- paste(varname, ".Rdata", sep="")
      }

      ## Load the file to be processed
      raw <- readLines(con=paste(in.path,in.file,sep=""), 
                       warn=FALSE, encoding='UTF-8' )

      ## Set up parallel processing
      cl <- makeCluster(detectCores())
      tm_parLapply_engine(cl)

      ## Put loaded file into a corpus
      s1 <- system.time(corp <- VCorpus(VectorSource(raw)))
      rm(raw)

      ## Cleaning routine for corpus
      # remove non-english characters.  This doesn't want to work using parLapply.
      # (code credit to Yanchang Zhao, "R Data Mining, 2012")
      clean <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)

      # export clean function to parallel cluster
      clusterExport(cl, "clean")

      s2 <- system.time(corp <- tm_map(corp, content_transformer(clean)))

      # other cleaning operations
      s3 <- system.time({
            corp <- tm_map(corp, removeNumbers)
            corp <- tm_map(corp, removePunctuation)
            corp <- tm_map(corp, content_transformer(tolower))
            corp <- tm_map(corp, stripWhitespace)
      })


      ## TDM
      if (routine==1) {
            s4 <- system.time(corp <- TermDocumentMatrix(corp, control = list(wordLengths=c(1,Inf))))
      } else if (routine==2) {
            gram2 <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
            s4 <- system.time(corp <- TermDocumentMatrix(corp, control = list(wordLengths=c(1,Inf),tokenize = gram2)))
      }

      # Stop parallelization
      tm_parLapply_engine(NULL)
      stopCluster(cl)

      # retrieve log file
      logfile <- paste(out.path, "log.Rdata", sep="")
      if (file.exists(logfile)){
            load(logfile)
      } 
      # format new row for log file
      nlog <- data.frame (in.file=in.file, out.file=out.file, 
                          routine=routine, s1=s1[3], s2=s2[3], s3=s3[3], s4=s4[3])
      row.names(nlog) <- date()
      # append or store log
      if (exists("time.log")){ 
            time.log <- rbind(time.log,nlog) 
      } else  time.log <- nlog 
      save(time.log, file=logfile)
      
      assign(paste(varname), corp)
      rm(corp)
      
      # save tdm out to Rdata file.
      save(list=varname, file=paste(out.path,out.file,sep=""))
      
      rm(list=varname)

}

# cleanings required of version 2 level
#preclean('blog-train.txt')
#preclean('news-train.txt')
#preclean('twit-train.txt')

# test to make sure it all works
preclean('news-train01.txt')

# save the list of top words into 'good_words.Rdata'

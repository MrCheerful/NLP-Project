#---
# author: "MrCheerful"
# date: "May 27, 2017"
#---
# file: 5-PredictionMatrix-1.R
# 2017-05-27 Developing 
#   1. Prediction matrix
#   2. Routine for preparing prediction matrix but also parsing input words
#   3. Routine for returning predicted words
#   4. Routine for converting indexed phrase back to sentance
#   5. Test routine for evaluating accuracy of predictions

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

## Functions

# Function to break up a paragraph into sentances
# from https://stackoverflow.com/questions/18712878/r-break-corpus-into-sentences

chunk_into_sentences <- function(text) {
      break_points <- c(1, as.numeric(gregexpr('[[:alnum:] ][.!?]', text)[[1]]) + 1)
      sentences <- NULL
      for(i in 1:length(break_points)) {
            res <- substr(text, break_points[i], break_points[i+1]) 
            if(i>1) { sentences[i] <- sub('. ', '', res) } else { sentences[i] <- res }
      }
      sentences <- sentences[sentences=!is.na(sentences)]
      return(sentences)
}

#-----------------------------------

# Routine for inserting a indexed text vector into prediction data frame

addToPredictionMatrix <- function(indexV, p.df) {
      
      # break sentance vector into temporary data frame of 4 grams
      t.df <- data.frame(w2 = integer(), w1 = integer(), w0 = integer(), wp = integer(), freq = integer())
      
      for (a in 1:(length(indexV)-3)){
            t.df[a,] <- c(indexV[a], indexV[a+1], indexV[a+2], indexV[a+3], 1)      
      }
      
      # loop through tdf and insert 4 grams into prediction dataframe
      for (b in 1:length(t.df$wp)){
            
            #search for matching row
            rn <- which(p.df$w2==t.df$w2[b] & p.df$w1==t.df$w1[b] & p.df$w0==t.df$w0[b] & p.df$wp==t.df$wp[b])
            
            # if match found -> increment, no match -> add row
            if (!length(rn)){
                  p.df <- rbind(p.df,t.df[b,])
            } else {
                  p.df[rn,'freq'] <- p.df[rn,'freq'] + 1
            }
      }
      p.df
}

#---------------------------
# Dictionary Data Frame Setup - ddf

# load dictionary if it exists, otherwise regenerate it

if(!exists('ddf')){
      if(file.exists("dictionary.Rdata")){
            load("dictionary.Rdata")
      } else {  

# regenerate dictionary
subs.df <- read.csv(text="index,sWord,pWord,grep
1,qqzz1,empty,
2,qqzz2,not-tracked,
3,qqzz3,number, '[$]?[0-9]+(.[0-9]+)*'
4,qqzz4,Mr., ' [Mm]r[.] '
5,qqzz5,Ms., ' [Mm]s[.] '
6,qqzz6,Mrs.,' [Mm]rs[.] '
7,qqzz7,P.S.,' [Pp][.]?[Ss][.]? '
8,qqzz8,vs., ' [Vv][.]?[Ss][.]? '
9,qqzz9,cc., ' [Cc][.]?[Cc][.]? '
10,qqzz10,a.m., ' [Aa][.]?[Mm][.]? '
11,qqzz11,p.m., ' [Pp][.]?[Mm][.]? '
12,qqzz12,A.D., ' [Aa][.]?[Dd][.]? '
13,qqzz13,B.C., ' [Bb][.]?[Cc][.]? '
14,qqzz14,M., ' M[.] ' ")
#15,qqzz15,I\'m, ' [Ii]\'m '
#16,qqzz16,it\'s, ' [Ii]t\'s '                    

load('good_words.Rdata')
a<-length(subs.df$pWord)
temp.df <- data.frame(index = seq(a+1, length.out=length(dictionaryWordsVector)),
                      sWord = dictionaryWordsVector,
                      pWord = dictionaryWordsVector)#,
#                      grep = NA)

ddf <- rbind(subs.df[,1:3],temp.df)
subs.df <- subs.df[3:a,]
save(ddf, subs.df, file="dictionary.Rdata")
rm(temp.df, a, good_words)
}
}

#-------------------------------------

# Setup or Load the prediction matrix

# if prediction matrix doesn't exist create it
# load dictionary if it exists, otherwise create a new empty one

if (!exists('p.df')) {
      if (file.exists("predictmatrix.Rdata")) {
            load("predictmatrix.Rdata")
      } else {  
            p.df <- data.frame(w2 = 0L, w1 = 0L, w0 = 0L, wp = 0L, freq = 0L)
            #            p.df <- data.frame(w2 = integer(), w1 = integer(), w0 = integer(), wp = integer(), freq = integer())
      }
}



#---------------------------------------

# Routine for processing a line of text into vector of dictionary indexes
# pick one line for test processing, the following to be converted to a function

textToIndexedVector <- function(textString){

      # Run the substitution routines
      for (a in seq_along(subs.df$index)){
            textString <- eval(parse(text=paste0("gsub(", subs.df[a,4], ", '", subs.df[a,2], "' , textString)")))
      }

      # break into sentences
#      sentenceV <- chunk_into_sentences(para)

      # lower case
      textString <- tolower(textString)
      
      # remove unnecessary punctuation
      textString <- str_replace_all(textString, pattern = '[[:punct:]]', '')
      
      # remove whitespace
      textString <- str_replace_all(textString, pattern = '\\s+', ' ')
      
      # break sentances up into vectors of words
      wordV <- stri_split_fixed(textString, " ")

# debugging
#      print(wordV)

      ## match and index abbreviations   NOTE CHANGE ddf$pWord to ddf$sWord WHEN GREP ROUTINES DONE
      indexV <- match(wordV[[1]], ddf$pWord, nomatch = '1')

      # insert 3 pre-words and return
      c(0,0,0,indexV)
}

#----------------------------------------

indexedVectorToText <- function(iv){
      ddf[iv,'pWord']
}

#----------------------------------------

basicPrediction <- function(wordV){
      
      indexV <- match(wordV, ddf$pWord, nomatch = '1')
      
      #search for matching rows
      rn <- which(p.df$w2==indexV[1] & p.df$w1==indexV[2] & p.df$w0==indexV[3])
      
      indexedVectorToText(p.df[rn,'wp'])
      
}

#----------------------------------------------------------------------

FileList <- data.frame(name=as.character(dir('data-3-split')), stringsAsFactors=FALSE)
FileListV <- c(FileList[4:8,1], FileList[12:16,1], FileList[20:24,1])

# Loop around training set files

for ( a in seq_along(FileListV)) {
      
      ## Load the training dataset
      con <- file(paste0('./data-3-split/',FileListV[a]))
      #text <- readLines(con, warn=FALSE, encoding='UTF-8' )
      textV <- readLines(con, warn=FALSE, encoding='latin-1' )
      close(con)
      rm(con)

      ## Parse the training set
      for (i in seq_along(textV)){
            p.df <- addToPredictionMatrix(textToIndexedVector(textV[i]), p.df)
      }
      save(p.df, file="predictmatrix.Rdata")
      cat("Completed: ",FileListV[a],".  ")
}


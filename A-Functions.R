#--
#

library(dplyr)
library(stringr)
library(stringi)

#---------------------------
# Load or Generate complex.df - the dataframe for converting complex terms to aliases

get.complex.df <- function(){
# load dataframe for complex to alias conversion if it exists, otherwise regenerate it.
# usage in loading setup routine
# if(!exists('complex.df')){ complex.df <- get.complex.df() }

      if(file.exists("complex.Rdata")){
            load("complex.Rdata")
            complex.df
      } else {  
            # regenerate complex to alias dataframe
            gen.complex.df()
      }
}


gen.complex.df <- function(){            
# generate the complex.df and save it
# note: code does not follow normal indenting for ease of data formatting
      
      complex.df <- read.csv(strip.white=TRUE, as.is = TRUE, 
                              text="alias,complex,grep
qqzz001,not-tracked,'qqzzz'
qqzz002,number,'[$]?[0-9]+(.[0-9]+)*'
qqzz003,M.,     'M[.]'
qqzz004,Mr.,    '[Mm]r[.]'
qqzz005,Ms.,    '[Mm]s[.]'
qqzz006,Mrs.,   '[Mm]rs[.]'
qqzz007,P.S.,   '[Pp][.][Ss][.]'
qqzz008,vs.,    '[Vv][Ss][.]'
qqzz009,c.c.,    '[Cc][.][Cc][.]'
qqzz010,a.m.,   '[Aa][.][Mm][.]'
qqzz011,p.m.,   '[Pp][.][Mm][.]'
qqzz012,A.D.,   '[Aa][.][Dd][.]'
qqzz013,B.C.,   '[Bb][.][Cc][.]'
qqzz014,isn\'t, '[Ii]sn\\'t'   
qqzz015,I\'m,   '[Ii]\\'m'
qqzz016,it\'s,  '[Ii]t\\'s'
qqzz017,don\'t, '[Dd]on\\'t'
qqzz018,we\'re, '[Ww]e\\'re'
qqzz019,hadn\'t,'[Hh]adn\\'t'
qqzz020,they\'re,'[Tt]hey\\'re'
qqzz021,hasn\'t,'[Hh]asn\\'t'
qqzz022,that\'s, '[Tt]hat\\'s'
qqzz023,ain\'t, '[Aa]in\\'t'
qqzz023,Wi-Fi, '[Ww][Ii][-]?[Ff][Ii]'
")
     save(complex.df, file="complex.Rdata")
     complex.df
}

#---------------------------
# Functions to insert or decode aliases using complex.df

complex2alias<- function(text.V, complex.df){
# reviews a text string and replaces complex words with aliases
# input: a text string
# output: a text string
      for (a in seq_along(complex.df$grep)){
            text.V <- eval(parse(text=paste0("gsub(", complex.df[a,'grep'], ", '", complex.df[a,'alias'], "' , text.V)")))
      }
      # for (a in seq_along(complex.df$grep)){
      #       text.V <- str_replace_all(text.V, paste(complex.df$grep[a]), 'test') #complex.df$alias)
      # }
      text.V
}

alias2complex<- function(text.v, complex.df){
      for (a in seq_along(complex.df$alias)){
            text.v <- gsub(complex.df$alias[a], complex.df$complex[a], text.v, fixed=FALSE)
      }
      text.v
}

#---------------------------
# word dictionary functions

get.word.dict <- function(){
      if(file.exists("dictionary.Rdata")){
            load("dictionary.Rdata")
      } else {
            word.dict <- gen.word.dict()
      }
      word.dict
}

gen.word.dict <- function(){
      #collect aliases
      word.dict <- complex.df$alias
      #load saved good words in vector dictionayWordsVector
      load('good_words.Rdata')
      word.dict <- c(word.dict, dictionaryWordsVector)
      rm(dictionaryWordsVector)
      save(word.dict, file="dictionary.Rdata")
      word.dict
}

#---------------------------
# word and code translations

word2code <- function(word.v, word.dict){
      match(word.v, word.dict, nomatch = '1')
}

code2word <- function(code.v, word.dict){
      word.dict[code.v]
}

#---------------------------

text2word <- function(textString){
# Routine for processing a line of text into vector of dictionary indexes
# pick one line for test processing, the following to be converted to a function

      # Run the substitution routines
      textString <- complex2alias(textString, complex.df)
      
      # break into sentences
      #      sentenceV <- chunk_into_sentences(para)
      
      # lower case
      textString <- tolower(textString)
      
      # remove unnecessary punctuation
      textString <- str_replace_all(textString, pattern = '[[:punct:]]', '')
      
      # remove whitespace
      textString <- str_replace_all(textString, pattern = '\\s+', ' ')
      
      # break sentances up into vectors of words
      word.v <- stri_split_fixed(textString, " ")
      
      word.v
}      

#----------------------------
# Prediction matrix functions
# Usage:  if (!exists('p.df')) { p.df <- get.p.df() }

get.p.df <- function(){
# retrieve the prediction matrix from file if it exists
# otherwise generate a new empty one.
      
            if (file.exists("predictmatrix.Rdata")) {
            load("predictmatrix.Rdata")
      } else {
            p.df <- gen.p.df()
      }
      p.df
}

gen.p.df <- function(){
      p.df <- data.frame(w2 = 0L, w1 = 0L, w0 = 0L, wp = 0L, freq = 0L)
      save(p.df,file="predictmatrix.Rdata")
}

### Original Code2DF function - worked row by row,  changed below to column by column
# code2df <- function(code.v) {
# # Routine for inserting a code vector into the prediction data frame
#       # insert 3 pre-words and return
#       code.v <- c(0,0,0,code.v)
#       
#       # break sentance vector into temporary data frame of 4 grams
#       t.df <- data.frame(w2 = integer(), w1 = integer(), w0 = integer(), wp = integer(), freq = integer())
#       
#       for (a in 1:(length(code.v)-3)){
#             t.df[a,] <- c(as.integer(code.v[a]), as.integer(code.v[a+1]), 
#                           as.integer(code.v[a+2]), as.integer(code.v[a+3]), 1L )      
#       }
#       t.df
# }

code2df <- function(code.v) {
      # Routine for inserting a code vector into the prediction data frame
      # insert 3 pre-words and return
      l=length(code.v)
      code.v <- c(0,0,0,code.v)
      
      # break sentance vector into temporary data frame of 4 grams
      t.df <- data.frame(w2 = as.integer(code.v[1:l]), 
                         w1 = as.integer(code.v[2:(l+1)]), 
                         w0 = as.integer(code.v[3:(l+2)]), 
                         wp = as.integer(code.v[4:(l+3)]), 
                         freq = 1L)
      t.df
}


add2p.df <- function(t.df, p.df){
      p.df <- bind_rows(p.df, t.df) %>%
      group_by(w2, w1, w0, wp) %>%
      summarize(freq=sum(freq))
      p.df
}      
    
pdf2listpdf <- function(p.df){
      listpdf <- list()
      for (i in seq_along(word.dict)){
            listpdf[[i]] <- filter(p.df, w0==i)
      }
      listpdf
}


#----------------------------

# Prediction Functions

textPredict <- function(inText, word.dict, p.df){
# given an input text line, parse it and return a df with words and probabilities   
      wordv <- unlist(text2word(inText))
      codev <- word2code(wordv, word.dict)
      p0.df <- calc.predict(codev, p.df)
      data.frame(word=code2word(p0.df$wp, word.dict),prob=p0.df$prob)
}

calc.predict <- function(codev, list.pdf){
# input: a vector of word codes  
# return: a dataframe of predicted next words and their probabilities, sorted in decreasing probability.
      #verify codev length and lengthen if necessary, shorten to last three elements.
      l <- length(codev)
      if (l < 3){ codev <- c(0,0,0, codev) }
      code <- tail(codev,3)
      
      # retrieve prediction matrix subset based on w0
      p.df <- list.pdf[[code[3]]]
      
      # subset prediction matrix with matches (0 backoff)
      p0.df <- filter(p.df, w2==code[1], w1==code[2]) #, w0==code[3])
      
      # ? should the out of dictionary be removed?
      
      # determine Katz discount
      l <- dim(p0.df)[1]
      if (l<6) {disc.p0 <- (0.6 - 0.1*l)} else {disc.p0 <- 0}
      # calculate probabilities
      p0.df <- mutate(p0.df, prob = (1-disc.p0)*freq/sum(freq))
      
      # if l<6 then do a backoff - to be added
      
      arrange(p0.df,desc(prob))
}

#----------------------------

# Accuracy and timing test






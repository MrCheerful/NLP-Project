---
title: "take 2"
author: "MrCheerful"
date: "May 7, 2017"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
#library(ggplot2); 
library(parallel); 
#library(dplyr); 
#library(RWeka); 
#library(magrittr); 
library(tm); 
#library(stringi)
```


## Load the files

```{r}
path <- "./datawork/"
#tag <- c("blog", "news", "twit")
tag <- c("twit")

for (i in 1:length(tag)){
      assign(paste(tag[i]), readLines(con=paste(path,tag[i],"-train.txt",sep=""), 
                                      warn=FALSE, encoding='UTF-8' ))
}
rm(i, path)
```

## Set up parallel processing

```{r}
cl <- makeCluster(detectCores())
tm_parLapply_engine(cl)
```




## Put news into a corpus

```{r}
#news.c0 <- VCorpus(VectorSource(news))
twit.c0 <- VCorpus(VectorSource(twit))
#blog.c0 <- VCorpus(VectorSource(blog))

#rm(news); 
rm(twit); 
#rm(blog)
```



## Cleaning routine for corpus

```{r}
# remove non-english characters.  This doesn't want to work using parLapply.
# (code credit to Yanchang Zhao, "R Data Mining, 2012")
clean <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
clusterExport(cl, "clean")

#system.time(news.c1 <- tm_map(news.c0, content_transformer(clean)))
system.time(twit.c1 <- tm_map(twit.c0, content_transformer(clean)))
#system.time(blog.c1 <- tm_map(blog.c0, content_transformer(clean)))

#rm(news.c0); # 
rm(twit.c0); 
#rm(blog.c0)
```
user  system elapsed 
   0.05    0.00    0.04 
   user  system elapsed 
   0.61    0.00    0.63 
   user  system elapsed 
   0.45    0.00    0.45

train50
 user  system elapsed 
   0.46    0.16    1.38 
   user  system elapsed 
  19.67    3.67   36.02 
   user  system elapsed 
   5.63    2.26   10.83 


## Other transformations

```{r}
clean2 <- function(corp){
      corp <- tm_map(corp, removeNumbers)
      corp <- tm_map(corp, removePunctuation)
      corp <- tm_map(corp, content_transformer(tolower))
      corp <- tm_map(corp, stripWhitespace)
}

#system.time(news.c2 <- clean2(news.c1))
system.time(twit.c2 <- clean2(twit.c1))
#system.time(blog.c2 <- clean2(blog.c1))

#rm(news.c1); #
rm(twit.c1); 
#rm(blog.c1)
```
train50
   user  system elapsed 
   2.54    1.17    4.23 
   user  system elapsed 
  80.97   43.75  403.67 
   user  system elapsed 
  32.03   20.03  419.01 


## TDM

```{r}
#system.time(news.tdm1 <- TermDocumentMatrix(news.c2))
#rm(news.c2)
system.time(twit.tdm1 <- TermDocumentMatrix(twit.c2))
rm(twit.c2)
#system.time(blog.tdm1 <- TermDocumentMatrix(blog.c2))
#rm(blog.c2)
```

user  system elapsed 
   0.23    0.00    0.23 
   user  system elapsed 
   4.46    0.01    4.49 
   user  system elapsed 
   2.09    0.00    2.16 

train 50
  user  system elapsed 
   1.55    2.21  540.77 
   user  system elapsed 
  25.25   18.44 1144.00 
   user  system elapsed 
  12.36    1.91   58.59 



# Stop parallelization

```{r}
tm_parLapply_engine(NULL)
stopCluster(cl)
```

# Save TDM Matricies
```{r}
#save(news.tdm1, twit.tdm1, blog.tdm1, file="tdm1-train100.Rdata")
save(twit.tdm1, file="blogtdm1-train100.Rdata")
```

```{r}
#hi
```


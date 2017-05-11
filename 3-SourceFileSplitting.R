## This file will read in each of the source corpus files
## and then split them into Training and Test datasets
## as well as making some smaller sets for development.
##
## intermediate datasets will be saved into ./datawork
##
## files will be named source-group.txt
## where source is the tag for the source file - blog, news, twit
## and group is the subset of the original data
##           train100 - 100% of training portion - 70% of original
##           train50 - 50% of training portion
##           train10 - 10% of training portion
##           train1 - 1% of training portion
##           test1 - 50% of test portion - 30% of original
##           test2 - other 50% of test portion
##

# set up vectors for data loading
tag <- c("news", "blog", "twit")
path <- "./Coursera-SwiftKey/final/en_US/"
file <- c("en_US.news.txt", "en_US.blogs.txt", "en_US.twitter.txt")

# load the files
for (i in 1:length(file)){
      assign(paste(tag[i]), readLines(con=paste(path,file[i],sep=""), warn=FALSE, encoding='UTF-8' ))
}

# set up vectors for splitting and saving
spath <- "./datawork"

# set up function for making a vector with splits to the dataset
splits <- function(n, blocks=c(train=0.70, test1=0.15, test2=0.15) ){
      sp <- as.integer(n*blocks)
      err <- n - sum(sp)
      sp[1] <- sp[1] + err
      names(sp) <- names(blocks)
      sample(c(rep(names(sp),sp)))
}      

# create split vector for each dataset
news.s <- splits(length(news))
blog.s <- splits(length(blog))
twit.s <- splits(length(twit))

bl <- c("train", "test1", "test2")

# split and write
for (i in 1:length(tag)){ 
      for (j in 1:length(bl)){
            fname <- paste(spath,"/",tag[i],"-",bl[j],".txt", sep="")
            dataf <- paste(tag[i],"[",tag[i],".s=='",bl[j],"']",sep="")
            datas <- eval(parse(text=dataf))
            writeLines(datas, fname)
            close(file(fname))
      }
}

# now create the training subsets
for (i in 1:length(tag)){ 
      assign(paste(tag[i],".train",sep=""), eval(parse(text=paste(tag[i],"[",tag[i],".s=='train']",sep=""))) )
}

# set up the split block
bl2 <- c(train50=0.5, train25=0.25, train10=0.10, train01=0.01, trainrest=0.14)
bl2n <- names(bl2)

# create the split vectors for each dataset
for (i in 1:length(tag)){
      expr <- paste(tag[i],".t <- splits(length(",tag[i],".train), bl2)", sep="")
      print(expr)
      eval(parse(text=expr))
}

# split and write
for (i in 1:length(tag)){ 
      for (j in 1:length(bl2n)){
            fname <- paste(spath,"/",tag[i],"-",bl2n[j],".txt", sep="")
            dataf <- paste(tag[i],".train[",tag[i],".t=='",bl2n[j],"']",sep="")
            datas <- eval(parse(text=dataf))
            writeLines(datas, fname)
            close(file(fname))
      }
}


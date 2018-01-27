con1 <- file("SwiftKey/en_US/en_US.twitter.txt", "r")
con2 <- file("SwiftKey/en_US/en_US.news.txt", "r") 
con3 <- file("SwiftKey/en_US/en_US.blogs.txt", "r") 

US_Twitter <- readLines(con1)
US_Twitter.cleaned <- gsub('[[:punct:]]', '', US_Twitter)
US_Twitter.cleaned <- gsub('[[:digit:]]+', '', US_Twitter.cleaned)

US_Twitter.length <- nchar(US_Twitter.cleaned)
max(US_Twitter.length)
min(US_Twitter.length)

masterString_Twitter <- paste(US_Twitter.cleaned, collapse = ' ', sep = " ")
masterVector_Twitter <- strsplit(masterString_Twitter, " ")[1]
masterTable_Twitter <- sort(table(masterVector_Twitter), decreasing = T)

# ----

US_Blogs <- readLines(con2)
US_Blogs.cleaned <- gsub('[[:punct:]]', '', US_Blogs)
US_Blogs.cleaned <- gsub('[[:digit:]]+', '', US_Blogs.cleaned)

US_Blogs.length <- nchar(US_Blogs.cleaned)
max(US_Blogs.length)
min(US_Blogs.length)

masterString_Blogs <- paste(US_Blogs.cleaned, collapse = ' ', sep = " ")
masterVector_Blogs <- strsplit(masterString_Blogs, " ")[1]
masterTable_Blogs <- sort(table(masterVector_Blogs), decreasing = T)

# ----

US_News <- readLines(con3)
US_News.cleaned <- gsub('[[:punct:]]', '', US_News)
US_News.cleaned <- gsub('[[:digit:]]+', '', US_News.cleaned)

US_news.length <- nchar(US_News.cleaned)
max(US_news.length)
min(US_news.length)

masterString_News <- paste(US_News.cleaned, collapse = ' ', sep = " ")
masterVector_News <- strsplit(masterString_News, " ")[1]
masterTable_News <- sort(table(masterVector_News), decreasing = T)


# ----

require("tm")
library(tm)
library(RWeka)
removeWords(masterString_Twitter,"RT")

barplot(masterTable_News[1:20], names.arg = names(masterTable_News[1:20]))

masterTable <- data.frame("Twitter" = masterTable_Twitter[1:20], "Blog" = masterTable_Blogs[1:20], 
                          "news" = masterString_News[1:20])

twitterDF <- as.data.frame(masterTable_Twitter)
blogDF <- as.data.frame(masterTable_Blogs)
newsDF <- as.data.frame(masterTable_News)

myl <- list(A = twitterDF$masterVector_Twitter[1:100],
            B = blogDF$masterVector_Blogs[1:100],
            C = newsDF$masterVector_News[1:100])
lapply(1:length(myl), function(n) setdiff(myl[[n]], unlist(myl[-n])))

#-----

US_Twitter_Sample <- sample(US_Twitter, 1000)
corp <- Corpus(VectorSource(US_Twitter_Sample))

corpus.ng = tm_map(corp,removePunctuation)
corpus.ng = tm_map(corpus.ng,removeNumbers)

BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 1))
tdm.bigram = TermDocumentMatrix(corpus.ng,
                                control = list(tokenize = BigramTokenizer))

freq = sort(rowSums(as.matrix(tdm.bigram)),decreasing = TRUE)
freq.df = data.frame(word=names(freq), freq=freq)
head(freq.df, 20)


#----
tdm <- TermDocumentMatrix(corpus.ng, control=list(tokenize =  RWeka::WordTokenizer, 
                                              wordLengths = c(1, Inf)))
head(sort(slam::row_sums(tdm), decreasing = TRUE), 12)

t.twitter <- as.data.frame(head(sort(slam::row_sums(tdm), decreasing = TRUE), 12)) 
t2.twitter <- data.frame("y" = t.twitter[,1], "x" = row.names(t.twitter))

p<-ggplot(data=t2.twitter, aes(x=x, y=y)) +
    geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 60, hjust = 1))
p

library(ggplot2)
# Basic barplot
p<-ggplot(data=df, aes(x=dose, y=len)) +
    geom_bar(stat="identity")
p

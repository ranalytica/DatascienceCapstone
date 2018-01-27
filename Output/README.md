---
title: "Week 02 Milestone Report of Capstone Project"
author: "Thiloshon Nagarajah"
date: "October 31, 2017"
output: html_document
---

```{r setup, include=FALSE,cache=TRUE}
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(cache=TRUE)
```

## Synopsis

The task of capstone project is to understand and build predictive text models that will help users in typing sentences faster in keypads. A typical example is the SwiftKey Keyboard in mobile devices. The project will start with the basics, analyzing a large corpus of text documents to discover the structure in the data and how words are put together. It will cover cleaning and analyzing text data, then building and sampling from a predictive text model. The libraries and frameworks to use were analysed and tm for text mining and RWeka for Tokenizing and creating n-grams were choosen. The tokenizer function in RWeka gave unexpected results for tm 0.7 version. So tm was downversioned to 0.6 to continue the project. For profanity filtering Carnegie Mellon University Luis von Ahn’s Research Group's bad word collection was used.

## Dataset
The dataset I am using is provided by the Coursera Course and is created by folks at Swiftkey. The dataset is in 4 languages,

* English
* German
* Finnish
* Russian

and each language contains text documents from different sources,

 *  Twitter Tweets
 *  Blogs
 *  News

Lets try to quantify the raw English dataset.

```{r one, echo=FALSE }
suppressWarnings(suppressPackageStartupMessages(library(knitr))) 
suppressWarnings(suppressPackageStartupMessages(library(tm)))
suppressWarnings(suppressPackageStartupMessages(library(ggplot2)))
suppressWarnings(suppressPackageStartupMessages(library(RWeka)))
con1 <- file("SwiftKey/en_US/en_US.twitter.txt", "r")
con2 <- file("SwiftKey/en_US/en_US.news.txt", "r")
con3 <- file("SwiftKey/en_US/en_US.blogs.txt", "r")

US_Twitter <- suppressWarnings(readLines(con1))
US_Blogs <- suppressWarnings(readLines(con2))
US_News <- suppressWarnings(readLines(con3))

masterString_Twitter <- paste(US_Twitter, collapse = ' ', sep = " ")
masterVector_Twitter <- strsplit(masterString_Twitter, " ")[1]

masterString_Blogs <- paste(US_Blogs, collapse = ' ', sep = " ")
masterVector_Blogs <- strsplit(masterString_Blogs, " ")[1]

masterString_News <- paste(US_News, collapse = ' ', sep = " ")
masterVector_News <- strsplit(masterString_News, " ")[1]


rawStatistics <-
data.frame(
"TextDocument" = c("Twitter", "News", "Blogs"),
"Lines" = c(length(US_Twitter), length(US_News), length(US_Blogs)),
"Words" = c(length(masterVector_Twitter[[1]]), length(masterVector_News[[1]]), length(masterVector_Blogs[[1]])),
"MaxWords" = c(max(lengths(strsplit(US_Twitter, " "))), max(lengths(strsplit(US_News, " "))), max(lengths(strsplit(US_Blogs, " ")))),
"AvgWords" = c(mean(lengths(strsplit(US_Twitter, " "))), mean(lengths(strsplit(US_News, " "))), mean(lengths(strsplit(US_Blogs, " ")))),
"Characters" = c(nchar(masterString_Twitter), nchar(masterString_News), nchar(masterString_Blogs)),
"MaxChars" = c(max(nchar(US_Twitter)), max(nchar(US_News)), max(nchar(US_Blogs))),
"AvgChars" = c(mean(nchar(US_Twitter)), mean(nchar(US_News)), mean(nchar(US_Blogs)))
)
kable(rawStatistics, caption = "RAW Data")
```

## Loading Data

Data was downloaded from the Coursera Course Page by using the url <https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip>. The dataset was loaded into R by using file and readline function.

```{r eval=FALSE}
con1 <- file("SwiftKey/en_US/en_US.twitter.txt", "r")
US_Twitter <- readLines(con1)
```

The main concern in doing text mining is the resource. Text mining requires alot of computational power and memory in particular. Even though the data set i have is couple of millions of records long, I could only load around 50000 records of data in memory in one go. So I have decided to random subsample the data and get a fraction of data to continue the project. 

```{r}
US_Twitter_Sample <- sample(US_Twitter, 50000)
US_News_Sample <- sample(US_News, 50000)
US_Blogs_Sample <- sample(US_Blogs, 50000)
```

Now the statistics are as follows,
```{r two, echo=FALSE}
US_Twitter <- US_Twitter_Sample
US_News <- US_News_Sample
US_Blogs <- US_Blogs_Sample

masterString_Twitter <- paste(US_Twitter, collapse = ' ', sep = " ")
masterVector_Twitter <- strsplit(masterString_Twitter, " ")[1]

masterString_Blogs <- paste(US_Blogs, collapse = ' ', sep = " ")
masterVector_Blogs <- strsplit(masterString_Blogs, " ")[1]

masterString_News <- paste(US_News, collapse = ' ', sep = " ")
masterVector_News <- strsplit(masterString_News, " ")[1]

rawStatistics <-
data.frame(
"TextDocument" = c("Twitter", "News", "Blogs"),
"Lines" = c(length(US_Twitter), length(US_News), length(US_Blogs)),
"Words" = c(length(masterVector_Twitter[[1]]), length(masterVector_News[[1]]), length(masterVector_Blogs[[1]])),
"MaxWords" = c(max(lengths(strsplit(US_Twitter, " "))), max(lengths(strsplit(US_News, " "))), max(lengths(strsplit(US_Blogs, " ")))),
"AvgWords" = c(mean(lengths(strsplit(US_Twitter, " "))), mean(lengths(strsplit(US_News, " "))), mean(lengths(strsplit(US_Blogs, " ")))),
"Characters" = c(nchar(masterString_Twitter), nchar(masterString_News), nchar(masterString_Blogs)),
"MaxChars" = c(max(nchar(US_Twitter)), max(nchar(US_News)), max(nchar(US_Blogs))),
"AvgChars" = c(mean(nchar(US_Twitter)), mean(nchar(US_News)), mean(nchar(US_Blogs)))
)
kable(rawStatistics, caption = "Sample Data")
```

And finally the text documents were converted to corpus objects.

```{r}
twitter <- Corpus(VectorSource(US_Twitter))
```

## Preprocessing

There were few concerns to be addressed in the dataset we gathered. The following few steps show how these concerns were addressed.

```{r}
# the puncuations and numbers in the texts were removed as there is no need to predict punctations or numbers
twitter.cleaned <- tm_map(twitter,removePunctuation)
twitter.cleaned <- tm_map(twitter.cleaned,removeNumbers)

# Profanity filtering was done
twitter.cleaned <- tm_map(twitter.cleaned, removeWords, readLines("bad-words.txt"))
```

```{r echo=FALSE}
news <- Corpus(VectorSource(US_News))
blogs <- Corpus(VectorSource(US_Blogs))

news.cleaned <- tm_map(news,removePunctuation)
news.cleaned <- tm_map(news.cleaned,removeNumbers)
news.cleaned <- tm_map(news.cleaned, removeWords, readLines("bad-words.txt"))

blogs.cleaned <- tm_map(blogs,removePunctuation)
blogs.cleaned <- tm_map(blogs.cleaned,removeNumbers)
blogs.cleaned <- tm_map(blogs.cleaned, removeWords, readLines("bad-words.txt"))
```

After cleaning and profanity filtering, the dataset is as follows,

```{r three, echo=FALSE}
US_Twitter <- data.frame(text=unlist(sapply(twitter.cleaned, `[`, "content")), 
    stringsAsFactors=F)[,1]
US_News <- data.frame(text=unlist(sapply(news.cleaned, `[`, "content")), 
    stringsAsFactors=F)[,1]
US_Blogs <- data.frame(text=unlist(sapply(blogs.cleaned, `[`, "content")), 
    stringsAsFactors=F)[,1]

masterString_Twitter <- paste(US_Twitter, collapse = ' ', sep = " ")
masterVector_Twitter <- strsplit(masterString_Twitter, " ")[1]

masterString_Blogs <- paste(US_Blogs, collapse = ' ', sep = " ")
masterVector_Blogs <- strsplit(masterString_Blogs, " ")[1]

masterString_News <- paste(US_News, collapse = ' ', sep = " ")
masterVector_News <- strsplit(masterString_News, " ")[1]

rawStatistics <-
data.frame(
"TextDocument" = c("Twitter", "News", "Blogs"),
"Lines" = c(length(US_Twitter), length(US_News), length(US_Blogs)),
"Words" = c(length(masterVector_Twitter[[1]]), length(masterVector_News[[1]]), length(masterVector_Blogs[[1]])),
"MaxWords" = c(max(lengths(strsplit(US_Twitter, " "))), max(lengths(strsplit(US_News, " "))), max(lengths(strsplit(US_Blogs, " ")))),
"AvgWords" = c(mean(lengths(strsplit(US_Twitter, " "))), mean(lengths(strsplit(US_News, " "))), mean(lengths(strsplit(US_Blogs, " ")))),
"Characters" = c(nchar(masterString_Twitter), nchar(masterString_News), nchar(masterString_Blogs)),
"MaxChars" = c(max(nchar(US_Twitter)), max(nchar(US_News)), max(nchar(US_Blogs))),
"AvgChars" = c(mean(nchar(US_Twitter)), mean(nchar(US_News)), mean(nchar(US_Blogs)))
)
kable(rawStatistics, caption = "Cleaned Data")
```


## Tokenization and N-Gram Modelling

Next I created a basic 1-Gram model to inspect what are the mostly used words in the dataset. 

```{r four, echo=FALSE}
tdm.twitter <-
    TermDocumentMatrix(twitter.cleaned,
    control = list(
    tokenize =  RWeka::WordTokenizer,
    wordLengths = c(1, Inf)
    ))

tdm.blogs <-
    TermDocumentMatrix(blogs.cleaned,
    control = list(
    tokenize =  RWeka::WordTokenizer,
    wordLengths = c(1, Inf)
    ))

tdm.news <-
    TermDocumentMatrix(news.cleaned,
    control = list(
    tokenize =  RWeka::WordTokenizer,
    wordLengths = c(1, Inf)
    ))

```

The 10 most used words in Twitter dataset:

```{r five, echo=FALSE}
t.twitter <- as.data.frame(head(sort(slam::row_sums(tdm.twitter), decreasing = TRUE), 10)) 
t2.twitter <- data.frame("y" = t.twitter[,1], "x" = row.names(t.twitter))

p<-ggplot(data=t2.twitter, aes(x=x, y=y)) +
    geom_bar(stat="identity")
p
```

The 10 most used words in Blogs dataset:

```{r  echo=FALSE}
t.blogs <- as.data.frame(head(sort(slam::row_sums(tdm.blogs), decreasing = TRUE), 10)) 
t2.blogs <- data.frame("y" = t.blogs[,1], "x" = row.names(t.blogs))

p<-ggplot(data=t2.blogs, aes(x=x, y=y)) +
    geom_bar(stat="identity")
p
```

The 10 most used words in News dataset:

```{r  echo=FALSE}
t.news <- as.data.frame(head(sort(slam::row_sums(tdm.news), decreasing = TRUE), 10)) 
t2.news <- data.frame("y" = t.news[,1], "x" = row.names(t.news))

p<-ggplot(data=t2.news, aes(x=x, y=y)) +
    geom_bar(stat="identity")
p
```

As we can see, most of the top 10 words are actually pretty much the same. 

The similar words in Twitter and Blogs are:

```{r echo=FALSE}
intersect(row.names(t.twitter), row.names(t.blogs))
```

The similar words in Twitter and News are:

```{r echo=FALSE}
intersect(row.names(t.twitter), row.names(t.news))
```

The similar words in Blogs and News are:

```{r echo=FALSE}
intersect(row.names(t.blogs), row.names(t.news))
```

And, the similar words in all sets are:

```{r echo=FALSE}
intersect(row.names(t.twitter), intersect(row.names(t.blogs), row.names(t.news)) )
```

Here its interesting to note 7 out of 10 most used words are same in all three datasets.

Now, lets observe how the 2-Grams and 3-Grams in Twitter data set looks like.

2-Gram

```{r six, echo=FALSE}
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
tdm.bigram = TermDocumentMatrix(twitter.cleaned,
                                control = list(tokenize = BigramTokenizer))
t.twitter <- as.data.frame(head(sort(slam::row_sums(tdm.bigram), decreasing = TRUE), 20)) 
t2.twitter <- data.frame("y" = t.twitter[,1], "x" = row.names(t.twitter))

p<-ggplot(data=t2.twitter, aes(x=x, y=y)) +
    geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 60, hjust = 1))
p
```

3-Gram

```{r seven, echo=FALSE}
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
tdm.bigram = TermDocumentMatrix(twitter.cleaned,
                                control = list(tokenize = BigramTokenizer))
t.twitter <- as.data.frame(head(sort(slam::row_sums(tdm.bigram), decreasing = TRUE), 20)) 
t2.twitter <- data.frame("y" = t.twitter[,1], "x" = row.names(t.twitter))

p<-ggplot(data=t2.twitter, aes(x=x, y=y)) +
    geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 60, hjust = 1))
p
```

We can even find data for 2 to N-Grams.

```{r eight,}
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 10))
tdm.bigram = TermDocumentMatrix(twitter.cleaned,
                                control = list(tokenize = BigramTokenizer))
t.twitter <- as.data.frame(head(sort(slam::row_sums(tdm.bigram), decreasing = TRUE), 20)) 
t2.twitter <- data.frame("y" = t.twitter[,1], "x" = row.names(t.twitter))

p<-ggplot(data=t2.twitter, aes(x=x, y=y)) +
    geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 60, hjust = 1))
p

```

## Future Plans

From the N-Grams created we can get an idea of how to predict the texts. 
The 2-Grams and 3-Grams can be used to predict subsequent words and 1-Gram can be used to predict most frequent words.

Other than this some more advanced features such as stemming and tagging can be utilized.


## Update

NextIt (Word/Sentence Prediction System)
========================================================
author: Thiloshon Nagarajah
date: 05 Nov 17
autosize: true

Motivation
========================================================

When we type sentences in our computers or handhelds, it is often helpful if the application could figure out what we are tying to type and suggest words to type. Google Search and Swiftkey Keyboards are very good example of this usecase. 

What if we could create an application which does that? It would help us a lot right? 

Natural Language Processing is a field of Computer Science where Language Models are engineered. This kind of app can be created with NLP technologies and Powerful languages like R. This presentation introduces you to NextIT, a Word/Sentence Prediction App.




Algorithm and Procedure 01
========================================================

The overall algorithm is as follows:

1. Sampling 20% of data for train and rest for test and validation 
2. Getting and cleaning data: Removing punctuations, twitter words, numbers,URLs and profanity words.
3. Tokenizing, Stemming and creating Document Frequency Matrix for 1-gram, 2-grams and 3-grams.
4. Generating probabilities and applying Kneser-Ney Smoothing

I have used the following libraries to develop the application
- Quanteda (I choose this over tm + RWeka as this is very customized for NLP)
- Slam (To speedup sparse matrix calculations)
- data.table (to speedup DFM related calculations)

Algorithm and Procedure 02
========================================================

The model uses Kneser - Ney Smoothing for generating probability distribution using 2 and 3 grams. This also helps finding probability for unknows ngram combinations. 

Here when an unknown ngram is encountered, the model recurses and finds combination of probabilites of lower order models of all smaller ngrmas

I choose Kneser - Ney over Stupid Backoff language model as it is very effective even in small datasets. Since my machine couldn't handle large datasets, kneser - Ney was a good candidate.

If no word is predicted then as fail safe the model randomly returns one of the highly probable word from 1-gram.

App
========================================================

The App uses the above algorithms to find predictions. As a bonus it also tries to find the sentence user is trying to type. 

Access the app in the following URL:
<https://shining-thiloshon.shinyapps.io/NextIT/>

![TheApp](Capture.png)




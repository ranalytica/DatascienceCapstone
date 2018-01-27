library(readtext)

data1 <- read.table("SwiftKey/de_DE/de_DE.blogs.txt", header = T)
data1 <- readtext("SwiftKey/de_DE/de_DE.blogs.txt")

data1 <- quanteda::textfile("SwiftKey/de_DE/de_DE.blogs.txt")


mydoc.txt <-scan("SwiftKey/de_DE/de_DE.blogs.txt", what = "character")


text <- read.delim("this is a test for R load.txt", sep = "/t")


enNews <-scan("SwiftKey/en_US/en_US.news.txt", what = "character")

enBlog <-scan("SwiftKey/en_US/en_US.blogs.txt", what = "character")
head(enBlog, 100)


enTwitter <-scan("SwiftKey/en_US/en_US.twitter.txt", what = "character")
head(enTwitter, 100)

# 

con <- file("SwiftKey/en_US/en_US.twitter.txt", "r") 
lines <- readLines(con)
x <- nchar(lines)
max(x)


con <- file("SwiftKey/en_US/en_US.news.txt", "r") 
lines <- readLines(con)
x <- nchar(lines)
max(x)

con <- file("SwiftKey/en_US/en_US.blogs.txt", "r") 
lines <- readLines(con)
x <- nchar(lines)
max(x)


love <- grepl("love", lines)
summary(love)
hate <- grepl("hate", lines)
summary(hate)

biostats <- grepl("biostats", lines)
which(biostats)
lines[556872]


readLines(con, 1) ## Read the first line of text 
readLines(con, 1) ## Read the next line of text 
readLines(con, 5) ## Read in the next 5 lines of text 
close(con) ## It's important to close the connection when you are done
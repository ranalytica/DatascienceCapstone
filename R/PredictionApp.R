library(quanteda)
library(data.table)

con1 <- file("SwiftKey/en_US/en_US.twitter.txt", "r")
con2 <- file("SwiftKey/en_US/en_US.news.txt", "r")
con3 <- file("SwiftKey/en_US/en_US.blogs.txt", "r")

US_Twitter <- readLines(con1)
US_Blogs <- readLines(con3)
US_News <- readLines(con2)

sampleHolderTwitter <-
    sample(length(US_Twitter), length(US_Twitter) * 0.1)
sampleHolderBlog <- sample(length(US_Blogs), length(US_Blogs) * 0.1)
sampleHolderNews <- sample(length(US_News), length(US_News) * 0.1)

US_Twitter_Sample <- US_Twitter[sampleHolderTwitter]
US_Blogs_Sample <- US_Blogs[sampleHolderBlog]
US_News_Sample <- US_News[sampleHolderNews]

master_vector <-
    c(US_Twitter_Sample, US_Blogs_Sample, US_News_Sample)
corp <- corpus(master_vector)

master_Tokens <- tokenize(
    x = tolower(corp),
    removePunct = TRUE,
    removeTwitter = TRUE,
    removeNumbers = TRUE,
    removeHyphens = TRUE,
    remove_symbols = TRUE,
    remove_url = TRUE,
    verbose = TRUE
)

stemed_words <- tokens_wordstem(master_Tokens, language = "english")

bi_gram <- tokens_ngrams(stemed_words, n = 2)
tri_gram <- tokens_ngrams(stemed_words, n = 3)

uni_DFM <- dfm(stemed_words)
bi_DFM <- dfm(bi_gram)
tri_DFM <- dfm(tri_gram)

uni_DFM <- dfm_trim(uni_DFM, 3)
bi_DFM <- dfm_trim(bi_DFM, 3)
tri_DFM <- dfm_trim(tri_DFM, 3)

sums_U <- colSums(uni_DFM)
sums_B <- colSums(bi_DFM)
sums_T <- colSums(tri_DFM)

uni_words <- data.table(word_1 = names(sums_U), count = sums_U)

bi_words <-
    data.table(
        word_1 = sapply(strsplit(names(sums_B), "_", fixed = TRUE), '[[', 1),
        word_2 = sapply(strsplit(names(sums_B), "_", fixed = TRUE), '[[', 2),
        count = sums_B
    )

tri_words <-
    data.table(
        word_1 = sapply(strsplit(names(sums_T), "_", fixed = TRUE), '[[', 1),
        word_2 = sapply(strsplit(names(sums_T), "_", fixed = TRUE), '[[', 2),
        word_3 = sapply(strsplit(names(sums_T), "_", fixed = TRUE), '[[', 3),
        count = sums_T
    )

setkey(uni_words, word_1)
setkey(bi_words, word_1, word_2)
setkey(tri_words, word_1, word_2, word_3)

discount_value <- 0.75

nbgr <- nrow(bi_words[, .N, by = .(word_1, word_2)])
ckn <- bi_words[, .(Prob = ((.N) / nbgr)), by = word_2]
setkey(ckn, word_2)

uni_words[, Prob := ckn[word_1, Prob]]
uni_words <- uni_words[!is.na(uni_words$Prob)]

n1wi <- bi_words[, .(N = .N), by = word_1]
setkey(n1wi, word_1)

bi_words[, Cn1 := uni_words[word_1, count]]
bi_words[, Prob := ((count - discount_value) / Cn1 + discount_value / Cn1 * n1wi[word_1, N] * uni_words[word_2, Prob])]


tri_words[, Cn2 := bi_words[.(word_1, word_2), count]]
n1w12 <- tri_words[, .N, by = .(word_1, word_2)]
setkey(n1w12, word_1, word_2)
tri_words[, Prob := (count - discount_value) / Cn2 + discount_value / Cn2 * n1w12[.(word_1, word_2), N] *
              bi_words[.(word_1, word_2), Prob]]
uni_words2 <- uni_words

uni_words <- uni_words2[order(-Prob)][1:50]

save(uni_words, bi_words, tri_words, file = "wordFrequencies.Rdata")

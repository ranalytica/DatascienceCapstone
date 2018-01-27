load("wordFrequencies.Rdata")

getWords <- function(str){
    words <- nextWord(str)
    
    w <- getlast2words(str)
    chain_1 <- paste(w[1], w[2], words[1], sep = " ")
    
    additional_word_1 <- nextWord(chain_1)
    w <- getlast2words(chain_1)
    chain_2 <- paste(w[1], w[2], additional_word_1[1], sep = " ")
    
    
    additional_word_2 <- nextWord(chain_2)
    w <- getlast2words(chain_2)
    chain_3 <- paste(w[1], w[2], additional_word_2[1], sep = " ")
    
    print(words)
    print(chain_3)
}

nextWord <- function(str) {
    words <- getlast2words(str)
    pwords <- triWords(words[1], words[2], 5)
    pwords
}

getlast2words <- function(str) {
    words <- tokenize(x = char_tolower(str))
    char_wordstem(rev(rev(words[[1]])[1:2]), language = "english")
}

triWords <- function(w1, w2, n = 5) {
    pwords <- tri_words[.(w1, w2)][order(-Prob)]
    if (any(is.na(pwords)))
        return(biWords(w2, n))
    if (nrow(pwords) > n)
        return(pwords[1:n, word_3])
    count <- nrow(pwords)
    bwords <- biWords(w2, n)[1:(n - count)]
    return(c(pwords[, word_3], bwords))
}

biWords <- function(w1, n = 5) {
    pwords <- bi_words[w1][order(-Prob)]
    if (any(is.na(pwords)))
        return(uniWords(n))
    if (nrow(pwords) > n)
        return(pwords[1:n, word_2])
    count <- nrow(pwords)
    unWords <- uniWords(n)[1:(n - count)]
    return(c(pwords[, word_2], unWords))
}

uniWords <- function(n = 5) {
        return(sample(uni_words[, word_1], size = n))
    
}

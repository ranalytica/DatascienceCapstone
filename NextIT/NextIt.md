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



## Notes regarding this applicaton

Mr Cheerful - 17 June 2017

#### Comment:

A couple weeks before the due date for this project I restarted the project with a different approach because I could not figure out how to get adequate performance with the library TM functions and the TDM matricies.  (If you got it to work okay, good for you!)

I restarted with just the base R package, and used some stringi, stringr and dplyr functions.
I achieved the performance I was after: reporting back a prediction in less than 1s.
But it didn't leave me with enough time to scale up the solution with the full training set.

This demonstration is based on a 3500 word dictionary, trained on 10% of the supplied corpus.
In training, I had turned off the filter for 'out of dictionary' words to be able to see how often out of dictionary words come up with the current size of dictionary.

The training method for my algorithm doesn't need copious computer memory, so this model could easily be retrained with a 6000 or 10000 word dictionary, and the entire corpus supplied.  It would just take about 6 days to run on my computer.


#### Backlog:

* Retrain algorithm with 6000 word dictionary. (Covers approx. 90% of words used.)

* Enable predicted word buttons to insert word in input text.

* Add button to clear text field.


#### Instructions

* Application is laid out like most smart phones.  Simply enter text in the box and the predicted next word choices will appear in the boxes above.

 
#### References
 
 
* [Wikipedia Katz’s back-off model](https://en.wikipedia.org/wiki/Katz%27s_back-off_model)

* [Introduction to stringr](https://cran.r-project.org/web/packages/stringr/vignettes/stringr.html)

 
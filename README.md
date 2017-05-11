# NLP-Project

## Overview

This repository is my development code for the final project in a very popular data science online mooc.  

### Components

Due to the size of the datasets and intermediate data files, I will not add them to the github repostiory, but in the spirit of reproducibilty, the code will have everything required to reproduce the data from the originial source.

#### 3-SourceFileSplitting.R

Script for parsing the provided dataset into training and testing sets.  The data is split into 70% training, and two 15% testing sets.   The training is further split into 100%, 50%, 25%, 10% and 1% size sets for development.

#### 4-DataClean-<iteration>.R

This is the script for cleaning and pre-processing the data and then saving the resulting R objects for analysis or prediction models.
As this processing pipeline will change and need to be redone multiple times, an iteration index is added to keep things sorted out.

* Iteration 1 - week 2 processing for milestone report.

### Weekly Work reports

* Week1-working notes.Rmd
* Week2-MilestoneReport.Rmd
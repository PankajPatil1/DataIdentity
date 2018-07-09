# Problem Statement

Your client is a multi-national financial company, which offers multiple products to the consumers. There are multiple channels to offer these products to consumers although major contribution is coming from offline distribution channel. Offline channel sells Financial products to consumers via their agent network and as per government regulation these agents must be certified to sell financial products. There are multiple certification programs against different categories of financial products. 


As this offline channel shares major contribution to total company sales, company focuses on recruitment and certify them to build large agent network. Here, major challenge is training them to get the certifications to sell various type of products.
 

You are given a dataset of trainee performance for the training curriculum test wise within multiple programs. Your task is to predict the performance on such tests given the demographic information and training program/test details. This will enable your client to strengthen its training problem by figuring out **the most important factors that lead to a better engagement and performance for a trainee.**

## Data Dictionary 

 
|id 	  |	Unique ID |
|:-------------:|:-------------:|
| program_id 	| ID for program |
| program_type |	 Type of program |
| program_duration | 	 Program duration in days |
| test_id 	| test ID |
| test_type |  Type of test (offline/online) |
| difficulty_level |	 Difficulty level of test |
| trainee_id | 	 ID for trainee |
| gender 	| Gender of trainee |
| education |  Education Level of trainee |
| city_tier | 	 Tier of city of residence for  trainee |
| age | 	 Age of trainee |
| total_programs_enrolled 	| Total Programs Enrolled by trainee |
| is_handicapped 	| Does trainee suffer from a disability? |
| trainee_engagement_rating | 	Instructer/teaching assistant provided trainee engagement rating for the course |
| is_pass |	 0 - test failed, 1 -  test passed |
 
## Evaluation Metric ##

The evaluation metric for this competition is AUC ROC score.

## Approach
The dataset had missing values in the age and trainee_engagement_rating, these were fixed by using the MICE package from the R repository. Once, the missing values were treated, I noticed there was a data leak in the dataset. The 'id' section had the entry in the form of 'traineeid_examid'. So, to exploit that, I calculated the percentage of exams passed by a particular trainee. So, for the following data:

| id | trainee_id | is_pass |
|:-------:|:---------:|:-------:|
|  1_2  |  1  |  1  |
|  1_4  |  1  |  1  |
|  1_5  |  1  |  0  |

The pass percentage for trainee 1 is 33.33%.

These passing percentages were calculated for every trainee id and then were  put against (using weighted addition) the trainee_id in the test set in case the trainee id existed in the test set, otherwise predictive models were created to predict the passing probability.
The dataset was trained using ANN, XGB and Logistic regression models. Once, the models were trained and verified that they were working using a 5 fold cross validation model. Their predictions were added using weights which were calculated completely using hit and trial method. Once the weights were finalised, we had two columns for predictions. One column consisted of the passing percentages and the other consisted of weighted addition of probabilities predicted using ensemble of models created earlier. Then another weighted addition was carried out (in case the pass percentage was not available for any trainee id, the predictions were added as it is to the final column). After hit and trial method, the model was finalized and published.

## Results
| Score |  My Rank | Total # of people | 
|:-----:|:-----:|:-------------:|
|0.7975061359 | 62 | 1142 |

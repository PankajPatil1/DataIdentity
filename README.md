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

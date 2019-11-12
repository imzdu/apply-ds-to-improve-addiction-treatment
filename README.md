# Apply Data Science To Improve Addiction Treatment

## Motivation

Every day, more than 130 people in the United States die after overdosing on opioids^[National Institute on Drug Abuse - https://www.drugabuse.gov/drugs-abuse/opioids/opioid-overdose-crisis]. Addiction to and misuse of opioids, such as heroin, prescription pain relievers, and synthetic opioids such as fentanyl, has reached alarming levels. This issue has destroyed countless families, and has placed a heavy burden on the overall economy, including increased costs of healthcare, addiction treatment, criminal justice involvement, and lost productivity, etc.

Therefore, it has become ever more critical for healthcare providers to extract insights and better understand the addiction population for providing effective treatment.

Data science is one of the ways to help achieve this.

As our organization continuously strives to improve treatment quality, I've recently worked on a data science project to apply machine learning techniques to understand key common attributes among patients, and discover any unique clusters. Continuity of care is crucial for treating substance use disorder. Our goal is to discover key causes for patients to quit recovery programs, and identify areas for improvement, and design more effective intervention. 

The analysis presented in this report is only one piece of a working-in-progress effort towards the goal. __Upon approval by our organization, I'd like to share some of the key findings from this project, hoping to inspire meaningful discussions about how data science and technologies can transform addiction treatment.__

## Summary


In this report, I will go through step by step on how I used unsupervised machine learning to extract clinical insights and conduct patients segmentation analysis from survey results. 

The survey used in this project is called Brief Addiction Monitor (BAM). The complete survey with scoring & clinical guidelines are publicly available, which can be found following [this link](https://www.mentalhealth.va.gov/providers/sud/docs/BAM_Scoring_Clinical_Guidelines_01-04-2011.pdf).

This report follows the BSPF project framework developed by [Matt Dancho](https://www.linkedin.com/in/mattdancho/), an enhanced [CRISP-DM](https://en.wikipedia.org/wiki/Cross-industry_standard_process_for_data_mining) Methodology designed specifically for solving business problems using data science.

Here is the outline of this report:

1. Problem Understanding
2. Data Understanding
3. Data Preparation
4. Modeling
5. Validation
6. Impact
7. What's Next


## Files and Dataset

The RMarkdown file can be found [here](https://github.com/imzdu/apply-ds-to-improve-addiction-treatment/tree/master/Communication).

The full report of this analysis can be found [here](https://github.com/imzdu/apply-ds-to-improve-addiction-treatment/blob/master/Communication/Apply%20Data%20Science%20to%20Improve%20Addiction%20Treatment.pdf).

De-identified dataset for reproducing the report can be found [here](https://github.com/imzdu/apply-ds-to-improve-addiction-treatment/tree/master/Raw%20Data/BAM%20Data%20Raw)

Please make sure to set working directory as inside "imzdu/apply-ds-to-improve-addiction-treatment".

### Disclaimer
*The findings extracted from this analysis is entired based on data sets from within our organization. Although we'd like to think insights drawn from this analysis could represent a larger scope (given the sample size), you might find otherwise. To reproduce the analysis, the dataset used in this report can be found here: [TBD]. __Please note, to completely ensure patients' privacy, the data has been de-identified to stay HIPAA compliant. Column "display_id" contains an id arbitrarily assigned to each patient for analysis purposes only.__*

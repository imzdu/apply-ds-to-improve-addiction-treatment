# This pipe line is to load all the raw data needed, and format them into a desired structure for analysis. 

source("../Scripts/functions.R")

bam_raw_2018_data_path <- "../Raw Data/BAM Data Raw/2018/"
bam_raw_2019_data_path <- "../Raw Data/BAM Data Raw/2019/"

# Load Survey Results Data:
bam_raw_2018_raw_data_tbl <- load_raw_data(bam_raw_2018_data_path) %>% 
    rename("active_status" = `active?`, "survey_date" = `Survey Date`, "category" = Category)


bam_raw_2019_raw_data_tbl <- load_raw_data(bam_raw_2019_data_path) %>% 
    rename("active_status" = `active?`, "survey_date" = `Survey Date`, "category" = Category)


total_raw_data_tbl <- bam_raw_2018_raw_data_tbl %>% 
    rbind(bam_raw_2019_raw_data_tbl)

# Response data below to be used for ananlysis:
original_question_reponse_tbl <- total_raw_data_tbl %>% 
    format_questions(include = F)

# The data below will be held out for cluster analysis at a later stage:
added_question_response_tbl <- total_raw_data_tbl %>% 
    format_questions(custom_questions = c('17', '18', '19'),include = T)


added_question_response_definition_tbl <- total_raw_data_tbl %>% 
    format_questions(custom_questions = c('17', '18', '19'),include = T) %>% 
    filter(!category == "Address") %>% 
    select(question_number, category, value, score) %>% 
    mutate(value = str_replace_all(value, pattern = "shelter", "Shelter")) %>% 
    split(.$category) %>% 
    purrr::map(., distinct) %>% 
    reduce(rbind)



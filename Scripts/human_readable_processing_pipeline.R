# Pipeline for processing survey data to be "Human Readable", and to be ready for preprocessing for modeling ----
human_readable_processing <- function(data){
    
    # Create a definition tibble and split it into list of tibbles for further processing:
    original_response_definition_tbls <- data %>%
        distinct(questions, score, value) %>% 
        arrange(questions, score) %>% 
        split(.$questions) %>% 
        map(~ select(., -questions)) %>% 
        map(~ mutate(., value = as_factor(value)))
    
    
    # rename the tibble list so that the column names are human readable
    for (i in seq_along(original_response_definition_tbls)){
        list_name <- names(original_response_definition_tbls)[i]
        colnames(original_response_definition_tbls[[i]]) <- c(list_name, paste0(list_name, "_value"))
    }
    
    
    # Combine all the data together into a list so that we can use functions to iterate over
    data_for_preprocessing_tbl <- list(Survey_Data = response_encoded_tbl %>% 
                                           select (-active_status)) %>% 
        append(original_response_definition_tbls, after = 1) %>% 
        reduce(left_join) %>% 
        select(-one_of(names(original_response_definition_tbls))) %>% 
        set_names(str_replace_all(names(.), pattern = "_value", replacement = "")) %>% 
        select(sort(names(.)))
    
    return(data_for_preprocessing_tbl)
    
}

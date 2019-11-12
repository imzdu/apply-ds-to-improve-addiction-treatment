# This script contains custom functions:

# To load raw data:
load_raw_data <- function(file_path){
    file_path %>% 
        fs::dir_info() %>% 
        select(path) %>% 
        mutate(data = purrr::map(path, read_excel)) %>% 
        unnest() %>% 
        select(-path)
}


# Convert raw questions into question numbers, and allow users to choose if custom added questions should be included:
format_questions <- function(data, custom_questions = c('17', '18', '19'), include = T){
    
    questions_formatted <- data %>% 
        separate(question_name, into = c("question_number", NA), sep = "\\.") 
    
    if(include){
        data_formatted <- questions_formatted %>% 
            filter(question_number %in% custom_questions) %>% 
            mutate(questions = str_glue("Question_{question_number}"))
    } else {
        data_formatted <- questions_formatted %>% 
            filter(!question_number %in% custom_questions) %>% 
            mutate(questions = str_glue("Question_{question_number}"))
    }
    
    return(data_formatted)
}



# To calculate the mode of a vector ----
mode_cal <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
}

# To calculate patient churn rate:

patient_churn_rate_cal <- function(data, x, .cluster, cluster_col, ...){
    
    # data: df used to perform the cluster algorithm
    # x: df that contains the cluster information
    # .cluster: cluster of interest
    # cluster_col: column that contains cluster information
    # ...: columns to be selected for analysis
    
    vars_expr <- quos(...)
    cluster_col_expr <- enquo(cluster_col)
    
    churn_rate <- data %>% 
        left_join(x, by = "display_id") %>% 
        filter(!! cluster_col_expr == .cluster) %>% 
        select(!!! vars_expr) %>% 
        count(!!! vars_expr) %>% 
        mutate(pct = n / sum(n))
    
    return(churn_rate)
    
}

# To summarise survey responses based on categories:
survey_response_recap <- function(data, .cluster, cluster_col, ...){
    
    # data: df contains most frequent responses for each patient from all past surveys
    # .cluster: cluster of interest
    # cluster_col: column that contains cluster information
    # ...: columns to be grouped to sum category scores, typically display_id, clusters, categories.
    
    vars_expr <- quos(...)
    cluster_col_expr <- enquo(cluster_col)
    
    data %>% 
        filter(!! cluster_col_expr == .cluster) %>% 
        group_by(!!! vars_expr) %>% 
        summarise(
            score = sum(score)
        ) %>% 
        ungroup()
}

# To summarise survey responses of added questions:
added_response_recap <- function(data, x, .cluster, cluster_col, ...){
    
    # data: df contains responses od added questions
    # .cluster: cluster of interest
    # cluster_col: column that contains cluster information
    # ...: columns to be grouped to sum category scores, typically display_id, clusters, categories.
    vars_expr <- quos(...)
    cluster_col_expr <- enquo(cluster_col)
    
    data %>% 
        left_join(x, by = "display_id") %>% 
        filter(!! cluster_col_expr == .cluster) %>% 
        filter(!category == "Address") %>%
        group_by(!!! vars_expr) %>% 
        summarise(
            score = mode_cal(score)
        ) %>% 
        ungroup() %>% 
        left_join(added_question_response_definition_tbl %>% 
                      select(question_number, score, value), by = c("question_number", "score")) %>% 
        select(display_id, clusters, category, value, score)
}


# This plot pipeline is for ploting non-clinical metrics among clusters of choice:
plot_metrics <- function(data, metric_name, .cluster, .value, 
         fct_reorder = FALSE, order_by, fct_rev = FALSE){
    
    # set variables for tidy eval:
    metric_name_expr <- enquo(metric_name)
    cluster_expr <- enquo(.cluster)
    cluter_str <- quo_name(cluster_expr)
    value_expr <- enquo(.value)
    value_name <- quo_name(value_expr)
    order_by_expr <- enquo(order_by)
    
    cluster_data <- data %>% 
        filter(category == !! metric_name_expr) %>% 
        count(!! cluster_expr, !! value_expr, !! order_by_expr) %>% 
        group_by(!! cluster_expr) %>% 
        mutate(pct = n / sum(n)) %>% 
        ungroup()

    if (fct_reorder) {
        cluster_data <- cluster_data %>% 
            mutate(value = as_factor(!! value_expr) %>% fct_reorder(!! order_by_expr))
    } else{
        cluster_data <- cluster_data %>% 
            mutate(value = as_factor(!! value_expr) %>% fct_reorder(pct))
    }
    
    
    # If user wants to reverse the fct ordering of .value:
    if (fct_rev) {
        
        cluster_data <- cluster_data %>% 
            mutate(value = !! value_expr %>% fct_rev())
    }
    
    g <- cluster_data %>% 
        ggplot(aes_string(x = value_name, y = "pct", fill = cluter_str)) +
        geom_col(position = "dodge") + 
        geom_label(aes(label = scales::percent(pct)), size = 4, position = position_dodge(0.9),show.legend = F) +
        theme(
            axis.title.y = element_text(margin = margin(r = 0, unit = "pt")),
            axis.title.x = element_text(margin = margin(t = 10, b = 5, unit = "pt")), 
            legend.position = "bottom"
        ) +
        coord_flip()
    
    return(g)
}


# scree plot for identifying the number of clusters using k-modes:
kmode_mapper <- function(modes = 3){
    
    preprocessed_data_tbl %>% 
        select(-display_id) %>% 
        kmodes(modes = modes, iter.max = 25, weighted = FALSE)
}


kmodes_scree_plot <- function(n = 10, seed = 1235){
    
    # to create 10 modes for each to run through kmodes, and produce performance metrics for plotting
    set.seed(seed)
    kmodes_mapped_tbl <- tibble(modes = 1:n) %>% 
        mutate(k_modes = modes %>% purrr::map(kmode_mapper)) %>% 
        mutate(withindiff = k_modes %>% purrr::map(pluck("withindiff")))
    
    # plot the sum of withindiff for each kmode object
    kmodes_skree_plot <- kmodes_mapped_tbl %>% 
        unnest(withindiff) %>% 
        group_by(modes) %>% 
        summarise(sum_withindiff = sum(withindiff)) %>% 
        ungroup() %>% 
        ## Create a skree plot to visualize the best number of center to choose
        ggplot(aes(modes, sum_withindiff)) +
        geom_point() +
        geom_line() +
        ggrepel::geom_label_repel(aes(label = modes), color = "#2c3e50") +
        theme_bw()
    
    return(kmodes_skree_plot)
}



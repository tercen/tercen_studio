library(tercen)
library(dplyr)
 
(ctx = tercenCtx())  %>%
    select(.y, .ci, .ri) %>%
    group_by(.ci, .ri) %>%
    summarise(median = median(.y)) %>%
    ctx$addNamespace() %>%
    ctx$save()


library(tercen)
library(dplyr)

options("tercen.workflowId"= "9d5379a435c8457a347584e162003e09")
options("tercen.stepId"= "12-9")

(ctx = tercenCtx())  %>%
    select(.y, .ci, .ri) %>%
    group_by(.ci, .ri) %>%
    summarise(mean = mean(.y)) %>%
    ctx$addNamespace() %>%
    ctx$save()
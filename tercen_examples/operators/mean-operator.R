library(tercen)
library(dplyr)

getOption("tercen.serviceUri")
getOption("tercen.username")
getOption("tercen.password")
   
options("tercen.workflowId"= "9d5379a435c8457a347584e162003e09")
options("tercen.stepId"= "641-34")
getOption("tercen.workflowId")
getOption("tercen.stepId")
 
(ctx = tercenCtx())  %>% 
  select(.y, .ci, .ri) %>% 
  group_by(.ci, .ri) %>%
  summarise(mean = mean(.y)) %>%
  ctx$addNamespace() %>%
  ctx$save()
 

tercenCtx()$query
 
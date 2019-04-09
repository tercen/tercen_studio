library(tercen)
library(dplyr)

getOption("tercen.serviceUri")
getOption("tercen.username")
getOption("tercen.password")

options("tercen.workflowId"= "9d5379a435c8457a347584e162003e09")
options("tercen.stepId"= "366-26")
getOption("tercen.workflowId")
getOption("tercen.stepId")

ctx = tercenCtx()

ctx$workflow
ctx$client$taskService$get('237eff3d8e96c6d33369276ea72b4540')

(ctx = tercenCtx()) %>% 
  select(.y) 

base = 10 
#ctx$op.value('base')

(ctx = tercenCtx()) %>% 
  select(.y) %>% 
  transmute(log = log(.y, base=base)) %>%
  ctx$addNamespace() %>%
  ctx$save()

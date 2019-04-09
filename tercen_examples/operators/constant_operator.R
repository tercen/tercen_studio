library(tercen)
library(dplyr)

getOption("tercen.serviceUri")
getOption("tercen.username")
getOption("tercen.password")

options("tercen.workflowId"= "9d5379a435c8457a347584e162003e09")
options("tercen.stepId"= "641-34")
getOption("tercen.workflowId")
getOption("tercen.stepId")

tercenCtx() %>% cselect()
ctx = tercenCtx()
ctx$cschema$nRows
ctx$rschema$nRows
ctx$names
ctx %>% select(.y, .ci, .ri)

ctx$query

rep(0:(ctx$cschema$nRows-1), 0:(ctx$rschema$nRows-1))
 
cTable = tibble(.ci=seq.int(0,ctx$cschema$nRows-1)) %>% mutate(value=0.0)
rTable = tibble(.ri=seq.int(0,ctx$rschema$nRows-1)) %>% mutate(value=0.0)

cTable %>% full_join(rTable) %>%
  ctx$addNamespace() %>%
  ctx$save() 



rep(0:10, 0:4)

fun = function(x) {return(x)} 

(ctx = tercenCtx())  %>%   select(.ci, .ri) 

data = tibble(value=c(0.0))
ctx = tercenCtx()
ctx$addNamespace(tibble(value=c(0.0))) %>% ctx$save()

(ctx = tercenCtx())  %>% 
  select(.y, .ci, .ri) %>% 
  group_by(.ci, .ri) %>%
  summarise(value = fun(as.double(ctx$op.value('value')))) %>%
  ctx$addNamespace() %>%
  ctx$save()


(ctx = tercenCtx())  %>% 
  select(.y, .ci, .ri) %>% 
  group_by(.ci, .ri) %>%
  summarise(mean = mean(.y)) %>%
  ctx$addNamespace() %>%
  ctx$save()


tercenCtx()$query

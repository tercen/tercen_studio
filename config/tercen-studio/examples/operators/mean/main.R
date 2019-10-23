library(tercen)
library(dplyr)

# http://0.0.0.0:5402/#ds/2ecef2b0b686d7fde25f34eeb8005605/3-1
options("tercen.workflowId"= "2ecef2b0b686d7fde25f34eeb8005605")
options("tercen.stepId"= "3-1")
  
(ctx = tercenCtx())  %>%
    select(.y, .ci, .ri) %>%
    group_by(.ci, .ri) %>%
    summarise(median = median(.y)) %>%
    ctx$addNamespace() %>%
    ctx$save()

# example using as.matrix
# mean.matrix = (ctx = tercenCtx()) %>% as.matrix(fill=NaN)

# data = data.frame(.ri = as.vector(row(mean.matrix)-1),
#                  .ci = as.vector(col(mean.matrix)-1),
#                  mean = as.vector(mean.matrix)) %>%
#  ctx$addNamespace() %>%
#  ctx$save()
 
 

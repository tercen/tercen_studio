library(tercen)
library(dplyr)

# http://127.0.0.1:5402/#ds/2ecef2b0b686d7fde25f34eeb8005605/3-1
# options("tercen.workflowId"= "2ecef2b0b686d7fde25f34eeb8005605")
# options("tercen.stepId"= "3-1")
  
(ctx = tercenCtx())  %>%
    select(.y, .ci, .ri) %>%
    group_by(.ci, .ri) %>%
    summarise(median = median(.y)) %>%
    ctx$addNamespace() %>%
    ctx$save()


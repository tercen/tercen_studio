library(tercen)
library(dplyr)
library(caret)

data = (ctx = tercenCtx())  %>% 
  select(.cindex, .rindex, .values) %>% 
  reshape2::acast(.cindex ~ .rindex, value.var='.values', fun.aggregate=mean) 

data %>%
  preProcess(method=c("BoxCox", "center", "scale", "pca")) %>%
  predict(data) %>%
  as_tibble() %>%
  mutate(.cindex = seq_len(nrow(.))-1) %>%
  ctx$addNamespace() %>%
  ctx$save()
 
 
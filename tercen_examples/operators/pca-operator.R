library(tercen)
library(dplyr)

(ctx = tercenCtx())  %>% 
  select(.cindex, .rindex, .values) %>% 
  reshape2::acast(.cindex ~ .rindex, value.var='.values', fun.aggregate=mean) %>%
  prcomp(scale=TRUE) %>%
  predict() %>%
  as_tibble() %>%
  mutate(.cindex = seq_len(nrow(.))-1) %>%
  ctx$addNamespace() %>%
  ctx$save()
 
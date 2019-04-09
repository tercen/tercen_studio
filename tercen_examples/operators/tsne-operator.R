library(tercen)

# Sets seed for reproducibility
set.seed(42)

(ctx = tercenCtx())  %>% 
  select(.cindex, .rindex, .values) %>% 
  reshape2::acast(.cindex ~ .rindex, value.var='.values', fun.aggregate=mean) %>%
  Rtsne::Rtsne(perplexity = 20, check_duplicates = FALSE) %>%
  (function(tsne) {
    d = as_tibble(tsne$Y)
    names(d)=paste('tsne', seq_along(d), sep = '.')
    return(d)
  }) %>% 
  mutate(.cindex = seq_len(nrow(.))-1) %>%
  ctx$addNamespace() %>%
  ctx$save()
 
library(tercen)
library(dplyr)
  
# http://127.0.0.1:5402/#ds/642ef388cf12e36d5b9cbf5361004dab/4-2
options("tercen.workflowId"= "642ef388cf12e36d5b9cbf5361004dab")
options("tercen.stepId"= "4-2")

ctx = tercenCtx()

ctx$client$session$serverVersion

ctx$names
ctx$query
ctx$rschema
ctx$cschema
ctx$workflow

ctx$namespace
ctx$query
ctx$yAxis
ctx$xAxis
ctx$colors
ctx$labels
ctx$errors

ctx %>% select()
ctx %>% cselect()
ctx %>% rselect()

ctx$op.value('scale')

# columns names of the xy table
ctx$names
# columns names of the column table
ctx$cnames
# columns names of the row table
ctx$rnames

# schema of the xy table
ctx$schema
# schema of the column table
ctx$cschema
# schema of the row table
ctx$rschema

# select xy table
ctx$select()
ctx$select(nr=1)
ctx$select(offset=10L, nr=3L)
ctx$select(c('.y','.ci','.ri'), nr=3)
ctx$select('.y', nr=3)

# select column table
ctx$cselect()
# select row table
ctx$rselect()

ctx %>% select()
ctx %>% cselect()
ctx %>% rselect()
      
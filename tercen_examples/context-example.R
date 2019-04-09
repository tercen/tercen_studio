library(tercen)
library(dplyr)

options("tercen.serviceUri"= "https://dev.tercen.com/api/v1/")
options("tercen.username"= "username")
options("tercen.password"= "password")

# https://dev.tercen.com/core/#ds/6d5568907eb0e316ef6e1c59737a0939/12-9
options("tercen.workflowId"= "6d5568907eb0e316ef6e1c59737a0939")
options("tercen.stepId"= "12-9")

ctx = tercenCtx()

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
      
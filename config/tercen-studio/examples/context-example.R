library(tercen)
library(dplyr)

# b6cb5a7da1470bd088032dd09e00bff0/ds/96a905f1-3d1a-4274-8f4f-cc42751e7b0c
options("tercen.workflowId"= "b6cb5a7da1470bd088032dd09e00bff0")
options("tercen.stepId"= "96a905f1-3d1a-4274-8f4f-cc42751e7b0c")

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
ctx %>% as.matrix()

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
       

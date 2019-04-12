library(tercen)
library(dplyr)

source('doLinreg.R')

client = TercenClient$new()

workflowId = '7152cd08a80e36aafe1539069900f849'
stepId = '425a662e-0b36-45ad-8e2a-f4be976cabd7'

workflow = client$workflowService$get(workflowId)
query = client$workflowService$getCubeQuery(workflowId, stepId)
qtSchema = client$tableSchemaService$findByQueryHash(keys=list(query$qtHash))[[1]]
table = client$tableSchemaService$select(qtSchema$id, list('.values', '.x','.cindex','.rindex'), 0, qtSchema$nRows)
df = as_tibble(table)
# edit(df)

group_by_cell = df %>% group_by(.cindex, .rindex)
computed.df = group_by_cell %>% do(doLmFit(.))
# edit(computed.df)

cnames = c('pindex','fitLmX','fitLmY')
computed.df = rename_(computed.df, 
                      .dots= setNames(cnames,
                                      paste(query$operatorSettings$namespace, cnames, sep='.')))

# edit(computed.df)


# computed.df = rbind(computed.df ,computed.df )

result = OperatorResult$new()
result$tables = list(tercen::dataframe.as.table(computed.df))


bytes = rtson::toTSON(result$toTson())
fileDoc = FileDocument$new()
fileDoc$name = 'result'
fileDoc$projectId = workflow$projectId
fileDoc$acl$owner = workflow$acl$owner
fileDoc$metadata$contentType = 'application/octet-stream'
fileDoc$metadata$contentEncoding = 'iso-8859-1'

fileDoc = client$fileService$upload(fileDoc, bytes)

task = ComputationTask$new()
task$projectId = workflow$projectId
task$query = query
task$fileResultId = fileDoc$id

task = client$taskService$create(task)

task = client$taskService$waitDone(task$id)

if (inherits(task$state, 'FailedState')){
  stop(task$state$reason)
}

# task
# t = tercen::dataframe.as.table(computed.df)
# t$nRows
# dim(computed.df)





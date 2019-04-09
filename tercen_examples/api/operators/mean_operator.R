library(tercen)
library(dplyr)

  
client = TercenClient$new()
# client = TercenClient$new('testuser','mm', serviceUri='http://127.0.0.1:4400')
task = client$taskService$get(tercen::parseCommandArgs()$taskId)
task
query = task$query
 
project = client$projectService$get(task$projectId)

# workflowId = '7152cd08a80e36aafe1539069900f849'
# stepId = '425a662e-0b36-45ad-8e2a-f4be976cabd7'
# workflow = client$workflowService$get(workflowId)
# query = client$workflowService$getCubeQuery(workflowId, stepId)

qtSchema = client$tableSchemaService$findByQueryHash(keys=list(query$qtHash))[[1]]
table = client$tableSchemaService$select(qtSchema$id, list('.values','.cindex','.rindex'), 0, qtSchema$nRows)
df = as_tibble(table)

meanName = paste0(query$operatorSettings$namespace, '.mean')
computed.df = df %>%
  group_by(.cindex, .rindex) %>%
  summarise(mean = mean(.values))

computed.df = rename_(computed.df, 
                      .dots= setNames(c('mean'),
                                      c(paste0(query$operatorSettings$namespace, '.mean'))))
 
result = OperatorResult$new()
result$tables = list(tercen::dataframe.as.table(computed.df))
  
bytes = rtson::toTSON(result$toTson())
 
fileDoc = client$fileService$get(task$fileResultId)
client$fileService$upload(fileDoc, bytes)
 
 
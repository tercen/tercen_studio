library(tercen)

client = TercenClient$new()
client
 
workflowId = '449df8165dddb9276962e5729501f9cd'
stepId = 'd82ce8cc-7494-4e80-b8b2-d460a10783ca'

client$workflowService$get(workflowId)
 
teamId = client$session$user$teamAcl$aces[[1]]$principals[[1]]$principalId
date = '2018'

projects = client$documentService$findProjectByOwnersAndCreatedDate(
  startKey=list(teamId,date),
  endKey=list(teamId,''))

projects
project = projects[[1]]

workflow = Workflow$new()
workflow$name = 'test from R' 
workflow$isDeleted = FALSE
workflow$projectId = project$id
workflow$acl$owner = project$acl$owner
workflow
client$workflowService$create(workflow)


client$projectDocumentService$findWorkflowByLastModifiedDate(
  startKey=list(project$id, '2018'), 
  endKey=list(project$id,''),
  limit=1,
  skip=1)

fileDoc = FileDocument$new()
fileDoc$name = 'iris from R'
fileDoc$projectId = project$id
fileDoc$acl$owner = project$acl$owner
fileDoc$metadata = CSVFileMetadata$new()
fileDoc$metadata$contentType = 'text/csv'
fileDoc$metadata$separator = ','
fileDoc$metadata$quote = '"'
fileDoc$metadata$contentEncoding = 'iso-8859-1'
fileDoc

data = iris
data['observation'] = 1:dim(data)[1]
con = rawConnection(raw(0), "r+")
write.csv(data, file=con, row.names = F)
bytes = rawConnectionValue(con)

fileDoc = client$fileService$upload(fileDoc, bytes)

fileDoc

task = CSVTask$new()
task$fileDocumentId = fileDoc$id

task = client$taskService$create(task)
task = client$taskService$waitDone(task$id)

task


workflowId = 'e8d6abebec64da4146d648d367035a40'
stepId = '82a0bca2-d0cb-4824-ab38-c9c7bf1f5daf'
query = client$workflowService$getCubeQuery(workflowId,stepId )
query
client$tableSchemaService$get(query$qtTableId)

table = client$tableSchemaService$select(query$qtTableId, list('.values','.cindex','.rindex'), 0, 2000)

table
cols = table$columns[[1]]
cols$values



library(tercen)
 
options("tercen.serviceUri"="http://172.17.0.1:5400/api/v1/")

filename = '~/projects/examples/crabs-long.csv'
teamName = 'test-team'
projectName = 'myproject'

client = TercenClient$new()

client$session

projects = client$documentService$findProjectByOwnersAndCreatedDate(
    startKey=list(teamName,'2022'),
    endKey=list(teamName,''))

project = Find(function(p) identical(p$name,projectName), projects)
project

bytes = readBin(file(filename, 'rb'),raw(),n=file.info(filename)$size)

fileDoc = FileDocument$new()
fileDoc$name = 'crabs data'
fileDoc$projectId = project$id
fileDoc$acl$owner = project$acl$owner
fileDoc$metadata = CSVFileMetadata$new()
fileDoc$metadata$contentType = 'text/csv'
fileDoc$metadata$separator = ','
fileDoc$metadata$quote = '"'
fileDoc$metadata$contentEncoding = 'iso-8859-1'
fileDoc

fileDoc = client$fileService$upload(fileDoc, bytes)

task = CSVTask$new()
task$state = InitState$new()
task$fileDocumentId = fileDoc$id
task$owner = project$acl$owner
task$projectId = project$id
task$params$separator = ','
task$params$encoding = 'iso-8859-1'
task$params$quote = '"'
task

task = client$taskService$create(task)
task
client$taskService$runTask(task$id)
task = client$taskService$waitDone(task$id)
task
if (inherits(task$state, 'FailedState')){
    stop(task$state$reason)
}

# client$taskService$get(task$id)

# browse
# paste0("http://127.0.0.1:5402/#sch/", task$schemaId)

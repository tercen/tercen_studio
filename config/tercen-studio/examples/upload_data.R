library(tercen)
 
filename = '~/examples/crabs-long.csv'
teamName = 'test-team'
projectName = 'myproject'

client = TercenClient$new()

client$session

projects = client$documentService$findProjectByOwnersAndCreatedDate(
    startKey=list(teamName,'2020'),
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

task = client$taskService$create(task)
client$taskService$runTask(task$id)
task = client$taskService$waitDone(task$id)
task
if (inherits(task$state, 'FailedState')){
    stop(task$state$reason)
}
# client$taskService$get(task$id)
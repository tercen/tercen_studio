library(tercenApi)
library(tercen)
library(tibble)
library(teRcenHttp)
 
#options("tercen.serviceUri"="http://172.17.0.1:5400/api/v1/")

data = data.frame(col1=c(1.0,2.0), col2=c("a","b"))

tbl = tercen::dataframe.as.table(data)
bytes = memCompress(teRcenHttp::to_tson(tbl$toTson()),
                    type = 'gzip')

teamName = 'test-team'
projectName = 'myproject'

client = TercenClient$new()

client$session

projects = client$documentService$findProjectByOwnersAndCreatedDate(
    startKey=list(teamName,'2032'),
    endKey=list(teamName,''))

project = Find(function(p) identical(p$name,projectName), projects)
project

 
fileDoc = FileDocument$new()
fileDoc$name = 'my_test_data_set'
fileDoc$projectId = project$id
fileDoc$acl$owner = project$acl$owner
fileDoc$metadata$contentEncoding = 'gzip'
fileDoc

fileDoc = client$fileService$upload(fileDoc, bytes)

task = CSVTask$new()
task$state = InitState$new()
task$fileDocumentId = fileDoc$id
task$owner = project$acl$owner
task$projectId = project$id

task

task = client$taskService$create(task)
task
client$taskService$runTask(task$id)
task = client$taskService$waitDone(task$id)
task
if (inherits(task$state, 'FailedState')){
    stop(task$state$reason)
}
 

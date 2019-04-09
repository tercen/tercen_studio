library(tercen)

serviceUri="http://127.0.0.1:5400/api/v1/"
username="admin"
password="admin"
 
teamName = 'test-team'
projectName = 'project'
############################################
serviceUri="https://dev.tercen.com/api/v1/"
username="admin"

teamName = 'ENP TercenWorkshop'
projectName = 'SCN2A-2'
############################################

client = TercenClient$new(serviceUri=serviceUri,
                          username=username,
                          password=password)

projects = client$documentService$findProjectByOwnersAndCreatedDate(
  startKey=list(teamName,'2020'),
  endKey=list(teamName,''))

project = Find(function(p) identical(p$name,projectName), projects)
project

tbl.schemas = client$projectDocumentService$findSchemaByLastModifiedDate(
  startKey=list(project$id,'2020'),
  endKey=list(project$id,''),
  useFactory=TRUE)
 
# all.tbl = client$tableSchemaService$selectSchema(tbl.schemas[[1]])
# all.tbl

all.tbl = dplyr::bind_rows(lapply(tbl.schemas,
                                  client$tableSchemaService$selectSchema),
                    .id = NULL)

  
bytes = memCompress(rtson::toTSON(tercen::dataframe.as.table(all.tbl)$toTson()),
                    type = 'gzip')

local.client = TercenClient$new(serviceUri="http://51.83.110.171/api/v1/",
                               username="admin",
                               password="admin")

# local.teamName = 'test-team'
# local.projectName = 'project'

local.teamName = teamName
local.projectName = projectName
  
local.projects = local.client$documentService$findProjectByOwnersAndCreatedDate(
  startKey=list(local.teamName,'2020'),
  endKey=list(local.teamName,''))

local.project = Find(function(p) identical(p$name,local.projectName), local.projects)
 

fileDoc = FileDocument$new()
fileDoc$name = 'SCN2A-2'
fileDoc$projectId = local.project$id
fileDoc$acl$owner = local.project$acl$owner
fileDoc$metadata = FileMetadata$new()
fileDoc$metadata$md5Hash = toString(openssl::md5(bytes))
fileDoc$metadata$contentType = 'application/octet-stream'
fileDoc$metadata$contentEncoding = 'gzip'
fileDoc
 
fileDoc = local.client$fileService$upload(fileDoc, bytes)
 
task = CSVTask$new()
task$state = InitState$new()
cpu = Pair$new()
cpu
cpu$key='cpu'
cpu$value='16'
task$environment = list(cpu)
task$fileDocumentId = fileDoc$id
task$owner = local.project$acl$owner
task$projectId = local.project$id

task = local.client$taskService$create(task)
local.client$taskService$runTask(task$id)
task = local.client$taskService$waitDone(task$id)
task
if (inherits(task$state, 'FailedState')){
  stop(task$state$reason)
}
local.client$taskService$get(task$id)


local.client$taskService$delete(task$id, task$rev)

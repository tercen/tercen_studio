library(tercen)

serviceUri="http://127.0.0.1:5400/api/v1/"
username="admin"
password="admin"

filename = '/home/alex/Downloads/data_analysis-Export.csv'
teamName = 'test-team'
projectName = 'project'
 
client = TercenClient$new(serviceUri=serviceUri,
                          username=username,
                          password=password)
  
projects = client$documentService$findProjectByOwnersAndCreatedDate(
  startKey=list(teamName,'2020'),
  endKey=list(teamName,''))
 
project = Find(function(p) identical(p$name,projectName), projects)
project
    
bytes = memCompress(readBin(file(filename, 'rb'), 
                            raw(), 
                            n=file.info(filename)$size),
                    type = 'gzip')
 
fileDoc = FileDocument$new()
fileDoc$name = 'atsne_data_analysis'
fileDoc$projectId = project$id
fileDoc$acl$owner = project$acl$owner
fileDoc$metadata = CSVFileMetadata$new()
fileDoc$metadata$md5Hash = toString(openssl::md5(bytes))
fileDoc$metadata$contentType = 'text/csv'
fileDoc$metadata$separator = ','
fileDoc$metadata$quote = '"'
fileDoc$metadata$contentEncoding = 'gzip,iso-8859-1'
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
 
library(tercen)

client = TercenClient$new()
client$session
client$session$user$id

client$userService$profiles(client$session$user$id)
client$userService$storageSummary(client$session$user$id)

client$teamService$storageSummary('team5')
client$projectService$storageSummary('51be7057e11c4f7b0f5b0df7c101487b')

client$projectDocumentService$findWorkflowBySchema(keys=list("ab373f854417408dc10d4b94c905e8e4"))

teamName = 'test-team'
# storageInUse
client$teamService$storageInUse(teamName)

team = client$teamService$findTeamByName(keys=list(teamName))[[1]]

projects = client$documentService$findProjectByOwnersAndCreatedDate(
  startKey=list(team$id,'2018'),
  endKey=list(team$id,''))

tibble(team = sapply(projects, function(each) each$acl$owner),
       projectName = sapply(projects, function(each) each$name),
       storageInUse = sapply(projects, function(each) client$projectService$storageInUse(each$id)))

# all teams
# need to be admin
storage.summary = function(){
  teams = client$teamService$findTeamByNameByLastModifiedDate(
    startKey=list('ZZZZZZZZ','2018'),
    endKey=list('',''))
  
  list = lapply(teams, function(team){
    projects = client$documentService$findProjectByOwnersAndCreatedDate(
      startKey=list(team$id,'2018'),
      endKey=list(team$id,''))
    
    t = tibble(owner = rep(team$owner, length(projects)),
               team = sapply(projects, function(each) each$acl$owner),
               project = sapply(projects, function(each) each$name),
               storageInUse = sapply(projects, function(each) client$projectService$storageInUse(each$id)))
    return(t)
  })
  
  return (do.call('rbind', list))
}

storage.summary()
 
# all users
# need to be admin
users = client$userService$findUserByNameByLastModifiedDate(
  startKey=list('ZZZZZZZZ','2018'),
  endKey=list('',''))



library(tercen)

options("tercen.serviceUri"="http://172.17.0.1:5400/api/v1/")

client = TercenClient$new()
client$session
client$session$user$id

client$userService$profiles(client$session$user$id)
client$userService$summary(client$session$user$id)
client$userService$resourceSummary(client$session$user$id)
 
teamName = 'test-team'
# usedStorage and usedCpuTime
client$teamService$resourceSummary('test-team')

team = client$teamService$findTeamByName(keys=list(teamName))[[1]]

projects = client$documentService$findProjectByOwnersAndCreatedDate(
  startKey=list(team$id,'2020'),
  endKey=list(team$id,''))

tibble(team = sapply(projects, function(each) each$acl$owner),
       project = sapply(projects, function(each) each$name),
       usedCpuTime = sapply(projects, function(each) client$projectService$resourceSummary(each$id)$usedCpuTime),
       usedStorage = sapply(projects, function(each) client$projectService$resourceSummary(each$id)$usedStorage))

 
# all teams
# need to be admin
storage.summary = function(){
  teams = client$teamService$findTeamByNameByLastModifiedDate(
    startKey=list('ZZZZZZZZ','2030'),
    endKey=list('',''))
  
  list = lapply(teams, function(team){
    
    projects = client$documentService$findProjectByOwnersAndCreatedDate(
      startKey=list(team$id,'2020'),
      endKey=list(team$id,''))
    
    t = tibble(owner = rep(team$acl$owner, length(projects)),
               team = sapply(projects, function(each) each$acl$owner),
               project = sapply(projects, function(each) each$name),
               usedCpuTime = sapply(projects, function(each) client$projectService$resourceSummary(each$id)$usedCpuTime),
               usedStorage = sapply(projects, function(each) client$projectService$resourceSummary(each$id)$usedStorage))
    
    return(t)
  })
  
  return (do.call('rbind', list))
}

storage.summary()
 
# all users
# need to be admin
client$persistentService$findByKind('User', useFactory=T)
client$persistentService$findByKind('Team', useFactory=T)
client$persistentService$findByKind('Workflow', useFactory=F)
client$persistentService$findByKind('TableSchema', useFactory=F)
client$persistentService$findByKind('CubeQueryTableSchema', useFactory=F)
client$persistentService$findByKind('ComputedTableSchema', useFactory=F)
client$persistentService$findByKind('CubeQueryTask', useFactory=F)
client$persistentService$findByKind('ComputationTask', useFactory=F)
client$persistentService$findByKind('CSVTask', useFactory=F)

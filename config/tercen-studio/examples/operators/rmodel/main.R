library(tercen)
library(dplyr)

# http://127.0.0.1:5402/admin/w/8f87fbc2db7b31eb2cf5d59c300052b2/ds/11164845-5b3d-48b3-ac8f-1e251972d27c
options("tercen.workflowId"= "8f87fbc2db7b31eb2cf5d59c300052b2")
options("tercen.stepId"= "11164845-5b3d-48b3-ac8f-1e251972d27c")
  
ctx = tercenCtx()

# here the key for the join start by "." (.model) so it wont be displayed to the user
leftTable = data.frame(factor1=c("a", "b", "c" , "d"),
                        factor2=c(1.0,2.0,3.0,4.0),
                        .model=c("model.1", "model.1", "model.2" , "model.2"))  %>%
      ctx$addNamespace()  %>%
      tercen::dataframe.as.table()
 
leftTable$properties$name = 'left'
leftTable

leftRelation = SimpleRelation$new()
leftRelation$id = leftTable$properties$name


serialize.to.string = function(object){
  con = rawConnection(raw(0), "r+")
  saveRDS(object, con)
  str64 = base64enc::base64encode(rawConnectionValue(con))
  close(con)
  return(str64)
}

deserialize.from.string = function(str64){
  con = rawConnection(base64enc::base64decode(str64), "r+")
  object = readRDS(con)
  close(con)
  return(object)
}

nrow = 1000000
ncol = 10
very.large.object = matrix(1:(nrow*ncol),nrow = nrow, ncol = ncol,byrow = TRUE)
  
# the factor where the binary data base64 encoded is stored MUST start by a "." character so it wont be displayed to the user
# the factor used in the join relation MUST have a different name then the one used in the leftTable 
rightTable = data.frame(model=c("model.1", "model.2"),
                       .base64.serialized.r.model=c(serialize.to.string(very.large.object),
                                                    serialize.to.string(very.large.object)))  %>%
  ctx$addNamespace()  %>%
  tercen::dataframe.as.table()

rightTable$properties$name = 'right'

rightRelation = SimpleRelation$new()
rightRelation$id = rightTable$properties$name

# create the join relationship using a JoinOperator

pair = ColumnPair$new()
pair$lColumns = list(".model") # column name of the leftTable to use for the join 
pair$rColumns = list(rightTable$columns[[1]]$name) # column name of the rightTable to use for the join (note : namespace has been added) 
pair

# Note that the joinOperator only hold a reference on the rightTable
join.model = JoinOperator$new()
join.model$rightRelation = rightRelation
join.model$leftPair = pair
join.model

# create the join relationship using a composite relation (think at a start schema)

compositeRelation = CompositeRelation$new()
compositeRelation$id = "compositeRelation"
compositeRelation$mainRelation = leftRelation
compositeRelation$joinOperators = list(join.model)
compositeRelation

# finally return a JoinOperator to tercen with the composite relation
join = JoinOperator$new()
join$rightRelation = compositeRelation
join

result = OperatorResult$new()
result$tables = list(leftTable, rightTable)
result$joinOperators = list(join)
result

ctx$save(result) 

# Second step
# http://127.0.0.1:5402/admin/w/8f87fbc2db7b31eb2cf5d59c300052b2/ds/e5d06f56-c031-4cf9-9ce9-f9c9728f117f
options("tercen.workflowId"= "8f87fbc2db7b31eb2cf5d59c300052b2")
options("tercen.stepId"= "e5d06f56-c031-4cf9-9ce9-f9c9728f117f")

ctx = tercenCtx()
  

find.schema.by.factor.name = function(ctx, factor.name){
  visit.relation = function(visitor, relation){
    if (inherits(relation,"SimpleRelation")){
      visitor(relation)
    } else if (inherits(relation,"CompositeRelation")){
      visit.relation(visitor, relation$mainRelation)
      lapply(relation$joinOperators, function(jop){
        visit.relation(visitor, jop$rightRelation)
      })
    } else if (inherits(relation,"WhereRelation") 
               || inherits(relation,"RenameRelation")){
      visit.relation(visitor, relation$relation)
    } else if (inherits(relation,"UnionRelation")){
      lapply(relation$relations, function(rel){
        visit.relation(visitor, rel)
      })
    } 
    invisible()
  }
  
  myenv = new.env()
  add.in.env = function(object){
    myenv[[toString(length(myenv)+1)]] = object$id
  }
   
  visit.relation(add.in.env, ctx$query$relation)
   
  schemas = lapply(as.list(myenv), function(id){
    ctx$client$tableSchemaService$get(id)
  })
  
  Find(function(schema){
    !is.null(Find(function(column) column$name == factor.name, schema$columns))
  }, schemas);
}

# search for a schema that contains a column name 
# schema = find.schema.by.factor.name(ctx, '.base64.serialized.r.model')
schema = find.schema.by.factor.name(ctx, ctx$colors[[1]])
# get the data
table = ctx$client$tableSchemaService$select(schema$id, Map(function(x) x$name, schema$columns), 0, schema$nRows)
 
my.models = lapply(as_tibble(table)[[".base64.serialized.r.model"]], deserialize.from.string)
 

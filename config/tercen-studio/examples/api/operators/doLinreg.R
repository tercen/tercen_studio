doLmFit = function(aFrame){
  
  
  sortedData = arrange(aFrame, .x)
  dataX = sortedData$.x
  dataY = sortedData$.values
  
  nPoints = length(dataY)
  
  if (nPoints > 1){
    aLm = try(lm(dataY ~ dataX), silent = TRUE)
    if(!inherits(aLm, 'try-error')){
      slope = coef(aLm)[2] 
      intercept = coef(aLm)[1] 
      x1 = dataX[1]
      y1 = x1 * slope + intercept
      x2 = dataX[nPoints]
      y2 = x2 * slope + intercept
        
    } else {
      x1 = NaN
      y1 = NaN
      x2 = NaN
      y2 = NaN;
    }
  }
  if (nPoints == 1){
    x1 = NaN
    y1 = NaN
    x2 = NaN
    y2 = NaN;
  }
  if (nPoints == 0){
    x1 = NaN
    y1 = NaN
    x2 = NaN
    y2 = NaN;
  }
  ri = aFrame$.rindex[1]
  ci = aFrame$.cindex[1]
  return (data.frame(.rindex = c(ri,ri),
                     .cindex = c(ci,ci),
                     pindex = c(paste(ri,ci,1,sep='.'),paste(ri,ci,2,sep='.')),
                     fitLmX=c(x1,x2),
                     fitLmY=c(y1,y2)
                     ))
}

doLinreg = function(aFrame){
  
  dataX = aFrame$.x
  dataY = aFrame$.values
  
  nPoints = length(dataY)
  
  if (nPoints > 1){
    aLm = try(lm(dataY ~ dataX+0), silent = TRUE)
    if(!inherits(aLm, 'try-error')){
      slope = aLm$coefficients[[1]]
      intercept = 0
      ssY = sum((dataY-mean(dataY))^2)
      yFit = predict(aLm)
      R2 = 1-(sum((dataY-yFit)^2) / ssY)
      Result = 1;
      
    } else {
      slope = NaN
      intercept = NaN
      R2 = NaN
      Result = 0;
    }
  }
  if (nPoints == 1){
    slope = dataY/dataX
    intercept = 0;
    R2 = 1
    Result = 1
  }
  if (nPoints == 0){
    slope = NaN
    intercept = NaN
    R2 = NaN
    Result = 0;
  }
  return (data.frame(.rindex = aFrame$.rindex[1],
                     .cindex = aFrame$.cindex[1],
                     slope=slope,
                     intercept = intercept,
                     R2 = R2,
                     nPoints = nPoints,
                     Result = Result))
}
#
# F Distribution
#

spseHat <- function(model, test){
  return(sum((test$soil.res - predict(model, newdata=test))^2))
}

getFtable <- function(train, test){
  ## Simulation F values
  realModelStr <- "soil.res ~ 1 + lmoi + temp.15 + temp.0 + soiln0 + soilc0"
  realModel <- lm(realModelStr, data = train)
  # next model will have another feature in addition
  excludeVarsRegEx <- "(soil.res|lmoi|temp.15|temp.0|soiln0|soilc0)"
  nextVars <- names(hainich)[
    ! grepl(excludeVarsRegEx,names(hainich))]
  
  #create result data frame
  simulRes <- NULL
  for(x in nextVars){
    #create formula for next Model by adding current variable
    nxtModelStr <- paste(realModelStr, "+", x)
    nxtModel <- lm(nxtModelStr, data = train)
    #evaluate nextModel
    an <- anova(realModel, nxtModel) 
    f <- an$F[2] # F-value
    p <- an$`Pr(>F)`[2] # p-value
    spse <- spseHat(nxtModel, test)
    simulRes <- rbind(simulRes, c(spse,x,f,p)) 
  }
  simulRes <- data.frame(spse=as.double(simulRes[,1]), 
                         addedFeature=simulRes[,2] , F=as.double(simulRes[,3]),
                         p=as.double(simulRes[,4]), stringsAsFactors = T)
  
  return(simulRes)
}

#n = number of monte carlo simulations
#nTrain <- number of data points for training
monte <- function(data, n, nTrain){
  # 1 == train, 0 == test
  index <- sample(c(rep(1,nTrain),rep(0,dim(data)[1] - nTrain)))
  
  simulRes <- data.frame()
  for (i in 1:n){
    train <- hainich[index==1,]
    test <- hainich[index==0,]
    
    res <- getFtable(train,test)
    res$run <- rep(i, dim(res)[1])
    simulRes <- rbind(simulRes,res)
  }
  
  return(simulRes)
}

set.seed(1337)
hainich <- read.csv("hainich.csv", sep = ";", dec = ".")
n <- 100 # number of monte carlo simulations
nTrain <- 30 # number of training data points
simulRes <- monte(hainich,n,nTrain)


## evaluation
# gets a list of features with maximal F (count: topN)
# returns true if min(SPSE) is in this list
minSPSEinTopF <- function(round, topN){
  run <- simulRes[simulRes$run == round,]
  run <- run[order(run$F, decreasing = T),] # order by F
  run <- head(run, topN) # get top N with max F
  
  minSPSE <- simulRes[simulRes$spse == min(simulRes$spse) 
                      & simulRes$run == round,]
  
  #return true if best feature by SPSE is in top list by F value
  if(minSPSE$addedFeature %in% run$addedFeature){
    return(TRUE)
  }
  else{
    return(FALSE)
  }
}

probDecisionWrong <- function(topN){
  rounds <- max(simulRes$run)
  wrongRoundsCount <- 0
  
  #for all round
  for(i in 1:rounds){
    if(!minSPSEinTopF(i,topN)){
      wrongRoundsCount <- wrongRoundsCount + 1
    }
  }
  
  return(wrongRoundsCount / rounds)
}

#probability that F test dont get min SPSe in thier top 5 list
probWrongTop3 <- probDecisionWrong(3)
probWrongTop4 <- probDecisionWrong(4)
# -> F test is always in top 4 but never in top 3 ???
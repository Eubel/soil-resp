#
# F Distribution
#

spseHat <- function(model, test){
  # SPSE.hat1
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

crossValPart <- function(data, fold){
  set.seed(1337)
  index <- rep(1:fold, length.out=dim(hainich)[2])
  index <- sample(index) # mixing
  
  simulRes <- data.frame()
  for (i in 1:fold){
    train <- hainich[index!=i,]
    test <- hainich[index==i,]
    
    res <- getFtable(train,test)
    res$run = rep(i, dim(res)[1])
    simulRes <- rbind(simulRes,res)
  }
  
  return(simulRes)
}

hainich <- read.csv("hainich.csv", sep = ";", dec = ".")
#result by cross validation (random part against rest validation)
fold <- 4
simulRes <- crossValPart(hainich,fold)


## evaluation
for(i in seq(fold)){
  #select run
  r <- simulRes[simulRes$run == 1,]
  #which model with additional feature was the real winner (SPSE)?
  idMinErr <-  which(r$spse == min(r$spse))
  #which model won but was not the best one (F)?
  idMaxF <- which(r$F == max(r$F))
  
  print(paste("In run", i,
              "min SPSE and max F picked same additional feature:", idMaxF == idMinErr ))
}

## plotting
xs <- seq(0,7,by = 0.01)
freal <- density(simulRes$F)
## WARNING: I have no idea how to calc the degree of freedoms!
## maybe an$Res.Df? need df1 and df2
fNominal <- df(xs,24,23)
plot(freal, xlim=c(min(xs),max(xs)), ylim=c(0,1),
     xlab = "F-Value",
     main="Kernel distribution of F Values \n from models with different extra feature")
points(xs, fNominal, col="red", type="lines") #F distribution
legend("topright",c("Data","Calculated"), lwd=2, col=c("black","red"), bty = "n")
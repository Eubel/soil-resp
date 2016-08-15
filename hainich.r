hainich <- read.csv("hainich.csv", sep = ";", dec = ".")

## corelation
#correlation from soil.res with all others
hainich.r <- abs(cor(hainich, method = "pearson"))["soil.res",-1]
hainich.r.ordered <- hainich.r[order(hainich.r, decreasing = T)]
barplot(hainich.r.ordered, las = 2, ylim = c(0,0.5), col = "black", 
        ylab = "Absolute Pearson Correlation", main = "Variables Correlated with Soil Respiration")

## scatter plot
pairs(~ rootdw0 + smoi + nn,
      data = hainich, main = "Scatterplot Matrix")

## sampling training data
set.seed(1337)
testFraction <- 0.2 #Fraction of data used for testing (estimate for integer sample size)
sampleCount <- dim(hainich)[1]
index <- sample(1:sampleCount, round(testFraction * sampleCount))
hainich.test <- hainich[index,]
hainich.train <- hainich[-index,]

## making models
hainich.lm1 <- lm(soil.res ~ 1 + lmoi + temp.15 + soiln0 + rootdw0 + sdoc5,
                  data=hainich.train) # top 5 by correlation
hainich.lm2 <- lm(soil.res ~ 1 + ph.soil5 + sno30 + snh45 + rootc0 + ph.litter,
                  data=hainich.train) # bottom 5 by correlation
hainich.lm3 <- lm(soil.res ~ 1 + lmoi + temp.15 + soiln0,
                  data=hainich.train) # top 3 by correlation

## evaluate models
spseHat <- function(model){
  # SPSE.hat1
  return(sum((hainich.test$soil.res - predict(model, newdata=hainich.test))^2))
}
spse1hat <- spseHat(hainich.lm1)
spse2hat <- spseHat(hainich.lm2)
spse3hat <- spseHat(hainich.lm3)


## annova with F statistic
# test one model against the other
# warning: both models have to be fitted with the same training data!
# density of F depends on degree of freedom!
anova(hainich.lm1,hainich.lm2)


## cross validation
# evaluate models spse (without considering fixed betas)
# test data size is size of whole data set / fold
# see also: http://stats.stackexchange.com/questions/12398
crossValSpse <- function(model, fold){
  index <- rep(1:fold, length.out=dim(hainich)[2])
  index <- sample(index)
  
  spseHat <- 0
  for (i in 1:fold)
  {
    test <- hainich[index==i,]
    train <- hainich[index!=i,]
    formu <- eval(model$call[[2]]) 
    #model based on new data
    model <- lm(formu, data = train)
    #add spse hat
    spseHat <- spseHat + sum((test$soil.res - predict(model, newdata=test))^2)
  }
  return(spseHat / fold)
}

# 3 fold cross validation gives average estimated spse
hainich.lm1.spse <- crossValSpse(hainich.lm1,3)
hainich.lm1.spse <- crossValSpse(hainich.lm2,3)
hainich.lm1.spse <- crossValSpse(hainich.lm3,3)

## plot variable against soil resp
for (i in seq(2,5)) {
  dat <- data.frame(hainich[i], hainich$soil.res)
  plot(dat, ylab = "Soil Resp.", xlab = names(hainich[i]))
}

## regsubset
#info: http://www.stat.columbia.edu/~martin/W2024/R10.pdf
# package leaps requires gfortran compiler!
library("leaps")
#fullModel: Top 8 variables corelated to soil.res
# and coupling term for litter moisture lmoi with temp 0 and 15
hainich.leaps1 <- regsubsets(soil.res ~ 1 + lmoi * temp.15 * temp.0 + soiln0 + 
                              soilc0 + rootdw0 + sdoc5 + litdoc,
                   data=hainich.train, method = "forward")
hainich.leaps2 <- regsubsets(soil.res ~ 1 + lmoi * temp.15 + soiln0 + 
                               soilc0 + rootdw0 + sdoc5 + litdoc,
                             data=hainich.train, method = "forward")

summary(hainich.leaps1)
summary(hainich.leaps1)$bic

#plot variable importance based on baissian infomation criterion
# best model based on BIC 
# (tradeoff btw. likelihood and number of parameters)
# soil.res ~ 1 + rootdw0 + lmoi:temp.15
plot(hainich.leaps2, main="Importance of Variables in Leap hainich.leap2")

## setting real model
hainich.realModel <- lm(soil.res ~ 1 + lmoi + temp.15 +
                          temp.0 + soiln0 + soilc0,
                        data = hainich.train)
hainich.realModel.spsehat <- spseHat(hainich.realModel)
# plot(hainich.realModel)

## overfitting model
# tooBigModel = realModel + every coupling term
hainich.tooBigModel <- lm(soil.res ~ 1 * lmoi * temp.15 *
                            temp.0 * soiln0 * soilc0,
                          data = hainich.train)
hainich.tooBigModel.spsehat <- spseHat(hainich.tooBigModel)
#function step uses AIC instead of F!
nextStep <- step(hainich.realModel, 
     scope = list(lower=hainich.realModel, upper=hainich.tooBigModel),
     direction = "forward")
nextStep$anova$"Resid. Df" # residual change in F value



## SIMULATION

#subsetting data
subsetSize <- 10 # number of samples taken from original dataset
subset <- hainich[sample(nrow(hainich), subsetSize), ]

#make pseudo observations
pseudo.soilResp <- predict(hainich.realModel, newdata = subset, type = "response")


## Simulation F values
realModelStr <- "soil.res ~ 1 + lmoi + temp.15 + temp.0 + soiln0 + soilc0"
# next model will have another feature in addition
excludeVarsRegEx <- "(soil.res|lmoi|temp.15|temp.0|soiln0|soilc0)"
nextVars <- names(hainich)[
  ! grepl(excludeVarsRegEx,names(hainich))]

#create result data frame
simulRes <- NULL
for(x in nextVars){
  #create formula for next Model by adding current variable
  nxtModelStr <- paste(realModelStr, "+", x)
  nxtModel <- lm(nxtModelStr, data = hainich.train)
  #evaluate nextModel
  an <- anova(hainich.realModel, nxtModel) 
  f <- an$F[2]
  p <- an$`Pr(>F)`[2]
  spse <- spseHat(nxtModel)
  simulRes <- rbind(simulRes, c(spse,x,f,p)) 
}
simulRes <- data.frame(spse=as.double(simulRes[,1]), 
                       addFeature=simulRes[,2] , F=as.double(simulRes[,3]),
                       p=as.double(simulRes[,4]), stringsAsFactors = T)

## evaluation

#which model with additional feature was the real winner (SPSE)?
idMinErr <-  which(simulRes$spse == min(simulRes$spse))
#which model won but was not the best one (F)?
idMaxF <- which(simulRes$F == max(simulRes$F))

xs <- seq(0,7,by = 0.05)
freal <- density(simulRes$F)
## WARNING: I have no idea how to calc the degree of freedoms!
## maybe an$Res.Df? need df1 and df2
fNominal <- df(xs,24,23)
plot(freal, xlim=c(min(xs),max(xs)), ylim=c(0,1),
     xlab = "F-Value",
     main="Kernel distribution of F Values \n from models with different extra feature")
points(xs, fNominal, col="red", type="lines") #F distribution
legend("topright",c("Data","Calculated"), lwd=2, col=c("black","red"), bty = "n")

##TO-DO: multiple random training for simulation and F-Value statistics
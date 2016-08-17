# nicht vergessen: setwd!
# setwd("/home/daniel/Schreibtisch/Statistik Projekt")

hainich <- read.csv("hainich.csv", sep = ";", dec = ".")

# Correlation mit Pearson
hainich.pear <- abs(cor(hainich))["soil.res",-1]
hainich.pear.ordered <- hainich.pear[order(hainich.pear, decreasing = T)]
barplot(hainich.pear.ordered, las = 2, ylim = c(0,0.5), col = "black",
        ylab = "Absolute Pearson Correlation", main = "Variables Correlated with Soil Respiration")

# fig/scatterplot-pearson-top6.png
pairs(~ lmoi + temp.15 + litdoc + litter.d  + smoi + rootdw0, data=hainich ,main="Simple Scatterplot Matrix")

# sampling training data
set.seed(1337)
testFraction <- 0.2 #Fraction of data used for testing (estimate for integer sample size)
sampleCount <- dim(hainich)[1]
index <- sample(1:sampleCount, round(testFraction * sampleCount))
hainich.test <- hainich[index,]
hainich.train <- hainich[-index,]

null <- lm(soil.res ~ 1, data = hainich.train)
# Top 15 Variablen
#full <- lm(soil.res ~ 1 + lmoi + temp.15 + litdoc + litter.d + smoi + rootdw0 + temp.0 + soiln0 + sno35 + soiln5 + rootc0 + rootdw5 + soilc0 + sdoc5 + soilc5, data = hainich.train)
# Top 6 Variablen
full <- lm(soil.res ~ 1 + lmoi + temp.15 + litdoc + litter.d + smoi + rootdw0, data = hainich.train)

step(null, scope=list(lower=null, upper=full), direction="forward")

#info: http://www.stat.columbia.edu/~martin/W2024/R10.pdf
library("leaps")
hainich.leaps <- regsubsets(soil.res ~ 1 + lmoi + temp.15 + litdoc + litter.d + smoi + rootdw0,
                             data=hainich.train, method = "forward")

summary(hainich.leaps)
par(mfrow=c(1,2))
plot(hainich.leaps, scale="bic")
plot(hainich.leaps, scale="adjr2")
summary(hainich.leaps1)$bic

plot(hainich.leaps1, scale="bic")
plot(hainich.leaps1, scale="adjr2")

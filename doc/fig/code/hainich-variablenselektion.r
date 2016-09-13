hainich <- read.csv("hainich.csv", sep = ";", dec = ".")

# Correlation mit Pearson
hainich.pear <- abs(cor(hainich))["soil.res",-1]
hainich.pear.ordered <- hainich.pear[order(hainich.pear, decreasing = T)]
barplot(hainich.pear.ordered, las = 2, ylim = c(0,0.5), col = "black",
        ylab = "Absolute Pearson Korrelation", main = "Korrelation der Variablen mit Soil Respiration")

names(hainich.pear.ordered)
pairs(~ lmoi + temp.15 + litdoc + litter.d  + smoi + rootdw0 + temp.0 + soiln0, data=hainich ,main="Scatterplot der Top 8 korrelierenden Variablen nach Pearson")

# Shapiro: normalverteilt?
hainich.shapiro <- mapply(function(x) shapiro.test(x)$p.value,hainich)
hainich.shapiro.ordered <- hainich.shapiro[order(hainich.shapiro, decreasing = T)]
barplot(hainich.shapiro.ordered, las = 2, ylim = c(0,1), col = "black",
        ylab = "p-value", main = "Shapiro Test aller Variablen")
abline(h=0.05, col="red")

hainich.normal <- hainich[names(hainich.shapiro.ordered[hainich.shapiro.ordered > 0.05])]



# sampling training data
set.seed(1337)
testFraction <- 0.2 #Fraction of data used for testing (estimate for integer sample size)
sampleCount <- dim(hainich)[1]
index <- sample(1:sampleCount, round(testFraction * sampleCount))
hainich.test <- hainich[index,]
hainich.train <- hainich[-index,]

null <- lm(soil.res ~ 1, data = hainich.train)
full <- lm(soil.res ~ 1 + lmoi + temp.15 + smoi + soiln0, data=hainich.train)

step(null, scope=list(lower=null, upper=full), direction="forward")

#info: http://www.stat.columbia.edu/~martin/W2024/R10.pdf
library("leaps")
hainich.leaps <- regsubsets(soil.res ~ 1 + lmoi + temp.15 + smoi + soiln0,
                             data=hainich.train, method = "forward")

summary(hainich.leaps)
par(mfrow=c(1,2))
plot(hainich.leaps, scale="bic")
plot(hainich.leaps, scale="adjr2")
mtext("Model-Selektion mit \"forward selection\"", side=3, outer=TRUE, line=-3.5, cex=1, font = 2)
summary(hainich.leaps)$bic


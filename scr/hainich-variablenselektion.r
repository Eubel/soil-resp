hainich <- read.csv("hainich.csv", sep = ";", dec = ".")

# Correlation mit Pearson
hainich.pear <- abs(cor(hainich))["soil.res",-1]
hainich.pear.ordered <- hainich.pear[order(hainich.pear, decreasing = T)]
#png(file="../doc/fig/correlation-pearson.png",width=800,height=360)
barplot(hainich.pear.ordered, las = 2, ylim = c(0,0.5), col = "black",
        ylab = "Absolute Pearson Korrelation", main = "Korrelation der Variablen mit Soil Respiration")
#dev.off()

names(hainich.pear.ordered)
# fig/scatterplot-pearson-top8.png
#png(file="../doc/fig/scatterplot-pearson-top8.png",width=800,height=800)
pairs(~ lmoi + temp.15 + litdoc + litter.d  + smoi + rootdw0 + temp.0 + soiln0, data=hainich ,main="Scatterplot der Top 8 korrelierenden Variablen nach Pearson")
#dev.off()

# Shapiro normalverteilt?
hainich.shapiro <- mapply(function(x) shapiro.test(x)$p.value,hainich)
hainich.shapiro.ordered <- hainich.shapiro[order(hainich.shapiro, decreasing = T)]
#png(file="../doc/fig/normalverteilung-shapiro.png",width=800,height=360)
barplot(hainich.shapiro.ordered, las = 2, ylim = c(0,1), col = "black",
        ylab = "p-value", main = "Shapiro Test aller Variablen")
abline(h=0.05, col="red")
#dev.off()

hainich.normal <- hainich[names(hainich.shapiro.ordered[hainich.shapiro.ordered > 0.032])]

# Correlation mit Pearson
hainich.pear <- abs(cor(hainich.normal))["soil.res",-16]
hainich.pear.ordered <- hainich.pear[order(hainich.pear, decreasing = T)]
#png(file="../doc/fig/correlation-pearson.png",width=800,height=360)
barplot(hainich.pear.ordered, las = 2, ylim = c(0,0.5), col = "black",
        ylab = "Absolute Pearson Korrelation", main = "Korrelation der Variablen mit Soil Respiration")
#dev.off()






# fig/scatterplot-pearson-top8-normalverteilt.png
png(file="../doc/fig/scatterplot-pearson-normalverteilt.png",width=800,height=800)
pairs(~ lmoi + temp.15 + smoi + soiln0, data=hainich ,main="Scatterplot der ausgewählten Variablen")
dev.off()
#pairs(~ lmoi + log(temp.15) + smoi + soiln0, data=hainich ,main="Simple Scatterplot Matrix")

#shapiro.test(hainich$soiln0)$p.value
#shapiro.test(log(hainich$soiln0))$p.value

#pairs(~ soil.res + exp(temp.15) + exp(temp.10) + exp(temp.5) + exp(temp.0), data=hainich[2:38,])

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
#full <- lm(soil.res ~ 1 + lmoi + temp.15 + litdoc + litter.d + smoi + rootdw0, data = hainich.train)
# Top 8 nur normalverteilte Variablen = 4
full <- lm(soil.res ~ 1 + lmoi + temp.15 + smoi + soiln0, data=hainich.train)

step(null, scope=list(lower=null, upper=full), direction="forward")

#info: http://www.stat.columbia.edu/~martin/W2024/R10.pdf
library("leaps")
hainich.leaps <- regsubsets(soil.res ~ 1 + lmoi + temp.15 + smoi + soiln0,
                             data=hainich.train, method = "forward")

summary(hainich.leaps)
png("../doc/fig/variablenselektion-bic-adjr2.png", width = 400, height = 270)
par(mfrow=c(1,2))
plot(hainich.leaps, scale="bic")
plot(hainich.leaps, scale="adjr2")
mtext("Model-Selektion mit \"forward selection\"", side=3, outer=TRUE, line=-3.5, cex=1, font = 2)
dev.off()
summary(hainich.leaps)$bic


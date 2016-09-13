hainich <- read.csv("hainich.csv", sep = ";", dec = ".")

# spearman (monoton)
hainich.spear <- abs(cor(hainich, method = "spearman"))["soil.res",-1]
hainich.spear.ordered <- hainich.spear[order(hainich.spear, decreasing = T)]
barplot(hainich.spear.ordered, las = 2, ylim = c(0,0.5), col = "black",
        ylab = "Absolute Spearman Correlation", main = "Variables Correlated with Soil Respiration")

# pearson (linear)
hainich.pear <- abs(cor(hainich, method = "pearson"))["soil.res",-1]
hainich.pear.ordered <- hainich.pear[order(hainich.pear, decreasing = T)]
barplot(hainich.pear.ordered, las = 2, ylim = c(0,0.5), col = "black",
        ylab = "Absolute Pearson Correlation", main = "Variables Correlated with Soil Respiration")
# p.value < 0.05 bedeutet nicht normalverteilt
shapiro.test(hainich[,1])$p.value

hainich.pear <- abs(cor(hainich, method = "pearson"))["soil.res",-1]
hainich.pear.ordered <- hainich.pear[order(hainich.pear, decreasing = T)]
barplot(hainich.pear.ordered, las = 2, ylim = c(0,0.5), col = "black",
        ylab = "Absolute Pearson Correlation", main = "Variables Correlated with Soil Respiration")

# Vergleich der Barplots
spearpear = t(data.frame(hainich.spear, hainich.pear))
spearpear.ordered <- spearpear[,order(apply(spearpear, c(2),FUN=mean), decreasing = T)]
barplot(as.matrix(spearpear.ordered), las = 2, beside=TRUE)

# Shapiro: normalverteilt?
hainich.shapiro <- mapply(function(x) shapiro.test(x)$p.value,hainich)
hainich.shapiro.ordered <- hainich.shapiro[order(hainich.shapiro, decreasing = T)]
barplot(hainich.shapiro.ordered, las = 2, ylim = c(0,1), col = "black",
        ylab = "Shapiro Test p-value", main = "Variables")
abline(h=0.05, col="red")
shapiro.test(hainich[,14])

names(hainich.shapiro.ordered)

# Basic Scatterplot Matrix

## Top 15 Spearman Variablen
pairs(~ lmoi + temp.15 + soiln0 + temp.0 + soilc0 + rootdw0 + rootdw5 + sdoc5 + soil.res,data=hainich ,main="Simple Scatterplot Matrix")

## Top 15 Pearson Variablen
pairs(~ lmoi + temp.15 + litdoc + litter.d  + smoi + rootdw0 + temp.0 + sdoc5 + soil.res,data=hainich ,main="Simple Scatterplot Matrix")

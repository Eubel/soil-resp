#
# Has Temperature an non linear effect on soil-resp?
#

hainich <- read.csv("hainich.csv", sep = ";", dec = ".")
plot(hainich$temp.0,hainich$soil.res,
     xlim = c(11,13.5),
     ylab = "Soil Respiration", xlab = "Soil Temperature")
points(hainich$temp.5,hainich$soil.res, col = "red")
points(hainich$temp.10,hainich$soil.res, col = "blue")
legend("topright",c("0cm","5cm","10cm"), lwd=2, 
       col=c("black","red","blue"), bty = "n")
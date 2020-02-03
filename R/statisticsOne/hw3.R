sr <- read.table("Stats1.13.HW.03.txt", header=T)
nrow(sr)
names(sr)

round(cor(sr[3:10]), 2)

mean(abs(sr[3]-sr[5])[,])
mean(abs(sr[4]-sr[6])[,])
mean(abs(sr[7]-sr[9])[,])
mean(abs(sr[8]-sr[10])[,])

aer <- subset(sr, sr[, 2]=="aer")
aer
des <- subset(sr, sr[, 2]=="des")
des

mean((aer[5]-aer[3])[,])
mean((aer[6]-aer[4])[,])
mean((aer[9]-aer[7])[,])
mean((aer[10]-aer[8])[,])

mean((des[5]-des[3])[,])
mean((des[6]-des[4])[,])
mean((des[9]-des[7])[,])
mean((des[10]-des[8])[,])

sr

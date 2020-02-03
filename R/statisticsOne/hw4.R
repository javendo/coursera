HW4 <- read.table("Stats1.13.HW.04.txt", header = T)
describe(HW4) 
cor(HW4[2:4])
round(cor(HW4[2:4]), 2)

model1 <- lm(HW4$salary ~ HW4$years)
summary(model1)
plot(HW4$salary ~ HW4$years, main = "Scatterplot", ylab = "Salary", xlab = "Years")
abline(lm(HW4$salary ~ HW4$years), col="blue")

model2 <- lm(HW4$salary ~ HW4$courses)
summary(model3)
plot(HW4$salary ~ HW4$courses, main = "Scatterplot", ylab = "Salary", xlab = "Courses")
abline(lm(HW4$salary ~ HW4$courses), col="blue")

model3 <- lm(HW4$salary ~ HW4$years + HW4$courses)
summary(model3)
plot(HW4$salary ~ HW4$years + HW4$courses, main = "Scatterplot", ylab = "Salary", xlab = "Years plus Courses")
abline(lm(HW4$salary ~ HW4$years + HW4$courses), col="blue")

model1.z <- lm(scale(HW4$salary) ~ scale(HW4$years))
summary(model1.z)

model2.z <- lm(scale(HW4$salary) ~ scale(HW4$courses))
summary(model2.z)

summary(fitted(model3))
HW4$e <- resid(model3)

summary(HW4$e)
hist(HW4$e)

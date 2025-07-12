## #############################################################################
## basic math operations
## #############################################################################

1 + 3
3 * 3
3^2
## ~undocumented, but works like in Python
3**2

## #############################################################################
## Happy New Year in 2025!
## #############################################################################

45^2

## code style: space before and after operators, except
(20+25)^2

(2+0+2+5) * (2-0-2-5)
((2+0+2+5) * (2-0-2-5))^2

1^3 + 2^3 + 3^3 + 4^3 + 5^3 + 6^3 + 7^3 + 8^3 + 9^3
1:9
(1:9)^3
sum((1:9)^3)

sum(1:9)^2

# we know vectors! do we?
as.Date("2025-01-01")
as.Date("2025-01-03")
as.Date("2025-01-01"):as.Date("2025-01-03")

str(as.Date("2025-01-01"))
str(as.Date("2025-01-01"):as.Date("2025-01-03"))

seq(as.Date("2025-01-01"), as.Date("2025-01-03"), by = "1 day")
str(seq(as.Date("2025-01-01"), as.Date("2025-01-03"), by = "1 day"))

weekdays(seq(as.Date("2025-01-01"), as.Date("2025-01-03"), by = "1 day"))
substr(weekdays(seq(as.Date("2025-01-01"), as.Date("2025-01-03"), by = "1 day")), 1, 1)

## #############################################################################
## constants
## #############################################################################

pi
"pi"
'pi'

?pi

## #############################################################################
## vectors recap
## #############################################################################

letters
LETTERS
str(letters)

## one-based indexing!
letters[1]
letters[5]
letters[1:5]
1:5
seq(1, 5)
?seq
seq(1, 5, by = 0.1)
seq(1, 5, 0.1)
seq(by = 0.1, from = 1, to = 5)

## #############################################################################
## variables
## #############################################################################

x = 4  # works, but not in sync with the common code style
x <- 4 # good!

x * 2

## TODO compute the square root of x
x ^ 2
x ^ 0.5

## #############################################################################
## functions
## #############################################################################

sqrt(x)

hist(runif(100000))
?runif

runif(5, 5, 25)

## TODO sine wave
x <- 1:20
x <- 'foobar'
x <- runif
x(5)
x <- 1:20
sin(x)

## #############################################################################
## basic plots
## #############################################################################

plot(x, sin(x))
plot(x, sin(x), type = 'l')
?plot
?plot.default

## later => ggplot2

x <- seq(0, pi*2, by = 0.1)
plot(x, sin(x), type = 'l', col = 'red')

curve(sin, to = pi * 2)
?curve
?plot
?plot.default
curve(cos, to = pi * 2, col = 'red', add = TRUE)

## NOTE TRUE is often abbreviated to T, but avoid by all means, see e.g.
## T <- FALSE

## TODO Brownian motion / random walk for 100 steps
x <- 0
# +1
# -1

for (i in 1:100) { # whitespace doesn't matter, but stick with a code style!
    if (runif(1) < 0.5) {
        x <- x - 1
    } else {
        x <- x + 1
    }
}
x

set.seed(42)
x <- sample(c(1, -1),
            size = 100,
            replace = TRUE)

cumsum(x)
plot(cumsum(x), type = 's')

## vectorize (always)
x <- round(runif(100))*2-1
cumsum(x)

w <- matrix(round(runif(1e3))*2-1, nrow = 10)
w <- apply(w, 1, cumsum)
w
w[100, ]

w <- matrix(round(runif(1e6))*2-1, nrow = 1e3)
w <- apply(w, 1, cumsum)
str(w)
w[1000, ]
hist(w[1000, ])

w <- matrix(round(runif(1e3))*2-1, nrow = 100)
w <- apply(w, 1, sum)


## DATA!
h <- c(174, 170, 160)
w <- c(90, 80, 70)

plot(h, w, main = 'Heights and weights of students',
     xlab = 'Height', ylab = 'Weight')

## #############################################################################
## basic stats
## #############################################################################

min(w)
max(w)
range(w)
diff(range(w))
mean(w)
median(w)
sum(w)
summary(w)

cor(w, h)
lm(w ~ h) # linear model


165 * 1.3462 -146.1538

fit <- lm(w ~ h)
predict(fit, newdata = list(h = 165))

## extrapolation + needs more data! e.g. on newborns..
predict(fit, newdata = list(h = 52))

str(fit)
fit
summary(fit)

abline(fit, col = 'red')

## #############################################################################
## data frames
## #############################################################################

df <- data.frame(weight = w, height = h)
df
str(df)
df$weight
df$weight[1]
df[1, 1]
df[2, 2]
df[1, ]
df[, 1]

cor(df)
plot(df)
lm(df)

## compute Body Mass Index (BMI)
df$bmi <- df$weight / (df$height/100)^2
str(df)
df

df <- read.csv('http://bit.ly/CEU-R-heights')
str(df)
plot(df)

## TODO check the number of observation
length(df)
str(df)
nrow(df)
?nrow
dim(df)

## dim returns same as
c(nrow(df), ncol(df))

## TODO check the height of the 2nd respondent
df$heightIn[2]
df[2, 4]
df[2, 'heightIn']
df[2, "heightIn"]

## TODO compute height in cm
df$heightIn * 2.54
str(df)
df$height <- df$heightIn * 2.54
str(df)

## drop a column
df$heightIn <- NULL
str(df)

## TODO compute weight in kg
df$weight <- df$weightLb * .45
str(df)

## TODO compute BMI
df$bmi <- df$weight / (df$height/100)^2

## removing 2 columns
df$weightLb <- df$ageMonth <- NULL
str(df)

## quick EDA
plot(df) ## data.frame

## interactivity
install.packages('pairsD3')
library(pairsD3)
pairsD3(df)

## why ggplot?
install.packages('GGally')
library(GGally)
ggpairs(df)

## #############################################################################
## intro to ggplot2
## #############################################################################

## the R implementation of the Grammar of Graphics
library(ggplot2)

## barplot with ggplot: you specify a dataset, then define an aesthetic and geom
ggplot(df, aes(x = height)) + geom_histogram()
## and optionally some further layers (theme)
ggplot(df, aes(x = height)) + geom_histogram() + theme_bw()
ggplot(df, aes(x = height)) + geom_histogram(colour = "darkgreen", fill = "white") + theme_bw()

## we can store the resulting plot as an R object for future reuse
p <- ggplot(df, aes(x = height)) + geom_histogram()
p
p + theme_bw()

## it's better to split long lines for easier reading
p <- ggplot(df, aes(x = height)) +
     geom_histogram() +
     theme_bw()
p

## coord transformations
library(scales)
p + scale_y_log10()
p + scale_y_sqrt()
p + scale_y_reverse()
p + coord_flip()

## other categorical variable: country
ggplot(df, aes(x = sex)) + geom_histogram() # ERROR
ggplot(df, aes(x = sex)) + geom_bar()
ggplot(df, aes(x = sex)) + geom_bar() + theme(axis.text.x = element_text(angle = 90))
## QQ ordering? later...
?theme

## other geoms
ggplot(df, aes(height, weight)) + geom_point()
ggplot(df, aes(height, weight)) + geom_point() + geom_smooth()
ggplot(df, aes(height, weight)) + geom_point() + geom_smooth(method = 'lm', color = 'red', se = FALSE)

## mix continious with a discrete variable
ggplot(df, aes(height)) + geom_boxplot()
ggplot(df, aes(sex, height)) + geom_boxplot()
ggplot(df, aes(sex, height)) + geom_violin()
ggplot(df, aes(sex, height)) + geom_boxplot() + geom_violin(alpha = .25)
ggplot(df, aes(sex, height)) + geom_boxplot() + geom_violin(alpha = .25) +  geom_jitter()

## facet => create separate plots per group
p <- ggplot(df, aes(x = height)) + geom_histogram()
p + facet_wrap( ~ sex)

## density plot
ggplot(df, aes(x = height)) + geom_density()
ggplot(df, aes(x = height, fill = sex)) + geom_density()
ggplot(df, aes(x = height, fill = sex)) + geom_density(alpha = 0.2) + theme_bw()
ggplot(df, aes(x = height, fill = sex)) + geom_density(alpha = 0.2) + theme_bw() +
    ggtitle("Height of boys and girls") +
    xlab("Height (cm)") + ylab("") +
    theme(legend.position = "top")

?theme

## plot number of girls and boys below and above 160 cm!
## maybe a stacked barchart?

ggplot(df, aes(x = sex, y = ...)) + geom_bar()
## need to transform the data ...
df$height_cat <- df$height < 160
table(df$height_cat)
df$height_cat <- cut(df$height, breaks = c(0, 160, Inf))
table(df$height_cat)

ggplot(df, aes(x = sex, fill = height_cat)) + geom_bar()
ggplot(df, aes(x = sex, fill = height_cat)) + geom_bar(position = "dodge")
ggplot(df, aes(x = sex, fill = height_cat)) + geom_bar(position = "fill")

## #############################################################################
## intro to data.table
## #############################################################################

## avg height per gender
mean(df[df$sex == "f", "weight"])

dff <- subset(df, sex == 'f')
mean(dff$weight)
x
aggregate(height ~ sex, FUN = mean, data = df)

## there must be a better way!
library(data.table)
dt <- data.table(df)
dt # VS df!

## dt[i]
dt[1]
dt[1:5]
dt[sex == "f"]
dt[sex == "f"][1:5] # chaining
dt[ageYear == min(ageYear)]
dt[ageYear == min(ageYear)][order(height)]

dt[round(runif(1)*.N)]
dt[round(runif(10)*.N)]
dt[.N]

## dt[i, j]
dt[, mean(height)]
dt[ageYear == min(ageYear), mean(height)]
dt[ageYear == min(ageYear), summary(height)]
dt[ageYear == min(ageYear), hist(height)]

## TODO compute the average height of girls and boys
dt[sex == "f", mean(height)]
dt[sex == "m", mean(height)]

## dt[i, j, by]
dt[, mean(height), by = sex]
dt[, list(H = mean(height)), by = list(gender = sex)]
## note that list can be abbreviated by a dot (.) in data.table
dt[, .(H = mean(height)), by = .(gender = sex)]
dt[, .(H = mean(height), W = mean(weight)), by = .(gender = sex)]
dt[, .(H = mean(height), W = mean(weight)), by = .(gender = sex, elementary_school = ageYear < 14)]

## count the number of folks below/above 12 yrs
dt$agecat <- cut(dt$ageYear, c(0, 12, Inf))
dt[, agecat := cut(ageYear, c(0, 12, Inf))]
dt[, .N, by = agecat]
## show the average weight of high BMI (25) folks
dt[bmi > 25, mean(weight)]
## categorize folks to underweight (<18.5)/normal/overweight (25+)
dt[, bmicat := cut(bmi, c(0, 18.5, 25, Inf))]
## stacked bar chart for BMI categorization split by gender
ggplot(dt, aes(x = sex, fill = bmicat)) + geom_bar()
ggplot(dt[, .N, by = .(sex, bmicat)], aes(x = sex, y = N, fill = bmicat)) + geom_col()

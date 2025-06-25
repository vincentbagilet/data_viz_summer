
library(tidyverse)
library(broom)

n_iter <- 100

for (i in 1:n_iter) {
  N <- 1000
  a <- 2
  b <- 0.3
  # c <- 4
  # d <- 0.2
  
  dat <- tibble(
    x = rnorm(N),
    # w = rnorm(N, 0.8),
    e = rnorm(N, 0, 0.5),
    # y = a + b*x + c*w + d*x*w + e
    y = a + b*x + e
  )
  
  lm(data = dat, y ~ x) |> 
    tidy() |> 
    filter(term == "x") |> 
    bind_rows(res)
}



N <- 1000
a <- 2
b <- 0.3
# c <- 4
# d <- 0.2

dat <- tibble(
  x = rnorm(N),
  # w = rnorm(N, 0.8),
  e = rnorm(N, 0, 0.5),
  # y = a + b*x + c*w + d*x*w + e
  y = a + b*x + e
)

res <- lm(data = dat, y ~ x)



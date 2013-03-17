context("constrained_data_frame")

test_that("Subclassing works", {
  constrained_data_frame("df1", columns=c(a="factor"))
  expect_is(new("df1", data.frame(a=letters)), "df1")
})

test_that("Subclassing returns a function", {
  df1 <- constrained_data_frame("df1", columns=c(a="factor"))
  expect_is(df1(data.frame(a=letters)), "df1")
})

################

Foo <- constrained_data_frame("Foo", columns=c(a="numeric", b="numeric"))
foo <- Foo(data.frame(a=1:5, b=6:10))

####

context("subclass DataFrameConst [ method")

test_that("[,DataFrameConstr,missing,missing works", {
  expect_equal(foo[], foo)
})

test_that("[,DataFrameConstr,missing,character with drop=missing  works", {
  expect_equal(foo[ , "a"], as.numeric(1:5))
})

test_that("[,DataFrameConstr,missing,character with drop=FALSE works", {
  expect_equal(foo[ , "a", drop=FALSE], data.frame(a=1:5))
})

test_that("[,DataFrameConstr,missing,character with drop=FALSE works", {
  expect_equal(foo[ , "a", drop=FALSE], data.frame(a=1:5))
})

test_that("[,DataFrameConstr,integer,mssing works", {
  expected <- Foo(data.frame(a=1:2, b=6:7))
  expect_equal(foo[1:2], expected)
})

test_that("[,DataFrameConstr,integer,mssing: test #1", {
  expect_equal(foo[1:2, "a"], 1:2)
})

test_that("[,DataFrameConstr,integer,mssing: test #2", {
  expect_equal(foo[1:2, "a", drop=FALSE], data.frame(a=1:2))
})

test_that("[,DataFrameConstr,integer,mssing: test #3", {
  expected <- Foo(data.frame(a=1:2, b=6:7))
  expect_equal(foo[1:2, c("a", "b"), drop=FALSE], expected)
})

########
context("Subclass of DataFrameConstr [<- method")

test_that("[<-,Foo,missing,missing: working", {
  foo[] <- 1
  expected <- Foo(data.frame(a=rep(1, 5), b=rep(1, 5)))
  expect_equal(foo, expected)
})

test_that("[<-,Foo,missing,ANY: working", {
  foo[ , "b"] <- 11:15
  expected <- Foo(data.frame(a=1:5, b=11:15))
  expect_equal(foo, expected)
})

test_that("[<-,Foo,missing,ANY: error", {
  expect_error(foo[ , "b"] <- "a", "invalid class")
})

test_that("[<-,Foo,ANY,missing: works", {
  foo[1, ] <- 100
  expected <- Foo(data.frame(a=c(100, 2:5), b=c(100, 7:10)))
  expect_equal(foo, expected)
})

test_that("[<-,Foo,missing,ANY: error", {
  expect_error(foo[1] <- "a", "invalid class")
})

test_that("[<-,Foo,ANY,ANY: works", {
  foo[1, "a"] <- 100
  expected <- Foo(data.frame(a=c(100, 2:5), b=6:10))
  expect_equal(foo, expected)
})

test_that("[<-,Foo,ANY,ANY: error", {
  expect_error(foo[1, "a"] <- "a", "invalid class")
})

#######

context("subclass of DataFrameConstr [[<- methods")

test_that("[[<-,Foo,missing,missing error", {
  expect_error(foo[[]] <- 1, "missing subscript")
})

test_that("[[<-,Foo,integer,missing works", {
  foo[[1]] <- 100
  expected <- Foo(data.frame(a=rep(100, 5), b=6:10))
  expect_equal(foo, expected)
})

test_that("[[<-,Foo,character,missing works", {
  foo[["a"]] <- 100
  expected <- Foo(data.frame(a=rep(100, 5), b=6:10))
  expect_equal(foo, expected)
})

test_that("[[<-,Foo,ANY,missing error", {
  expect_error(foo[["a"]] <- "a", "invalid class")
})

test_that("[[<-,Foo,integer,integer,missing works", {
  foo[[1, 1]] <- 100
  expected <- Foo(data.frame(a=c(100, 2:5), b=6:10))
  expect_equal(foo, expected)
})

test_that("[[<-,Foo,integer,character,missing works", {
  foo[[1, "a"]] <- 100
  expected <- Foo(data.frame(a=c(100, 2:5), b=6:10))
  expect_equal(foo, expected)
})

test_that("[[<-,Foo,ANY,ANY error", {
  expect_error(foo[[1, "a"]] <- "a", "invalid class")
})

####

context("subclass of DataFrameConstr $<- method")

test_that("$<-,DataFrameConstr works", {
  foo$a <- 11:15
  expected <- Foo(data.frame(a=11:15, b=6:10))
  expect_equal(foo, expected)
})

test_that("$<-,DataFrameConstr error", {
  expect_error(foo$a <- "a", "invalid class")
})


### cbind2

context("subclass of DataFrameConstr cbind2 works")

test_that("cbind2,Foo works", {
  bar <- cbind2(foo, data.frame(c=11:15))
  expect_is(bar, "Foo")
})

### rbind2
context("subclass of DataFrameConstr rbind2 works")

test_that("rbind2,Foo works", {
  bar <- rbind2(foo, data.frame(a=6, b=11))
  expect_is(bar, "Foo")
})

### colnames<-
context("colnames<- method")

test_that("colnames<- error", {
  expect_error(colnames(foo) <- c("d", "b"))
})

test_that("colnames<- works", {
  colnames(foo) <- c("a", "b")
  expect_is(foo, "Foo")
})

####
context("rownames<- method")

test_that("rownames<- works", {
  rownames(foo) <- letters[1:5]
  expect_is(foo, "Foo")
})

test_that("rownames<- with NULL works", {
  rownames(foo) <- NULL
  expect_is(foo, "Foo")
})

####
context("names<- method")

test_that("names<- works", {
  names(foo) <- c("a", "b")
  expect_is(foo, "Foo")
})

test_that("names<- error", {
  expect_error(names(foo) <- c("c", "b"), "invalid class")
})

####
context("dimnames<- method")

test_that("dimnames<- works", {
  dimnames(foo) <- list(1:5, c("a", "b"))
  expect_is(foo, "Foo")
})

test_that("dimnames<- error", {
  expect_error(dimnames(foo) <- list(1:5, c("d", "b")), "invalid class")
})

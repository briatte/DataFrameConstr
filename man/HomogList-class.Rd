\docType{class}
\name{HomogList-class}
\alias{HomogList-class}
\title{Homogenous List}
\arguments{
  \item{...}{Passed onto generic functions.}
}
\description{
An S4 subclass of \code{list} in which all elements of the
list to be the same class.
}
\details{
This is similar to the 'atomic lists' in R in that all
elements of the vector must be the same class, but the
\code{HomogList} supports arbitrary classes. \code{NULL}
values are also valid.
}
\section{Slots}{
  \describe{ \item{\code{.Data}}{Object of class
  \code{list}.} \item{\code{classtype}}{Object of class
  \code{character}. Required classtype for all elements in
  the list.} }
}

\section{Extends}{
  \describe{ \item{\code{list}}{Directly.} }
}

\section{Methods}{
  \describe{ \item{[<-}{\code{signature(x = "HomogList")}:
  ... } \item{[}{\code{signature(x = "HomogList")}: ... }
  \item{[[<-}{\code{signature(x = "HomogList")}: ... }
  \item{c}{\code{signature(x = "HomogList")}: ... }
  \item{show}{\code{signature(object = "HomogList")}: ... }
  }
}
\examples{
foo <- HomogList(list(sum=sum, max=max, min=min), "function")
print(foo)
x <- 1:10
lapply(foo, function(f) f(x))
foo[["mean"]] <- mean
print(foo)
# error
try(foo[["a"]] <- 1)
}
\keyword{classes}


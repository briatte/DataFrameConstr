#' @include package.r
#' @include subclass_homog_list.r
#' @export psData
#' @export validate_data_frame
#' @exportClass psData
#' @exportMethod [<-
#' @exportMethod [[<-
#' @exportMethod $<-
#' @exportMethod [
#' @exportMethod cbind2
#' @exportMethod rbind2
#' @exportMethod colnames<-
#' @exportMethod rownames<-
#' @exportMethod names<-
#' @exportMethod merge
NULL

# @exportMethod dimnames<- ## to add above?

FunctionList <- subclass_homog_list("FunctionList", "function")
CharacterList <- subclass_homog_list("CharacterList", "character")

#' Validate \code{data.frame}: column names, classes, and arbitrary constraints
#'
#' Check that a \code{data.frame} has columns with specified names and classtypes, or
#' satisfies arbitrary constraints.
#'
#' @param object \code{data.frame} to be validated.
#' @param columns Named \code{character} vector. Names are column names, values are
#' the required classes for those columns.
#' @param exclusive \code{logical} If \code{TRUE}, then \code{object}
#' cannot contain any columns other than those in \code{columns}
#' @param constraints \code{list} of functions. Each function should
#' take only one argument, and return \code{logical}.
#' 
#' @return If valid, then \code{TRUE}, else \code{character} with
#' an error message.
#'
#' @examples
#' data(iris)
#' # check that the iris dataset has numeric column Sepal.Length
#' # and factor column Species.
#' validate_data_frame(iris,
#'                     columns=c(Sepal.Length="numeric",
#'                               Species="factor"))
#' # Error because iris does not have column 'foo'
#' try(validate_data_frame(iris,
#'                     columns=c(foo="numeric")))
#' # Error because Sepal.Length is not an integer
#' try(validate_data_frame(iris,
#'                     columns=c(foo="ineger")))
validate_data_frame <- function(object, columns=NULL, exclusive=FALSE, 
                                constraints=list(), design = list()) {
  constraints <- FunctionList(constraints)

  # if these become compulsory
  design <- CharacterList(design)
  # meta <- CharacterList(meta)

  if (length(columns)) {
    for (i in names(columns)) {
      # hack
      if (i == "ANY") {
        next
      }
      if (! i %in% colnames(object)) {
        return(sprintf("column %s not in 'object'", i))
      }
      if (!is(object[[i]], columns[[i]])) {
        return(sprintf("column %s does not inherit from %s",
                       i, columns[[i]]))
      }
    }
  }
  if (exclusive) {
    othercols <- setdiff(colnames(object), names(columns))
    if (length(othercols)) {
      return(sprintf("invalid columns: %s",
                     paste(sQuote(othercols), collapse=", ")))
    }
  }
  for (f in constraints) {
    rc <- f(object)
    if (!all(rc)) {
      return(sprintf("Constraint failed:\n%s", paste(deparse(f), collapse="\n")))
    }
  }
  for (g in names(design)) {
    if(g %in% c("panel", "time") & any(!object@design[[g]] %in% names(object)))
      return(sprintf("missing panel variable(s): %s", 
                     paste0(object@design[[g]][ !object@design[[g]] %in% names(object) ], collapse=", ")))
  }
  TRUE
}

#' Data Frame with constraints
#'
#' Creates a new object directly extended \code{\link{data.frame}},
#' but with constrains that require columns. This class can be used
#' to ensure that data frames have a specific structure.
#'
#' @param ... Data to include in the object.
#' 
#' @section Slots:
#' 
#' \describe{
#' \item{\code{.Data}:}{Object of class \code{"list"}}
#' \item{\code{columns}}{Named \code{character} vector. The names are the
#' column names, and the values are the required classes of the column.}
#' \item{\code{exclusive}}{Object of class \code{logical}. If \code{TRUE},
#' then the data frame cannot contain any columns other than those
#' in \code{columns}}
#' \item{\code{constraints}}{Object of class \code{list} containing \code{function}
#' elements.  Each function in the list should take one argument, and return \code{logical}.}
#' \item{\code{names}:}{Object of class \code{"character"} Column names}
#' \item{\code{row.names}:}{Object of class \code{"data.frameRowLabels"} Row names}
#' \item{\code{.S3Class}:}{Object of class \code{"character"} Name of \code{S3Class}}
#' }
#'
#' @section Methods:
#'
#' Methods commonly used with data frames are defined to return \code{"psData"}
#' objects where appropriate, or throw errors if they would create an invalid
#' \code{"psData"} object.
#'
#' \describe{
#'   \item{[<-}{\code{signature(x = "psData")}: }
#'   \item{[[<-}{\code{signature(x = "psData")}: }
#'   \item{[}{\code{signature(object = "psData")}:
#'   Returns \linkS4class{psData} if the returned object is valid,
#'   otherwise returns a \code{data.frame}.
#'   }
#'   \item{$<-}{\code{signature(x = "psData")}: }
#'   \item{cbind2}{\code{signature(x = "psData")}:}
#'   \item{rbind2}{\code{signature(x = "psData")}: ... }
#'   \item{names<-}{\code{signature(x = "psData")}: ... }
#'   \item{colnames<-}{\code{signature(object = "psData")}: }
#'   \item{rownames<-}{\code{signature(object = "psData")}: }
#'   \item{dimnames<-}{\code{signature(object = "psData")}: }
#' }
#'
#' @section Extends:
#'
#' \describe{
#' \item{\code{data.frame}}{Directly.}
#' }
#' 
#' @docType class
#' @keywords classes
#' @aliases psData-class
#' @aliases psData
#' @aliases [,psData,missing,missing-method
#' @aliases [,psData,missing,ANY-method
#' @aliases [,psData,ANY,missing-method
#' @aliases [,psData,ANY,ANY-method
#' @aliases [<-,psData,ANY,ANY-method
#' @aliases [<-,psData,ANY,missing-method
#' @aliases [<-,psData,missing,ANY-method
#' @aliases [<-,psData,missing,missing-method
#' @aliases [[<-,psData,ANY,missing-method
#' @aliases [[<-,psData,ANY,ANY-method
#' @aliases $<-,psData-method
#' @aliases show,psData-method
#' @aliases rbind2,psData,ANY-method
#' @aliases cbind2,psData,ANY-method
#' @aliases colnames<-,psData-method
#' @aliases rownames<-,psData,ANY-method
#' @aliases rownames<-,psData,NULL-method
#' @aliases names<-,psData,ANY-method
#' @aliases dimnames<-,psData,list-method
#' @aliases initialize,psData-method
#' @examples
#' foo <- 
#'   psData(data.frame(a = runif(3), b = runif(3), c = letters[1:3]),
#'                   columns = c(a = "numeric", b = "ANY", c = "factor"),
#'                   constraints = list(function(x) {x$a > 0}))
#' # works just like a normal data.frame
#' print(foo)
#' summary(foo)
#' # errors
#' try(foo$a <- as.character(foo$a))
#' try(foo["a", 1] <- -1)
#' try(foo$a <- NULL)
#' # errors
#' try(foo$b <- as.character(foo$b))
#' try(foo$d <- runif(3))
psData <-
  setClass("psData", contains="data.frame",
           representation(columns="character",
                          exclusive="logical",
                          constraints="FunctionList",
                          design="CharacterList",
                          meta="CharacterList"),
           prototype(data.frame(),
                     columns=character(),
                     exclusive=FALSE,
                     constraints=FunctionList(),
                     design = CharacterList(),
                     meta = CharacterList()),
           validity = function(object) {
             rc <- validate_data_frame(object, columns = object@columns,
                                        exclusive=object@exclusive,
                                        constraints = object@constraints,
                                        design = object@design)
             if (is.character(rc)) {
               return(rc)
               }
             TRUE
             })

setMethod("initialize", "psData",
          function(.Object,
                   x=new_data_frame(columns), columns=character(),
                   exclusive=FALSE, constraints=list(), design=list(), meta=list()) {
              ## Drop any bad columns if exclusive
            if (exclusive) {
              coltouse <- intersect(names(x), names(columns))
              x <- as.data.frame(x)[ , coltouse, drop=FALSE]
            }
            .Object <- callNextMethod(.Object, x)
            .Object@columns <- columns
            .Object@exclusive <- exclusive
            .Object@constraints <- FunctionList(constraints)
            .Object@design <- CharacterList(design)
            .Object@meta <- CharacterList(meta)
            validObject(.Object)
            .Object
          })

setGeneric("design", function(object, ...) standardGeneric("design"))
setMethod("design", "psData", function(object) { object@design })

setGeneric("meta", function(object, ...) standardGeneric("meta"))
setMethod("meta", "psData", 
          function(object) { 
            cat(ifelse(object@meta$name == "", "", paste0(object@meta$name, "\n")),
                "Panel data frame [", 
                nrow(object), "rows x ", ncol(object), "columns]\n\n",
                mapply(function(x, y) cat(sprintf("$ %s: %s\n", x, y)),
                       names(object@design), object@design))
            
            object@meta })

# basic show method will display primary panel and time attributes
# use design() method to get all panel attributes
setMethod("show", "psData",
          function(object) {
            cat(ifelse(object@meta$name == "", "", paste0(object@meta$name, "\n")),
                "Panel data frame [", 
                nrow(object), "rows x ", ncol(object), "columns,",
                length(unique(object[, object@design$panel ])), 
                object@design$panel[1], 
                "x", 
                length(unique(object[, object@design$time ])), 
                object@design$time[1], "]\n\n")
            print(head(as(object, "data.frame")))
            if(length(object@columns) > 0) {
              cat("Required columns:\n")
              mapply(function(x, y) cat(sprintf("$ %s: %s\n", x, y)),
                     names(object@columns), object@columns)
            }
            if(length(object@constraints) > 0) {
              cat("Constraints:\n")
              show(object@constraints)
            }
            if(length(object@meta) > 0)
              cat("\nSource:", 
                  paste0(object@meta$author, collapse = ", "),
                  object@meta$version, object@meta$date, "\n", 
                  object@meta$url)
          })

###Methods

# [-method
setMethod("[", c(x="psData", i="missing", j="missing"),
          function(x, i, j, drop=TRUE) {
            if (drop && ncol(x) == 1) {
              x[[1]]
            } else {
              x
            }
          })

setMethod("[", c(x="psData", i = "missing", j = "ANY"), 
          function(x, i, j, drop=TRUE) {
            y <- data.frame(x)[ , j, drop=drop]
            tryCatch(new("psData", y, x@columns, x@exclusive, x@constraints, x@design, x@meta),
                     error = function(e) y)
          })

setMethod("[", c(x="psData", i = "ANY", j = "missing"), 
          function(x, i, j, drop = TRUE) {
            y <- as(x, "data.frame")[i, , drop=drop]
            tryCatch(new("psData", y, x@columns, x@exclusive, x@constraints, x@design, x@meta),
                     error = function(e) y)
          })

setMethod("[", c(x="psData", i = "ANY", j = "ANY"), 
          function(x, i, j, drop = TRUE) {
            y <- as(x, "data.frame")[i, j, drop=drop]
            tryCatch(new("psData", y, x@columns, x@exclusive, x@constraints, x@design, x@meta),
                     error = function(e) y)
          })


# [<- method

setMethod("[<-", c(x="psData", i="missing", j="missing"),
          function(x, i, j, value) {
            y <- callGeneric(data.frame(x), , ,value=value)
            new("psData", y,  x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

setMethod("[<-", c(x="psData", i="missing", j="ANY"),
          function(x, i, j, value) {
            y <- callGeneric(data.frame(x), , j,value=value)
            new("psData", y,  x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

setMethod("[<-", c(x="psData", i="ANY", j="missing"),
          function(x, i, j, value) {
            y <- callGeneric(data.frame(x), i, ,value=value)
            new("psData", y,  x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

setMethod("[<-", c(x="psData", i="ANY", j="ANY"),
          function(x, i, j, value) {
            y <- callGeneric(data.frame(x), i, j,value=value)
            new("psData", y,  x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })


# [[<- method

setMethod("[[<-", c(x="psData", i="ANY", j="missing", value="ANY"),
          function(x, i, j, value) {
            y <- callGeneric(data.frame(x), i, value=value)
            new("psData", y, x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

setMethod("[[<-", c(x="psData", i="ANY", j="ANY", value="ANY"),
          function(x, i, j, value) {
            y <- callGeneric(data.frame(x), i, j, value=value)
            new("psData", y, x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

# $<- method
setMethod("$<-", "psData",
          function(x, name, value) {
            y <- callNextMethod()
            new("psData", y, x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

# rbind2 method
setMethod("rbind2", "psData",
          function(x, y, ...) {
            z <- rbind(as(x, "data.frame"), as(y, "data.frame"), ...)
            new("psData", z, x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

# cbind2 method
setMethod("cbind2", "psData",
          function(x, y, ...) {
            z <- cbind(as(x, "data.frame"), as(y, "data.frame"), ...)
            new("psData", z, x@columns, x@exclusive, x@constraints, x@design, x@meta)
          })

# colnames<-
setMethod("colnames<-", "psData",
          function(x, value) {
            y <- callNextMethod()
            validObject(y)
            y
          })

# rownames<-
setMethod("rownames<-", c(x = "psData", value = "ANY"),
          function(x, value) {
            y <- callNextMethod()
            validObject(y)
            y
          })

setMethod("rownames<-", c(x = "psData", value = "NULL"),
          function(x, value) {
            x@row.names <- seq_len(nrow(x))
            validObject(x)
            x
          })

# names<-
setMethod("names<-", "psData",
          function(x, value) {
            y <- callNextMethod()
            validObject(y)
            y
          })


# names<-
setMethod("dimnames<-", c(x="psData", value="list"),
          function(x, value) {
            rownames(x) <- value[[1]]
            colnames(x) <- value[[2]]
            validObject(x)
            x
          })

# setGeneric("foo", function(x, y, ...) standardGeneric("foo"))
# setMethod("foo", c( x = "psData", y = "psData" ),
#           function(x, y, ...) {
#             message("hello")
#             if( !identical( x@design$format[1], y@design$format[1] ) ){
#               stop(sprintf("incompatible panel units, cannot merge '%s' and '%s'",
#                            x@design$format[1], y@design$format[1]))
#             }
#             if( !identical( x@design$date[1], y@design$date[1] ) ){
#               stop(sprintf("incompatible panel units, cannot merge '%s' and '%s'",
#                            x@design$date[1], y@design$date[1]))
#             }
#             merge(data.frame(x), data.frame(y), 
#                   by.x = c(x@design$panel[1], x@design$time[1]),
#                   by.y = c(y@design$panel[1], y@design$time[1]), ...)
#           })

setMethod("merge", c("psData", "psData"), function(x, y, ...) {
  head(merge(as.data.frame(x), as.data.frame(y), ...))
})
setMethod("merge", c("data.frame", "psData"), function(x, y, ...) {
  head(merge(x, as.data.frame(y), ...))
})
setMethod("merge", c("psData", "data.frame"), function(x, y, ...) {
  head(merge(as.data.frame(x), y, ...))
})

#' as.psData
#'
#' Converts a data frame to \code{\link{class-psData}} by adding two
#' lists of attributes to the data:
#' \itemize{
#'   \item \code{design}. define panel attributes like country 
#'   codes and time units
#'   \item \code{meta}. define a minimal set of references to
#'   describe the data (optional)
#' }
#' @details
#' The \code{class-psData} also optionally supports all methods from the
#' \code{DataFrameConstr} package:
#' \itemize{
#'   \item \code{columns}. protect the classes of selected columns, 
#'   as in \code{columns = c(a = "numeric", b = "ANY", c = "factor")}
#'   \item \code{constraints}. force selected variables to follow logical conditions,
#'   as in \code{constraints = list(function(x) { x$a > 0 }}
#'   \item \code{exclusive}. protect the number of rows (\code{FALSE} by default)
#' }
#' @name as.psData
#' @param data
#' @references \code{DataFrameConstr}, by Jeffrey Arnold: 
#' \url{https://github.com/jrnold/DataFrameConstr}
#' @seealso \code{\link{as.panel}}
#' @examples
#' # Load Reinhart and Rogoff demo data.
#' data(debt)
#' # Add full panel details and metadata.
#' debt = as.psData(debt,
#'           design = list(
#'             # data design
#'             panel = c("Country"),
#'             format = c(Country = "name"),
#'             time = c("Year"),
#'             date = c(Year = "%Y")
#'           ),
#'           meta = list(
#'             # descriptive
#'             name = "Reinhart and Rogoff data, edited from Herndon et al.'s script.",
#'             # similar to R packages
#'             author = "Cosma Shalizi",
#'             # versioning
#'             date = "2013-04-29", 
#'             version = "",
#'             url = "http://www.stat.cmu.edu/~cshalizi/uADA/13/hw/11/debt.csv"
#'           ))
#' # Standard data frame.
#' head(data.frame(debt))
#' # psData data frame.
#' debt
#' @export
as.psData = function(data, design, meta = list(), ...) {

  stopifnot(c("panel", "format", "time", "date") %in% names(design))

  data = psData(data, design = design, meta = meta, ...)

  return(data)

}

#' Verify the data are in \code{\link{psData}} format
#'
is.psData = function(x) inherits(x, "psData")

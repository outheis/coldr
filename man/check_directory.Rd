% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/wrappers.r
\name{check_directory}
\alias{check_directory}
\title{check a directory}
\usage{
check_directory(path, pattern = "\\\\.[rR]$", recursive = FALSE, ...)
}
\arguments{
\item{path}{A path to a directory to be checked, e.g. "R/".}

\item{pattern}{A pattern to search files with, see \code{\link{list.files}}.}

\item{recursive}{Search the directory recursively?
See \code{\link{list.files}}.}

\item{...}{Arguments to be passed to \code{\link{check_file}}.}
}
\value{
invisible(TRUE), but see \emph{Details}.
}
\description{
run all \code{\link{check_file}} on the files in a directory.
}
\details{
The functions catches the messages of 'coldr'-conditions \code{\link{throw}}n
by \code{\link{check_file}} and, if it caught any, \code{\link{throw}}s them.
}
\section{Version}{
 $Id: 01015ff091d53e47fc1caa95805585b6e3911ba5 $
}
\examples{
# load internal functions first.
load_internal_functions('coldr')
print(check_directory(system.file('source', 'R', package = 'coldr'),
                      max_arguments = 6, max_width = 90))
}
\author{
Dominik Cullmann, <dominik.cullmann@forst.bwl.de>
}


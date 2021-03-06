% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/wrappers.r
\name{check_file}
\alias{check_file}
\title{check a file}
\usage{
check_file(path, ...)
}
\arguments{
\item{path}{The path to file, e.g. "checks.r".}

\item{...}{Arguments to be passed to \code{\link{check_functions_in_file}} or
\code{\link{check_file_layout}}.}
}
\value{
invisible(TRUE), but see \emph{Details}.
}
\description{
run all \code{\link{check_functions_in_file}} and
\code{\link{check_file_layout}} on a file.
}
\details{
The function catches the messages of 'coldr'-conditions \code{\link{throw}}n
by \code{\link{check_functions_in_file}} and \code{\link{check_file_layout}}
and, if it
caught any, \code{\link{throw}}s them.
}
\section{Version}{
 $Id: 01015ff091d53e47fc1caa95805585b6e3911ba5 $
}
\examples{
print(check_file(system.file('source', 'R', 'utils.r',
                                     package = 'coldr')))
}
\author{
Dominik Cullmann, <dominik.cullmann@forst.bwl.de>
}


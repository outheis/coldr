#' function checks
#'
#' A set of tiny functions to check that functions adhere to a layout style.
#'
#' A function should have a clear layout, it should
#' \itemize{
#'   \item not have too many arguments,
#'   \item not have nestings too deep,
#'   \item neither have too many lines nor
#'   \item have too many lines of code,
#'   \item not have lines too wide and
#'   \item explicitly \code{\link{return}} an object.
#' }
#' At least this is what I think. Well, some others too.
#'
#' All of the functions test whether their requirement is met (some layout
#' feature such as number of arguments, nesting depth, line width is not greater
#' than the maximum given). In case of a fail all \code{\link{throw}} a
#' condition of class c('coldr', 'error', 'condition').
#'
#' @section Warning: \code{\link{check_return}} just \code{\link{grep}}s for a
#' for a line starting with a \code{\link{return}} statemtent (ah, see the code
#' for the real thing).
#' This doesn't ensure that \emph{all} \code{\link{return}} paths from the
#' function are explicit and it may miss a \code{\link{return}} path after a
#' semicolon.
#' It just checks if you use \code{\link{return}} at all.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 01015ff091d53e47fc1caa95805585b6e3911ba5 $
#' @param object The function to be checked.
#' Should have been sourced with keep.source = TRUE (see
#' \code{\link{get_function_body}}.
#' @param maximum The maximum against which the function is to be tested.
#' @return invisible(TRUE), but see \emph{Details}.
#' @name function_checks
#' @examples 
#' print(check_num_arguments(check_num_arguments))
#' print(check_nesting_depth(check_nesting_depth))
#' print(check_num_lines(check_num_lines))
#' print(check_num_lines_of_code(check_num_lines_of_code))
#' print(check_return(check_return))
#' # R reformats functions on import (see 
#' # help(get_function_body, package = 'coldr')), so we need 90 characters:
#' print(check_line_width(check_line_width, maximum = 90))
NULL


#' @rdname function_checks
check_num_arguments <- function(object,
                                maximum = get_coldr_options('max_arguments')) {
    qassert(object, 'f')
    qassert(maximum, 'N1')
    num_arguments <- length(formals(object))
    if (num_arguments > maximum)
        throw(paste('found', num_arguments, 'arguments, maximum was', maximum))
    return(invisible(TRUE))
}

#' @rdname function_checks
check_nesting_depth <- function(object,
                                maximum = get_coldr_options('max_nesting_depth')
                                ) {
    qassert(object, 'f')
    qassert(maximum, 'N1')
    function_body <- get_function_body(object)
    # break if no braces in function
    if (! any (grepl('}', function_body, fixed = TRUE))) return(invisible(TRUE))
    braces <- paste(gsub('\\', '',
                         gsub("[^\\{\\}]", "", function_body),
                         fixed = TRUE),
                    collapse = '')
    # the first (opening) brace is from the function definition,
    # so we skip it via substring
    consectutive_openings <- strsplit(substring(braces, 2), '}',
                                      fixed = TRUE)[[1]]
    nesting_depths <- nchar(consectutive_openings)
    nesting_depth <- max(nesting_depths)
    if (nesting_depth > maximum)
        throw(paste('found nesting depth ', nesting_depth, ', maximum was ',
                    maximum, sep = ''))
    return(invisible(TRUE))
}

#' @rdname function_checks
check_num_lines <- function(object,
                            maximum = get_coldr_options('max_lines')) {
    qassert(object, 'f')
    qassert(maximum, 'N1')
    function_body <- get_function_body(object)
    num_lines  <- length(function_body)
    if (num_lines > maximum)
        throw(paste('found', num_lines, 'lines, maximum was', maximum))
    return(invisible(TRUE))
}

#' @rdname function_checks
check_num_lines_of_code <- function(object,
                                    maximum =
                                    get_coldr_options('max_lines_of_code')) {
    qassert(object, 'f')
    qassert(maximum, 'N1')
    function_body <- get_function_body(object)
    line_is_comment_pattern <- '^\\s*#'
    lines_of_code <- grep(line_is_comment_pattern, function_body,
                          value = TRUE, invert = TRUE)
    num_lines_of_code <-  length(lines_of_code)
    if (num_lines_of_code > maximum)
        throw(paste('found', num_lines_of_code, 'lines of code, maximum was',
                    maximum))
    return(invisible(TRUE))
}

#' @rdname function_checks
check_line_width <- function(object,
                            maximum = get_coldr_options('max_line_width')) {
    qassert(object, 'f')
    qassert(maximum, 'N1')
    function_body <- get_function_body(object)
    line_widths <-  nchar(function_body)
    if (any(line_widths > maximum)) {
        long_lines_index <- line_widths > maximum
        long_lines <- seq(along = function_body)[long_lines_index]
        throw(paste('line ', long_lines, ': found width ',
                    line_widths[long_lines_index], ' maximum was ', maximum,
                    sep = '', collapse = '\n')
        )
    }
    return(invisible(TRUE))
}

#' @rdname function_checks
check_return <- function(object) {
    message_string <- paste('Just checking for a line starting with a return', 
                          'statement.\n  This is no check for all return paths',
                          'being explicit.')
    warning(message_string)
    qassert(object, 'f')
    function_body <- body(object)  # body gives us the statements line by line,
    # some_command;   return(somewhat) will be matched by '^\\s*return\\('
    if (! any(grepl('^\\s*return\\(', function_body)))
        throw('found no return() statement at all.')
    return(invisible(TRUE))
}

#' check a file's layout
#'
#' Check for number of lines and width of lines.
#'
#' Some reckon a code file should not be too long and that its lines should not
#' be too wide. On current monitors, 300 lines are about five pages.
#' A line width of 80 seems a bit \ldots{} outdated, but maybe there's some good
#' in it.
#'
#' In case of a fail the function \code{link{throw}}s a
#' condition of class c('coldr', 'error', 'condition').
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 01015ff091d53e47fc1caa95805585b6e3911ba5 $
#' @param path A path to a file, e.g. "checks.r".
#' @param max_length The maximum number of lines accepted.
#' @param max_width The maximum line width accepted.
#' @return invisible(TRUE), but see \emph{Details}.
#' @examples 
#' print(check_file_layout(system.file('source', 'R', 'checks.r', 
#'                                     package = 'coldr')))
check_file_layout <- function(path,
                              max_length = get_coldr_options('max_length'),
                              max_width = get_coldr_options('max_width')) {
    qassert(path, 'S1')
    qassert(max_length, 'N1')
    qassert(max_width, 'N1')
    file_content <- readLines(path)
    line_widths <-  nchar(file_content)
    num_lines <- length(file_content)
    if (num_lines > max_length) {
        throw(paste(path, ": ",
                         num_lines, " lines in file.",
                         sep = '' )
        )
    }
    if (any(line_widths > max_width)) {
        long_lines_index <- line_widths > max_width
        throw(paste(path, ": line ",
                         seq(along = file_content)[long_lines_index],
                         ' counts ', line_widths[long_lines_index],
                         ' characters.',
                         sep = '')
        )
    }
    return(invisible(TRUE))
}

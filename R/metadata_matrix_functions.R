# Functions for importing matrix-format metadata

# Functions were adapted from the plater package (https://github.com/ropensci/plater/), which was built to
# allow the joining of matrix-format metadata to tidy data.

# Plater was built to handle matrix format files. These functions have been adapted here to work with
# dataframe inputs.

##

# 1. Functions to guess plate size from matrix/plater format metadata ------------------

#' plate_dimensions2
#'
#' adapted from plater package. not edited.
#'
#' @noRd
plate_dimensions2 <- function(get, from, value){
  dimensions <- data.frame(Columns = c(3, 4, 6, 8, 12, 24, 48),
                           Rows = c(2, 3, 4, 6, 8, 16, 32),
                           PlateSize = c(6, 12, 24, 48, 96, 384, 1536))
  which_row <- which(dimensions[[from]] == value)
  dimensions[which_row, get]
}

#' get_plate_size_from_number_of_columns2
#'
#' adapted from plater package.
#'
#' @noRd
get_plate_size_from_number_of_columns2 <- function(columns){
  # n <- plate_dimensions("PlateSize", "Columns", columns)
  n <- plate_dimensions2("PlateSize", "Columns", columns)
  if (length(n) == 0) {
    stop(paste0("Could not guess plate size from number of columns. ",
                "Invalid number of columns: ", columns), call. = FALSE)
  }
  n
}

#' guess_plate_size2
#'
#' adapted from plater package.
#'
#' @noRd
guess_plate_size2 <- function(data){ # file, sep
  # first_line <- readr::read_lines(file, n = 1)
  first_line <- data[1,]
  # first_line_vector <- strsplit(first_line, sep)[[1]]
  # first_line_vector <- first_line_vector[-1]
  first_line_vector <- as.numeric(first_line[-1])
  number_of_columns <- max(as.numeric(first_line_vector))
  # get_plate_size_from_number_of_columns(number_of_columns)
  get_plate_size_from_number_of_columns2(number_of_columns)
}

# 2. Functions to extract each variable matrix from the starting dataframe ------------------

#' number_of_columns2
#'
#' adapted from plater package.
#'
#' @noRd
number_of_columns2 <- function(plate_size)
{
  # n <- plate_dimensions("Columns", "PlateSize", plate_size)
  n <- plate_dimensions2("Columns", "PlateSize", plate_size)
  if (length(n) == 0) {
    stop(paste0("Invalid plate_size: ", plate_size, ". Must be 6, 12, 24, 48, 96, 384, or 1536."),
         call. = FALSE)
  }
  n
}

#' calculate_number_of_plates2
#'
#' adapted from plater package. calculate number of variables in a matrix/plater format dataframe.
#'
#' @noRd
calculate_number_of_plates2 <- function(data, number_of_rows) # raw_file,
{
  is_integer <- function(x) x%%1 == 0
  # result <- (length(raw_file) + 1)/(number_of_rows + 2) # length raw file is number of rows in data
  result <- (nrow(data) + 1)/(number_of_rows + 2)
  if (is_integer(result)) {
    return(result)
  }
  # else {
  #   result <- (length(raw_file))/(number_of_rows + 2)
  #   if (raw_file[length(raw_file)] == "" || is_integer(result)) {
  #     return(result)
  #   } # think this only applies to files
  else {
    stop(paste0("File length is incorrect. Must be a multiple of the ",
                "number of rows in the plate plus a header row for each ",
                "plate and a blank row between plates."), call. = FALSE)
  }
  # }
}

#' get_list_of_plate_layouts2
#'
#' adapted from plater package. extract each variable matrix from the given dataframe and return them as a list.
#'
#' @noRd
get_list_of_plate_layouts2 <- function(data, plate_size) # file,
{
  # raw_file <- read_lines(file)
  # number_of_rows <- plater::number_of_rows(plate_size)
  number_of_rows <- plate_size/number_of_columns2(plate_size)
  number_of_rows
  # number_of_plates <- calculate_number_of_plates(raw_file, number_of_rows)
  number_of_plates <- calculate_number_of_plates2(data, number_of_rows)
  # raw_file_list <- lapply(1:number_of_plates, FUN = function(plate) { # for each 'plate' ie. variable, find first/last rows
  #   first_row <- (plate - 1) * (number_of_rows + 1) + plate
  #   last_row <- first_row + number_of_rows
  #   raw_file[first_row:last_row]
  # })
  # raw_file_list
  variable_list <- lapply(1:number_of_plates, FUN = function(plate) { # for each 'plate' ie. variable, find first/last rows
    first_row <- (plate - 1) * (number_of_rows + 1) + plate
    last_row <- first_row + number_of_rows
    data[first_row:last_row,] # data is df not list of lines. df[x:y] specifies columns, whereas df[x:y,] specifies rows.
  }) # just renamed "raw_file_list" to "variable_list" and "raw_file" to "data"
  variable_list
}

# 3. Convert layouts (turn each 'plate' into a column) ------------------

#' get_well_ids2
#'
#' adapted from plater package. given a plate size, return vector of wells in "A1 .. H12" format.
#'
#' @noRd
get_well_ids2 <- function(plate_size)
{
  # cols <- number_of_columns(plate_size)
  cols <- number_of_columns2(plate_size)
  # rows <- number_of_rows(plate_size)
  rows <- plate_size/number_of_columns2(plate_size)

  MEGALETTERS <- function(x){ c(LETTERS[1:26], paste0("A", LETTERS[1:26]))[x] }
  # MEGALETTERS(1:8) # test # "A" "B" "C" "D" "E" "F" "G" "H"

  # format: "A01"
  # wells <- vapply(formatC(1:cols, width = 2, flag = "0"),
  #                 FUN = function(i) paste(MEGALETTERS(1:rows), i, sep = ""),
  #                 FUN.VALUE = rep("character", rows))

  # format: "A1"
  wells <- vapply(formatC(1:cols),
                  FUN = function(i) paste(MEGALETTERS(1:rows), i, sep = ""),
                  FUN.VALUE = rep("character", rows))

  wells <- as.vector(t(wells))
  return(wells)
}

#' convert_plate_to_column2
#'
#' adapted from plater package. convert a given variable from matrix/plater format to tidy format and output a 2-column dataframes, where the first column is the well column, and the second is the variable.
#'
#' @noRd
convert_plate_to_column2 <- function(plate, plate_size) # plate should be df #, sep
{
  # plate <- plate_text_to_data_frame(plate, sep)
  column_name <- plate[1, 1] # take top left cell as colname of tidy column
  if (is.na(column_name)) {
    column_name <- "values"
  }
  plate <- plate[-1, ] # remove top row w well column numbers

  # validate_plate(plate, plate_size) # skip validate for now
  # if (!are_plate_dimensions_valid(plate, plate_size)) {
  #   stop(paste0("Invalid plate dimensions. Found ", nrow(plate),
  #               " rows and ", ncol(plate) - 1, " columns. Must be (",
  #               number_of_rows(plate_size), ", ", number_of_columns(plate_size),
  #               ") for a ", plate_size, "-well plate."), call. = FALSE)
  # }
  # if (!are_row_labels_valid(plate, plate_size)) {
  #   stop(wrong_row_labels_error_message(plate, plate_size))
  # }

  plate <- plate[-1] # remove first column w well row letters
  rows <- nrow(plate)
  cols <- ncol(plate)
  plate <- unlist(lapply(seq_len(nrow(plate)), function(i) unname(plate[i,])))
  # wells <- get_well_ids(rows * cols)
  wells <- get_well_ids2(rows * cols)
  wells
  df <- data.frame(wellIds = wells, stringsAsFactors = FALSE,
                   # ColumnName = utils::type.convert(plate, as.is = TRUE))
                   new_column = utils::type.convert(plate, as.is = TRUE)) # rename new column
  df

  ## select non-well column for returning & remove NAs
  # names(df) <- c("wellIds", column_name) # redundant
  # column <- colnames(df)[colnames(df) != "wellIds"] # redundant
  # df <- df[!(is.na(df[, column])), ] # error
  # df <- df[!is.na(df["ColumnName"]), ]
  # df <- df %>%
  #   tidyr::drop_na(new_column) %>%
  #   dplyr::filter(new_column != "") # drop rows where new column is empty # sometimes necessary
  # df

  ## convert empty cells into NA
  df <- df %>%
    dplyr::mutate(new_column = ifelse(new_column == "", NA, new_column)) # if empty, replace w NA, otherwise leave as is
  df

  # rename column2
  colnames(df) <- c("wellIds", column_name)

  return(df)
}

#' convert_all_layouts2
#'
#' adapted from plater package. given a list of variable matrices in matrix/plater format, convert each to tidy format and output a list of 2-column dataframes, where the first column is the well column, and the second is the variable.
#'
#' @noRd
convert_all_layouts2 <- function(variable_list, plate_size) # raw_file_list, # sep
{
  # convert <- function(f, layout_number) {
  #   tryCatch(expr = convert_plate_to_column2(f, plate_size, sep),
  #            error = function(e) {
  #              e <- paste0("Error in layout #", layout_number,
  #                          ": ", e$message)
  #              stop(e, call. = FALSE)
  #            })
  # }
  # simplify for now
  convert <- function(f, layout_number) {
    convert_plate_to_column2(plate = f, plate_size = plate_size)
  }

  # Map(f = convert, raw_file_list, 1:length(raw_file_list))
  Map(f = convert, # function to map
      variable_list, # vector to map function across
      1:length(variable_list) # 2nd arg of the function: the layout number
  ) # Map applies a function to the corresponding elements of given vectors
}

# 4. Functions to convert extracted data to tidy format ------------------

#' check_unique_plate_names2
#'
#' adapted from plater package. not edited.
#'
#' @noRd
check_unique_plate_names2 <- function(result){
  plate_names <- vapply(result, FUN = function(x) colnames(x)[2], FUN.VALUE = "character")
  if (any(duplicated(plate_names))) {
    duplicates <- which(duplicated(plate_names))
    result <- lapply(1:length(result), FUN = function(n) {
      if (n %in% duplicates) {
        new_name <- paste0(colnames(result[[n]])[2], ".", n)
        colnames(result[[n]])[2] <- new_name
        result[[n]]
      }
      else {
        result[[n]]
      }
    })
  }
  return(result)
}

#' combine_list_to_dataframe2
#'
#' adapted from plater package. given a list of tidy 2-column dataframes for each variable, merge these to create a tidy multi-column dataframe.
#'
#' @noRd
combine_list_to_dataframe2 <- function(list_of_tidy_cols, plate_size){ # result,

  if (length(list_of_tidy_cols) == 1) {
    list_of_tidy_cols <- list_of_tidy_cols[[1]]
  }
  else {
    # result <- check_unique_plate_names(result)
    list_of_tidy_cols <- check_unique_plate_names2(list_of_tidy_cols)
    result <- Reduce(function(x, y) merge(x, y, by = "wellIds", all = TRUE), list_of_tidy_cols)
  }

  # ## remove rows where all values are NA
  # keep <- rowSums(!is.na(result)) > 1
  # result <- result[keep, ]

  ## order by well
  # sort_by_well_ids(result, "wellIds", plate_size)
  sort_by_well_ids2 <- function(data, well_ids_column, plate_size){
    data[order(match(data[[well_ids_column]], get_well_ids2(plate_size))), , drop = FALSE]
  }
  result <- sort_by_well_ids2(data = result, well_ids_column = "wellIds", plate_size = plate_size)
  result
}

# 5. Function to wrap the above ------------------

#' read_matrixformat_metadata
#'
#' adapted from plater package. function renamed from read_plate to read_plate2
#' to read_matrixformat_metadata. given a dataframe in matrix/plater format,
#' extract all variables and convert these to tidy format, returning a tidy
#' dataframe.
#'
#' @noRd
read_matrixformat_metadata <- function(data, well_ids_column = "well"){ # file, well_ids_column = "Wells", # sep = ","

  ## unneeded functions for file inputs
  # check_that_only_one_file_is_provided(file)
  # check_file_path(file)
  # check_that_file_is_non_empty(file)
  # check_well_ids_column_name(well_ids_column)

  ## what is the plate size? eg 96-well plate.
  # plate_size <- guess_plate_size(file, sep)
  plate_size <- guess_plate_size2(data)

  ## how many variables / "plates"/matrices are there in the data?
  # raw_file_list <- get_list_of_plate_layouts(file, plate_size)
  variable_list <- get_list_of_plate_layouts2(data = data, plate_size = plate_size)

  ## convert each variable/plate/matrix into a 2-col df with 'well' and the variable
  # result <- convert_all_layouts(raw_file_list, plate_size, sep)
  list_of_tidy_cols <- convert_all_layouts2(variable_list = variable_list, plate_size = plate_size)

  ## combine into 1 df
  # result <- combine_list_to_dataframe(result, plate_size)
  result <- combine_list_to_dataframe2(list_of_tidy_cols = list_of_tidy_cols, plate_size = plate_size)

  ## rename well column if appropriate
  colnames(result)[colnames(result) == "wellIds"] <- well_ids_column
  class(result) <- c("tbl_df", "tbl", "data.frame")

  result
}


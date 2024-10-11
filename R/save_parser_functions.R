#' check_parser_complete
#'
#' Checks if parser function is complete, with all parameters required.
#'
#' @noRd
check_parser_complete <- function(parser_parameters){

  # updated 2024.09
  required_contents = c("datatype", "dataformat",
                        "channel_name_specification", "channel_number", "channel_names", # "channel_name_indices" can be NULL
                        # "matrixformat", "firstchanneldata", # can be NULL
                        "row_beg", "row_end", "col_beg", "col_end", # [] consider shrinking to 4part list
                        "channeldataspacing", # even spacing only # not used for calcs # used for printing feedback to users for all datatypes
                        "channeldata_indices", # uneven spacing
                        "well_data_specification", "used_wells", # "well_data_indices" can be NULL

                        # spectrum only
                        "wav_min", "wav_max", "wav_interval",
                        # timecourse only
                        "timecourse_specification", "timepoint_number", "list_of_timepoints" # "timecourse_indices" can be NULL
  )

  ## check parser has been uploaded
  if(is.null(parser_parameters$datatype)){
    # parser has never been specified OR it has been reset
    message("Error: Parser missing. Upload a saved parser or build one before proceeding.")
    showModal(modalDialog(title = "Error", "Parser missing. Upload a saved parser or build one before proceeding.",
                          easyClose = TRUE ))
    error_detected <- TRUE
    return(error_detected)
  }

  if(parser_parameters$datatype == "datatype_standard"){
    # no spectrum
    required_contents <- stringr::str_subset(string = required_contents, pattern = "wav", negate = TRUE)
    # no timecourse
    required_contents <- stringr::str_subset(string = required_contents, pattern = "time", negate = TRUE)
  }
  if(parser_parameters$datatype == "datatype_spectrum"){
    # no timecourse
    required_contents <- stringr::str_subset(string = required_contents, pattern = "time", negate = TRUE)
  }
  if(parser_parameters$datatype == "datatype_timecourse"){
    # no spectrum
    required_contents <- stringr::str_subset(string = required_contents, pattern = "wav", negate = TRUE)
  }

  ## check all reqd parameters are in parameters list
  result <- all(sapply(required_contents, function(x) x %in% names(parser_parameters)))
  result
  if(isFALSE(result)){
    message("Error: Parser incomplete. If the parser was not created with a recent version of Parsley, remake the parser.")
    showModal(modalDialog(title = "Error", "Parser incomplete.
                          If the parser was not created with a recent version of Parsley, remake the parser.",
                          easyClose = TRUE ))
    error_detected <- TRUE
    return(error_detected)
  }

  ## check all reqd parameters are not NULL

  # uneven spacing - channeldataspacing can be NULL:
  required_contents <- required_contents[!stringr::str_detect(unlist(required_contents), "channeldataspacing")] # can be NULL

  # v2
  # distinction between names of list (eg "datatype") and their values "datatype_standard"
  for(element in names(parser_parameters)){ # for each parameter NAME
    if(any(grepl(element, required_contents))){
      # if the parameter NAME is in the required params...
      # check the parameter VALUE is not NULL
      print(element)
      if(is.null(unlist(parser_parameters[element]))){
        warning <- TRUE
        print("warning")
      }
    }
    # if the parameter is not in required params, skip check
  }

  # if any required params are NULL, throw warning
  if(isTRUE(warning)){
    message("Warning: Uploaded parser  may be incomplete. If you experience issues with parsing, remake the parser.")
    showModal(modalDialog(title = "Warning", "Uploaded parser  may be incomplete.
                          If you experience issues with parsing, remake the parser.",
                          easyClose = TRUE ))
  }

}


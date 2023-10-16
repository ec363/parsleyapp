#' app_server
#'
#' server function
#'
#' @param input,output,session internal parameters for shiny
#' @import shiny
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @noRd

# server -------------------------------------------------------------------------------------

app_server <- function(input, output, session) { # shiny as package function
# server <- function(input, output, session) {

  # To prevent RStudio crash on app closure
  session$onSessionEnded(function() {
    stopApp()
  })

  # Text ------

  addResourcePath(prefix = "www", directoryPath = system.file("www", package = "parsleyapp")) ###

  # About
  # about_text <- readLines("about.md")
  about_text_path <- system.file("md/about.md", package = "parsleyapp") ###
  about_text <- readLines(about_text_path)
  output$about_text <- renderUI({
    markdown(about_text)
  })

  # aboutcontents_text <- readLines("aboutcontents.md")
  aboutcontents_text_path <- system.file("md/aboutcontents.md", package = "parsleyapp") ###
  aboutcontents_text <- readLines(aboutcontents_text_path)
  output$aboutcontents_text <- renderUI({
    markdown(aboutcontents_text)
  })

  # Guide
  # guide_text <- readLines("guide.md")
  guide_text_path <- system.file("md/guide.md", package = "parsleyapp") ###
  guide_text <- readLines(guide_text_path)
  output$guide_text <- renderUI({
    markdown(guide_text)
  })

  # guidecontents_text <- readLines("guidecontents.md")
  guidecontents_text_path <- system.file("md/guidecontents.md", package = "parsleyapp") ###
  guidecontents_text <- readLines(guidecontents_text_path)
  output$guidecontents_text <- renderUI({
    markdown(guidecontents_text)
  })

  # Demos
  # examplesdemos_text <- readLines("examplesdemos.md")
  examplesdemos_text_path <- system.file("md/examplesdemos.md", package = "parsleyapp") ###
  examplesdemos_text <- readLines(examplesdemos_text_path)
  output$examplesdemos_text <- renderUI({
    markdown(examplesdemos_text)
  })

  # examplesdemos_contents_text <- readLines("examplesdemos_contents.md")
  examplesdemos_contents_text_path <- system.file("md/examplesdemos_contents.md", package = "parsleyapp") ###
  examplesdemos_contents_text <- readLines(examplesdemos_contents_text_path)
  output$examplesdemos_contents_text <- renderUI({
    markdown(examplesdemos_contents_text)
  })

  # Troubleshooting
  # help_text <- readLines("help.md")
  help_text_path <- system.file("md/help.md", package = "parsleyapp") ###
  help_text <- readLines(help_text_path)
  output$help_text <- renderUI({
    markdown(help_text)
  })

  # helpcontents_text <- readLines("helpcontents.md")
  helpcontents_text_path <- system.file("md/helpcontents.md", package = "parsleyapp") ###
  helpcontents_text <- readLines(helpcontents_text_path)
  output$helpcontents_text <- renderUI({
    markdown(helpcontents_text)
  })

  # News
  # news_text <- readLines("news.md")
  news_text_path <- system.file("md/news.md", package = "parsleyapp") ###
  news_text <- readLines(news_text_path)
  output$news_text <- renderUI({
    markdown(news_text)
  })

  # newscontents_text <- readLines("newscontents.md")
  newscontents_text_path <- system.file("md/newscontents.md", package = "parsleyapp") ###
  newscontents_text <- readLines(newscontents_text_path)
  output$newscontents_text <- renderUI({
    markdown(newscontents_text)
  })

  # DATAFRAME: New data objects as reactiveValues() and observeEvent()s ----

  ## Note on notation: df_shiny$data is equivalent to df_shiny[["data"]] - like subsetting a list. Same with inputs.
  ## Details: reconfiguring df_shiny as reactiveValues(data = NULL) and using observeEvent(condition, df_shiny$data = something) to update it each time
  # instead of having the whole df_shiny dataframe as one big reactive object.
  # Should work nicer because parts of it can then be updated without updating the whole thing.
  df_shiny <- reactiveValues(

    # 1. alldata is all data
    alldata = NULL,

    # 3. totaldata is sum total of all cells in alldata that represents numerical data (rather than empty space/metadata)
    totaldata = NULL,

    # 4. metadata is plate layout
    metadata = NULL,
    metadata_skip = FALSE, ### meta

    # 5. parsed data
    parseddata = NULL

  )

  # LOADING DATA ----

  ## Be careful with observeEvent: it just looks for input$something EXISTING, not its value.
  # So instead of observeEvent(input$something==1, {}), use: observeEvent(input$something, {}) and it will trigger every time input$something changes.
  # eg. input$action_button starts off with value 0 and then increases by 1 (and triggers event) every time it is pressed.
  # Note that the observeEvent expression in {} is called using isolate().

  # Input 1: Load example data ----
  observeEvent(input$submit_exampledata_button, { # whenever (and only when) submit button is pressed, df_shiny$alldata is updated to exampledata

    # Show only Raw data tab
    hideTab(inputId = "byop_mainpaneldata_tabset", target = "dataspecs_tab")
    hideTab(inputId = "byop_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "byop_mainpaneldata_tabset", target = "parseddata_tab")

    # Hide metadata - unless it already exists
    if(is.null(df_shiny$metadata)){
      hideTab(inputId = "byop_mainpaneldata_tabset", target = "metadata_tab")
    }

    withProgress(message = 'Loading data...', value = 0, {

      # RESET
      # Update ReactiveValues
      # some of this is redundant, but best to be thorough
      # when you press submit, you are expecting data to be overwritten - the user expects a clear and resubmit. so clear all first:
      # 1. Reset all data
      df_shiny$alldata = NULL
      # 3. Reset first channel data # moved to df_dataspecs
      # df_shiny$firstchanneldata = NULL
      # 3. Reset total data
      df_shiny$totaldata = NULL
      # 4. Reset parsed data
      df_shiny$parseddata = NULL
      # Reset others
      # [] Data Specs values?

      # LOAD
      # 1. Update all data
      filepathtouse <- system.file("extdata", paste0(input$select_exampledata, ".csv"), package = "parsleyapp") ###
      df_shiny$alldata <- utils::read.csv(filepathtouse, header = FALSE)
      # print(names(df_shiny$alldata)) # check # (notation is df_shiny$alldata, not df_shiny$alldata().)

    }) # end withprogress

    # Show Raw data Tab
    showTab(inputId = "byop_mainpaneldata_tabset", target = "rawdata_tab", select = TRUE)

  })
  # Input 1: Reset
  observeEvent(input$reset_exampledata_button, {

    withProgress(message = 'Clearing data...', value = 0, {
      # 1. Reset all data
      df_shiny$alldata = NULL
      # 3. Reset first channel data # moved to df_dataspecs
      # df_shiny$firstchanneldata = NULL
      # 3. Reset total data
      df_shiny$totaldata = NULL
      # 4. Reset parsed data
      df_shiny$parseddata = NULL
      # Reset others
      # [] Data Specs values?

    }) # end withprogress

    # Show Raw data Tab
    showTab(inputId = "byop_mainpaneldata_tabset", target = "rawdata_tab", select = TRUE)

  })

  # Input 2: Upload one CSV file ----
  observeEvent(input$submit_datafile_button, { # whenever submit button is pressed, df_shiny$alldata is updated

    # Show only Raw data tab
    hideTab(inputId = "byop_mainpaneldata_tabset", target = "dataspecs_tab")
    hideTab(inputId = "byop_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "byop_mainpaneldata_tabset", target = "parseddata_tab")

    # Hide metadata - unless it already exists
    if(is.null(df_shiny$metadata)){
      hideTab(inputId = "byop_mainpaneldata_tabset", target = "metadata_tab")
    }

    withProgress(message = 'Loading data...', value = 0, {

      # Missing files:
      if (is.null(input$upload_data)) {
        # Error handling: stop
        req(!is.null(input$upload_data))
      }

      # RESET
      # 1. Reset all data
      df_shiny$alldata = NULL
      # 3. Reset first channel data # moved to df_dataspecs
      # df_shiny$firstchanneldata = NULL
      # 3. Reset total data
      df_shiny$totaldata = NULL
      # 4. Reset parsed data
      df_shiny$parseddata = NULL
      # Reset others
      # [] Data Specs values?

      # LOAD:

      # v1 ### fileinput
      # # Which file to upload
      # file_in <- input$upload_data # the fileInput file selection device for Uploading one file was named "upload_data"
      # # print(file_in) # check
      # # print(file_in$datapath) # check
      #
      # # Do the upload
      #
      # # Reading the file:
      # isolate({
      #
      #   # Error handling when you try and upload the wrong file type: # 1. trycatch catches error
      #   tryCatch({
      #
      #     if(input$upload_data_delim == ","){ ### delim
      #
      #       # read.csv
      #       data <- utils::read.csv(file_in$datapath, header = FALSE) ###
      #       # print(head(data)) # check
      #
      #     } ### delim
      #
      #     if(input$upload_data_delim != ","){ ### delim
      #
      #       # read.table
      #       data <- utils::read.table(file_in$datapath, header = FALSE,
      #                                 sep = input$upload_data_delim)
      #
      #     } ### delim
      #
      #   }, # end first {} block in tryCatch
      #   error = function(err) { message(err) },
      #   warning = function(warn) { message(warn) }
      #   ) # end tryCatch
      #   # Error handling when you try and upload the wrong file type: # 2. req() stops rest of function
      #   req(is.data.frame(data)) # read_delim produces tibbles. tibble::is_tibble(data) also works.
      #
      # }) # end isolate
      #
      # # LOAD
      # # 1. Update all data (# Update df_shiny with converted dataframe)
      # df_shiny$alldata <- data

      # # v2 fileinput of specific types # https://mastering-shiny.org/action-transfer.html#uploading-data ### fileinput
      # # only upload data if extension is valid
      # ext <- tools::file_ext(input$upload_data$name) ### fileinput
      # if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt")))){
      #
      #   if(input$upload_data_delim == ","){ ### delim
      #     data <- utils::read.csv(input$upload_data$datapath, header = FALSE) # read.csv
      #   }
      #   if(input$upload_data_delim != ","){ ### delim
      #     data <- utils::read.table(input$upload_data$datapath, header = FALSE, sep = input$upload_data_delim) # read.table
      #   }
      #
      #   # LOAD
      #   # 1. Update all data (# Update df_shiny with converted dataframe)
      #   df_shiny$alldata <- data
      #
      # } # only upload data if extension is valid

      # v3 fileinput of specific types, including excel ### fileinput ### excel
      # https://mastering-shiny.org/action-transfer.html#uploading-data ### fileinput
      # only upload data if extension is valid
      ext <- tools::file_ext(input$upload_data$name) ### fileinput
      if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt", "xls", "xlsx")))){

        data <- NULL

        if(grepl(pattern = ext, x = c("csv")) & input$upload_data_delim == ","){ ### delim
          data <- utils::read.csv(input$upload_data$datapath, header = FALSE) # read.csv
        }
        if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt"))) & (input$upload_data_delim == ";" | input$upload_data_delim == "\t")){ ### delim
          data <- utils::read.table(input$upload_data$datapath, header = FALSE, sep = input$upload_data_delim) # read.table
        }
        if(any(grepl(pattern = ext, x = c("xls", "xlsx"))) & input$upload_data_delim == "excel"){ ### excel
          data <- readxl::read_excel(input$upload_data$datapath, col_names = FALSE)
          # first sheet (sheets = 1 would be equivalent)
          # col_names like "header" for readcsv, except colnames are "..1" etc, not "V1" etc.
        }

        if(!is.null(data)){ ### excel
          # LOAD
          # 1. Update all data (# Update df_shiny with converted dataframe)
          df_shiny$alldata <- data
        } else {
          # if data doesn't exist, there must be a mix up between file extension and file type specified
          message("Error: Ensure that the specified file type matches uploaded file's extension.")
          showModal(modalDialog(title = "Error", "Ensure that the specified file type matches uploaded file's extension.",
                                easyClose = TRUE ))
        }

        # # LOAD
        # # 1. Update all data (# Update df_shiny with converted dataframe)
        # df_shiny$alldata <- data

      } else {

        # if extension is not on the list of permissible extensions, throw error ### excel
        message("Error: File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.")
        showModal(modalDialog(title = "Error", "File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.",
                              easyClose = TRUE ))

      } # only upload data if extension is valid

    }) # end withprogress

    # Show Raw data Tab
    showTab(inputId = "byop_mainpaneldata_tabset", target = "rawdata_tab", select = TRUE)

  })
  # Input 2: Reset
  observeEvent(input$reset_datafile_button, {

    withProgress(message = 'Clearing data...', value = 0, {

      ## RESET DATA DFS
      # 1. alldata to be reset
      df_shiny$alldata = NULL
      # 3. Reset first channel data # moved to df_dataspecs
      # df_shiny$firstchanneldata = NULL
      # 3. Reset total data
      df_shiny$totaldata = NULL
      # 4. Reset parsed data
      df_shiny$parseddata = NULL
      # Reset others
      # [] Data Specs values?

      ## RESET DATASPECS (copied from Reset All button Under Parse section 20221219)
      # NB. This doesn't actually affect how the Data Specs UI looks (preselected parts still there). Pointless?

      # Reset dataspecs
      # step1
      df_dataspecs$datatype = NULL
      df_dataspecs$dataformat = NULL
      # [] update checkbox button to even?
      # updateCheckboxInput(session, inputId = "step1_checkbox", value = FALSE) # uncheck checkbox (if it was marked complete before)

      # step2
      df_dataspecs$channel_number = NULL
      df_dataspecs$channel_names = NULL
      df_dataspecs$wav_min = NULL
      df_dataspecs$wav_max = NULL
      df_dataspecs$wav_interval = NULL
      # [] update checkbox button to even?

      # step2b
      df_dataspecs$timecourse_firsttimepoint = NULL
      df_dataspecs$timecourse_duration = NULL
      df_dataspecs$timecourse_interval = NULL
      df_dataspecs$timepoint_number_expected = NULL
      df_dataspecs$timepoint_number = NULL # worked out version
      df_dataspecs$list_of_timepoints = NULL

      # step3
      df_dataspecs$matrixformat = NULL
      df_dataspecs$firstchanneldata = NULL
      df_dataspecs$row_beg = NULL
      df_dataspecs$row_end = NULL
      df_dataspecs$col_beg = NULL
      df_dataspecs$col_end = NULL
      # [] update checkbox button to even?

      # step4
      df_dataspecs$channeldataspacing = NULL
      # [] update checkbox button to even?

      # step5
      df_dataspecs$starting_well = NULL
      df_dataspecs$readingorientation = NULL
      df_dataspecs$used_wells = NULL
      # [] update checkbox button to even?

      # step6
      # [] update checkbox button to even?

      # Reset others
      # [] Data Specs values?

    }) # end withprogress

    # Show Raw data Tab
    showTab(inputId = "byop_mainpaneldata_tabset", target = "rawdata_tab", select = TRUE)

  })

  # Metadata Input 1: Load example metadata ----
  observeEvent(input$submit_examplemetadata_button, {

    # if skipping metadata: ### meta
    if(input$select_examplemetadata == "metadata_skip"){ ### meta

      ## RESET
      # Update ReactiveValues
      # some of this is redundant, but best to be thorough
      # when you press submit, you are expecting data to be overwritten - the user expects a clear and resubmit. so clear all first:
      # 1. Reset metadata
      df_shiny$metadata = NULL
      df_shiny$metadata_skip = FALSE ### meta
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      df_shiny$parseddata = NULL

      ## 1. Don't add metadata
      df_shiny$metadata_skip = TRUE ### meta
      df_shiny$metadata <- data.frame(metadata = "No metadata has been uploaded.") ### meta

      # Show Metadata Tab
      showTab(inputId = "byop_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)
    }

    if(input$select_examplemetadata != "metadata_skip"){ ### meta

      withProgress(message = 'Loading metadata...', value = 0, {

        # RESET
        # Update ReactiveValues
        # some of this is redundant, but best to be thorough
        # when you press submit, you are expecting data to be overwritten - the user expects a clear and resubmit. so clear all first:
        # 1. Reset metadata
        df_shiny$metadata = NULL
        df_shiny$metadata_skip = FALSE ### meta
        # Also Reset parsed data (in case this has already taken place w a previous metadata)
        df_shiny$parseddata = NULL

        # LOAD
        # 1. Update metadata
        filepathtouse <- system.file("extdata", paste0(input$select_examplemetadata, ".csv"), package = "parsleyapp") ###

        # # v1
        # df_shiny$metadata <- utils::read.csv(filepathtouse)
        # # print(names(df_shiny$metadata)) # check # works

        # v2 ### matrix format
        if(grepl("matrix", input$select_examplemetadata)){
          df_shiny$metadata <- utils::read.csv(filepathtouse, header = FALSE) # matrix
        } else {
          df_shiny$metadata <- utils::read.csv(filepathtouse, header = TRUE) # tidy
        }

      }) # end withprogress

      # Show Metadata Tab
      showTab(inputId = "byop_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)

    } ### meta

  })

  # Metadata Input 1: Reset
  observeEvent(input$reset_examplemetadata_button, {

    withProgress(message = 'Clearing metadata...', value = 0, {

      # 1. Reset metadata
      df_shiny$metadata = NULL
      df_shiny$metadata_skip = FALSE ### meta
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      df_shiny$parseddata = NULL

    }) # end withprogress

    # Show Metadata Tab
    showTab(inputId = "byop_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)

  })

  # Metadata Input 2: Upload one CSV file ----
  observeEvent(input$submit_metadatafile_button, {

    withProgress(message = 'Loading metadata...', value = 0, {

      # Missing files:
      if (is.null(input$upload_metadata)) {
        # Error handling: stop
        req(!is.null(input$upload_metadata))
      }

      # RESET
      # Update ReactiveValues
      # some of this is redundant, but best to be thorough
      # when you press submit, you are expecting data to be overwritten - the user expects a clear and resubmit. so clear all first:
      # 1. Reset metadata
      df_shiny$metadata = NULL
      df_shiny$metadata_skip = FALSE ### meta
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      df_shiny$parseddata = NULL

      # LOAD:

      # v1 ### fileinput
      # # Which file to upload
      # file_in <- input$upload_metadata # the fileInput file selection device for Uploading one file was named "upload_metadata"
      # # print(file_in) # check
      # # print(file_in$datapath) # check
      #
      # # Do the upload
      #
      # # Reading the file:
      # isolate({
      #
      #   # Error handling when you try and upload the wrong file type: # 1. trycatch catches error
      #   tryCatch({
      #
      #     # read.csv
      #     data <- utils::read.csv(file_in$datapath, header = TRUE) # metadata should always have header (ie 1st row = colnames)
      #     # print(head(data)) # check
      #
      #   }, # end first {} block in tryCatch
      #   error = function(err) { message(err) },
      #   warning = function(warn) { message(warn) }
      #   ) # end tryCatch
      #   # Error handling when you try and upload the wrong file type: # 2. req() stops rest of function
      #   req(is.data.frame(data)) # read_delim produces tibbles. tibble::is_tibble(data) also works.
      #
      # }) # end isolate
      #
      # # LOAD
      # # 1. Update metadata
      # df_shiny$metadata <- data

      # # v2 fileinput of specific types ### fileinput
      # # only upload metadata if extension is valid
      # ext <- tools::file_ext(input$upload_metadata$name) ### fileinput
      # if(any(grepl(pattern = ext, x = c("csv")))){
      #
      #   data <- utils::read.csv(input$upload_metadata$datapath, header = TRUE) # metadata should always have header (ie 1st row = colnames)
      #
      #   # LOAD
      #   # 1. Update metadata
      #   df_shiny$metadata <- data
      #
      # } # only upload data if extension is valid

      # v3 fileinput of specific types, including excel ### fileinput ### excel
      # only upload metadata if extension is valid
      ext <- tools::file_ext(input$upload_metadata$name) ### fileinput
      if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt", "xls", "xlsx")))){

        data <- NULL

        if(grepl(pattern = ext, x = c("csv")) & input$metadata_delim == ","){ ### delim

          if(input$metadata_format == "tidy"){
            data <- utils::read.csv(input$upload_metadata$datapath, header = TRUE) # read.csv
          } else if(input$metadata_format == "matrix"){ ### matrix format
            data <- utils::read.csv(input$upload_metadata$datapath, header = FALSE)
          }

        }
        if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt"))) & (input$metadata_delim == ";" | input$metadata_delim == "\t")){ ### delim

          if(input$metadata_format == "tidy"){
            data <- utils::read.table(input$upload_metadata$datapath, header = TRUE, sep = input$metadata_delim) # read.table
          } else if(input$metadata_format == "matrix"){ ### matrix format
            data <- utils::read.table(input$upload_metadata$datapath, header = FALSE, sep = input$metadata_delim)
          }

        }
        if(any(grepl(pattern = ext, x = c("xls", "xlsx"))) & input$metadata_delim == "excel"){ ### excel

          if(input$metadata_format == "tidy"){
            data <- readxl::read_excel(input$upload_metadata$datapath, col_names = TRUE) # first sheet # col_names like "header" for readcsv
          } else if(input$metadata_format == "matrix"){ ### matrix format
            data <- readxl::read_excel(input$upload_metadata$datapath, col_names = FALSE)
          }

        }

        if(!is.null(data)){ ### excel
          # LOAD
          # 1. Update metadata
          df_shiny$metadata <- data
        } else {
          # if data doesn't exist, there must be a mix up between file extension and file type specified
          message("Error: Ensure that the specified file type matches uploaded file's extension.")
          showModal(modalDialog(title = "Error", "Ensure that the specified file type matches uploaded file's extension.",
                                easyClose = TRUE ))
        }

        # # LOAD
        # # 1. Update metadata
        # df_shiny$metadata <- data

      } else {

        # if extension is not on the list of permissible extensions, throw error ### excel
        message("Error: File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.")
        showModal(modalDialog(title = "Error", "File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.",
                              easyClose = TRUE ))

      } # only upload data if extension is valid

    }) # end withprogress

    # Show Metadata Tab
    showTab(inputId = "byop_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)

  })
  # Metadata Input 2: Reset
  observeEvent(input$reset_metadatafile_button, {

    withProgress(message = 'Clearing metadata...', value = 0, {

      # 1. Reset metadata
      df_shiny$metadata = NULL
      df_shiny$metadata_skip = FALSE ### meta
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      df_shiny$parseddata = NULL

    }) # end withprogress

    # Show Metadata Tab
    showTab(inputId = "byop_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)

  })

  ##

  # Filename extraction ----

  # Filename extraction for single files
  # ...using reactiveValues and observeEvent()
  uploaded_file <- reactiveValues(
    filename_as_string = NULL, # doesn't tolerate "<-" here, has to be "="
    filename_as_string_metadata = NULL
  )
  observeEvent(input$submit_datafile_button, { # Submit button

    inFile <- input$upload_data
    if (is.null(inFile)) { return(NULL) }
    uploaded_file$filename_as_string <- stringi::stri_extract_first(str = inFile$name, regex = ".*")
    # regex "" gives me NA # regex "." gives me 2 # regex ".*" gives me basename(file)
    # regex "*" gives me syntax error # regex ".*(?=\\.)" gives me basename wo extension

  })
  observeEvent(input$reset_datafile_button, { # Reset button
    uploaded_file$filename_as_string <- NULL
  })
  output$myFileName <- renderPrint({ cat(uploaded_file$filename_as_string) })

  # Metadata
  observeEvent(input$submit_metadatafile_button, { # Submit button

    inFile <- input$upload_metadata
    if (is.null(inFile)) { return(NULL) }
    uploaded_file$filename_as_string_metadata <- stringi::stri_extract_first(str = inFile$name, regex = ".*")

  })
  observeEvent(input$reset_metadatafile_button, { # Reset button
    uploaded_file$filename_as_string_metadata <- NULL
  })
  output$metadata_name <- renderPrint({ cat(uploaded_file$filename_as_string_metadata) })

  ##

  # DATATABLES ----

  # alldata ----
  output$RawDataTable = DT::renderDataTable({

    # Remove error message from DT output after clearing data
    if(is.null(df_shiny$alldata)){
      df_temp <- data.frame(v1 = c(NA))
      DT::datatable(df_temp)
      return()
    }

    DT::datatable(df_shiny$alldata, # raw_data
              escape = TRUE, # default but impt. 'escapes' html content of tables.
              selection = list(target = 'cell'),
              rownames = FALSE, # remove row numbering
              # rownames = TRUE, ### rownumbers # can't enable, as disrupts cell selection function.
              class = "compact", # removes row highlighting and compacts rows a bit
              options = list(
                dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                paging = FALSE # only ever show all rows
                # pageLength = -1, # rows to show initially (-1 = all rows)
                # lengthMenu = list(c(-1, 10, 50), c('All', '10 rows', '100 rows')) # row number options
                # searching = FALSE,

                # # how to fix col widths?
                # scrollX = TRUE # autoWidth = TRUE, columnDefs = list(list(width = '50px', targets = "_all"))
                # # supposedly this fixes columns but fails for long-text columns
                # # issue still unsolved https://github.com/rstudio/DT/issues/29

              ) # DT options https://shiny.rstudio.com/gallery/datatables-options.html
    ) %>%
      DT::formatStyle(c(1:dim(df_shiny$alldata)[2]), # all columns # https://stackoverflow.com/questions/50751568/add-cell-borders-in-an-r-datatable
                  border = '1px solid #ddd', # https://stackoverflow.com/questions/50751568/add-cell-borders-in-an-r-datatable
                  fontSize = '10px', # reduce font size # can also do '50%' https://stackoverflow.com/questions/44101055/changing-font-size-in-r-datatables-dt
                  cursor = 'pointer' # fun. adds "hand" pointer to make it clear it's clickable
      )

  }) # renderdatatable

  #

  # first channel data (data from first reading) ----

  # FirstChannelDataTable - first row/column
  output$FirstChannelDataTable = DT::renderDataTable({

    DT::datatable(df_dataspecs$firstchanneldata,
              escape = TRUE, # default but impt. 'escapes' html content of tables.
              # rownames = FALSE, # remove row numbering
              rownames = TRUE, ### rownumbers
              class = "compact", # removes row highlighting and compacts rows a bit
              options = list(
                dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                paging = FALSE # only ever show all rows
              )
    )

  }) # renderdatatable

  #

  # totaldata (cropped data) ----

  # TotalDataTable - all cells w numeric data - for Cropped Data Tab page
  output$TotalDataTable = DT::renderDataTable({

    DT::datatable(df_shiny$totaldata,
              escape = TRUE, # default but impt. 'escapes' html content of tables.
              rownames = TRUE, # keep row numbering - required to show reading names post step 5
              class = "compact", # removes row highlighting and compacts rows a bit
              options = list(
                dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                paging = FALSE # only ever show all rows
              )
    )

  }) # renderdatatable

  #

  # metadata table ----
  output$MetaDataTable = DT::renderDataTable({

    DT::datatable(df_shiny$metadata,
              escape = TRUE, # default but impt. 'escapes' html content of tables.
              # rownames = FALSE, # remove row numbering
              rownames = TRUE, ### rownumbers
              class = "compact", # removes row highlighting and compacts rows a bit
              options = list(
                dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                paging = FALSE # only ever show all rows
              )
    )

  }) # renderdatatable

  #

  # parsed data table ----
  output$ParsedDataTable = DT::renderDataTable({

    DT::datatable(df_shiny$parseddata,
              escape = TRUE, # default but impt. 'escapes' html content of tables.
              # selection = list(target = 'cell'),
              # rownames = FALSE, # remove row numbering
              rownames = TRUE, ### rownumbers
              class = "compact", # removes row highlighting and compacts rows a bit
              options = list(
                dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                paging = FALSE # only ever show all rows
              )
    )

  }) # renderdatatable

  ##

  # CLICKS (Troubleshooting) -----

  # # Checks in UI:
  # # All Clicks
  # output$AllClicks = renderPrint(input$RawDataTable_cells_selected)
  # # Current Click
  # output$CurrentClick = renderPrint(input$RawDataTable_cell_clicked)

  # # Checks in Console:
  # observeEvent(input$RawDataTable_cell_clicked, { # https://yihui.shinyapps.io/DT-click/
  #
  #   # # current click checks
  #   # current_click = input$RawDataTable_cell_clicked
  #   # if (is.null(current_click$value)){return()} # do nothing if not clicked yet
  #   # print(paste0("current cell clicked*row = ", current_click$row))
  #   # print(paste0("current cell clicked*col = ", current_click$col))
  #   # print(paste0("current cell clicked*value = ", current_click$value))
  #   # print(input$RawDataTable_cells_selected)
  #
  #   # total click checks
  #   if (nrow(input$RawDataTable_cells_selected)<=1){return()} # do nothing if we don't have at least two clicks
  #   all_selected_cells <- input$RawDataTable_cells_selected
  #
  #   row_beg <- all_selected_cells[nrow(all_selected_cells)-1,1] # row _beg = second to last row, col1 of 'all clicks' table
  #   row_end <- all_selected_cells[nrow(all_selected_cells),1] # row_end = last row, col1 of 'all clicks' table
  #   col_beg <- ((all_selected_cells[nrow(all_selected_cells)-1,2])+1) # col_beg = second to last row, col2 of 'all clicks' table, +1 as cols start at 0 for some reason
  #   col_end <- ((all_selected_cells[nrow(all_selected_cells),2])+1) # col_end = last row, col2 of 'all clicks' table, +1 as cols start at 0 for some reason
  #
  #   # Very talkative print call
  #   # print(df_shiny$alldata[row_beg:row_end, col_beg:col_end])
  #
  # })

  # DATA SPECS ------

  # New reactiveValues for the Data Specs
  df_dataspecs <- reactiveValues(

    # step1
    datatype = NULL,
    dataformat = NULL,

    # step2
    channel_number = NULL,
    channel_name_specification = NULL, ### save_parser # fixed/selected
    channel_name_indices = NULL, ### save_parser
    channel_names = NULL,
    wav_min = NULL,
    wav_max = NULL,
    wav_interval = NULL,

    # step2b
    timecourse_specification = NULL, ### save_parser # fixed/selected
    timecourse_indices = NULL, ### save_parser
    timecourse_firsttimepoint = NULL,
    timecourse_duration = NULL,
    timecourse_interval = NULL,
    timepoint_number_expected = NULL,
    timepoint_number = NULL, # worked out version
    list_of_timepoints = NULL,

    # step3
    matrixformat = NULL,
    firstchanneldata = NULL,
    row_beg = NULL,
    row_end = NULL,
    col_beg = NULL,
    col_end = NULL,
    well_data_specification = NULL, ### save_parser # calculate/select
    well_data_indices = NULL, ### save_parser

    # step4
    channeldataspacing = NULL,

    # step5
    starting_well = NULL,
    readingorientation = NULL,
    used_wells = NULL

  )

  # Step 1 - Data Format -------------------------------------------------------------------------------------

  observeEvent(input$submit_dataformat_button, { # update whenever Step1 Confirm button is pressed

    if(input$step1_checkbox_button %%2 == 1){ # if checkbox button is checked/locked (clicked an odd number of times)
      # do nothing if step already complete
      message("Error: Section marked complete.")
      showModal(modalDialog(title = "Error", "Section marked complete.", easyClose = TRUE ))
      return()
    }
    if(input$datatype == "datatype_null" | input$dataformat == "dataformat_null"){
      # do nothing until there are selections
      message("Error: Select values first.")
      showModal(modalDialog(title = "Error", "Select values first.", easyClose = TRUE ))
      df_dataspecs$datatype <- NULL # revert value
      df_dataspecs$dataformat <- NULL
      return()
    }

    # Update Values

    # Update Values for All
    df_dataspecs$datatype <- input$datatype # "datatype_standard"
    df_dataspecs$dataformat <- input$dataformat # "dataformat_rows" or "dataformat_columns"

    # Illegal combinations
    if( (df_dataspecs$datatype == "datatype_spectrum" & df_dataspecs$dataformat == "dataformat_matrix") ){
      message("Error: Spectrum data must be provided in row or column format.")
      showModal(modalDialog(title = "Error", "Spectrum data must be provided in row or column format.", easyClose = TRUE ))
      df_dataspecs$datatype <- NULL # revert value
      df_dataspecs$dataformat <- NULL
      return()
    }
    if( (df_dataspecs$datatype == "datatype_timecourse" & df_dataspecs$dataformat == "dataformat_matrix") ){
      message("Error: Timecourse data must be provided in row or column format.")
      showModal(modalDialog(title = "Error", "Timecourse data must be provided in row or column format.", easyClose = TRUE ))
      df_dataspecs$datatype <- NULL # revert value
      df_dataspecs$dataformat <- NULL
      return()
    }

    # Console checks
    print("data type: ")
    print(df_dataspecs$datatype)
    print("data format: ")
    print(df_dataspecs$dataformat)

    # Show Data Specs Tab (tab is now visible, but isn't automatically selected)
    showTab(inputId = "byop_mainpaneldata_tabset", target = "dataspecs_tab", select = FALSE)

  })
  output$datatype_printed <- renderPrint({ cat(df_dataspecs$datatype) })
  output$dataformat_printed <- renderPrint({ cat(df_dataspecs$dataformat) })

  # Step 2 - Channel Names -------------------------------------------------------------------------------------

  observeEvent(input$submit_channelnames_button, { # update whenever Step2 Confirm button is pressed

    if(input$step2_checkbox_button %%2 == 1){ # if checkbox button is checked/locked (clicked an odd number of times)
      # do nothing if step already complete
      message("Error: Section marked complete.")
      showModal(modalDialog(title = "Error", "Section marked complete.", easyClose = TRUE ))
      return()
    }

    # Check previous steps completed
    if(input$step1_checkbox_button %%2 == 0){ # if checkbox button is unchecked/locked (clicked an even number of times)
      # do nothing if previous steps incomplete
      message("Error: Section 1 marked incomplete.")
      showModal(modalDialog(title = "Error", "Section 1 marked incomplete.", easyClose = TRUE ))
      # df_dataspecs$channel_names <- NULL
      # df_dataspecs$channel_number <- NULL
      return()
    }

    # FOR LIMITED CHANNEL NUMBERS - standard and timecourse data - Select cells to assign channel names -----
    if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_timecourse"){

      # Check channel names option is selected (only applies to std/timecourse data)
      if(input$channel_names_input == "channel_names_input_null"){
        message("Error: Select reading names input method.")
        showModal(modalDialog(title = "Error", "Select reading names input method.", easyClose = TRUE ))
        df_dataspecs$channel_number <- NULL
        df_dataspecs$channel_name_specification <- NULL ### save_parser
        df_dataspecs$channel_name_indices <- NULL ### save_parser
        df_dataspecs$channel_names <- NULL
        return()
      }

      # Channel Number - from numeric input
      df_dataspecs$channel_number <- input$channel_number
      print("channel number: ")
      print(df_dataspecs$channel_number)

      # Channel names Option1: get channel names from selected cells ----
      if(input$channel_names_input == "channel_names_input_select"){

        if(nrow(input$RawDataTable_cells_selected)==0){
          # do nothing until there are selections
          message("Error: Select cells first.")
          showModal(modalDialog(title = "Error", "Select cells first.", easyClose = TRUE ))
          df_dataspecs$channel_number <- NULL
          df_dataspecs$channel_name_specification <- NULL ### save_parser
          df_dataspecs$channel_name_indices <- NULL ### save_parser
          df_dataspecs$channel_names <- NULL
          return()
        }

        # Set df_dataspecs$channel_name_specification ### save_parser
        df_dataspecs$channel_name_specification <- "selected"

        # Expected Channel Number
        nrow_expected <- df_dataspecs$channel_number
        # Channels Selected
        nrow_submitted <- nrow(input$RawDataTable_cells_selected)
        # Need as many selections as channels
        if( (nrow_expected > nrow_submitted) | (nrow_expected < nrow_submitted) ){
          message("Error: Number of reading names does not match number of readings specified.")
          showModal(modalDialog(title = "Error", "Number of reading names does not match number of readings specified.", easyClose = TRUE ))
          df_dataspecs$channel_number <- NULL
          df_dataspecs$channel_name_specification <- NULL ### save_parser
          df_dataspecs$channel_name_indices <- NULL ### save_parser
          df_dataspecs$channel_names <- NULL
          return()
        }

        # Extract values from alldata
        all_selected_cells <- input$RawDataTable_cells_selected
        # Save selected cell indices (just altogether) ### save_parser
        df_dataspecs$channel_name_indices <- all_selected_cells

        selectedcell_values <- c()
        for(i in 1:nrow(all_selected_cells)){

          # subset row
          cell_i <- all_selected_cells[i,]

          # use co-ords to grab values from alldata
          value_i <- df_shiny$alldata[cell_i[1],(cell_i[2]+1)] # again, cols need a +1

          selectedcell_values <- c(selectedcell_values, value_i)
        }

        # Check for empty cells
        if(any(selectedcell_values=="")){
          # if any of the wells in the list is "", stop
          message("Error: Reading name selection cannot contain empty cells.")
          showModal(modalDialog(title = "Error", "Reading name selection cannot contain empty cells.", easyClose = TRUE ))
          df_dataspecs$channel_number <- NULL
          df_dataspecs$channel_name_specification <- NULL ### save_parser
          df_dataspecs$channel_name_indices <- NULL ### save_parser
          df_dataspecs$channel_names <- NULL
          return()
        }

        # Update channel_names
        df_dataspecs$channel_names <- selectedcell_values

      } else if(input$channel_names_input == "channel_names_input_manual"){

        # Channel names Option2: get channel names from text input ----

        # Set df_dataspecs$channel_name_specification ### save_parser
        df_dataspecs$channel_name_specification <- "fixed"
        df_dataspecs$channel_name_indices <- NULL # overwrite any previous assignment in 'select' mode

        # Convert text to list at ","s
        temp_channelnameslist <- unlist(strsplit(input$channel_names_manual_input, split=","))

        # Fix entries as poor as: ' od-1, red.2, blue fluor ':
        # Remove white space front and back # https://study.com/academy/lesson/removing-space-from-string-in-r-programming.html
        temp_channelnameslist <- trimws(temp_channelnameslist)
        # Remove all punctuation (except underscores) & replace with underscore (presumably this replaces _ with _ so fine.)
        temp_channelnameslist <- gsub(x = temp_channelnameslist, pattern = "[[:punct:]]", replacement = "_") # sub() changes first. gsub changes all.
        # Replace internal white spaces with underscores
        temp_channelnameslist <- gsub(x = temp_channelnameslist, pattern = " ", replacement = "_") # sub() changes first. gsub changes all.

        # Expected Channel Number
        nrow_expected <- df_dataspecs$channel_number
        # Channels Manually Entered
        nrow_submitted <- length(temp_channelnameslist)
        print("length of names list entered:")
        print(nrow_submitted)
        # Need as many selections as channels
        if( (nrow_expected > nrow_submitted) | (nrow_expected < nrow_submitted) ){
          message("Error: Number of reading names does not match number of readings specified.")
          showModal(modalDialog(title = "Error", "Number of reading names does not match number of readings specified.", easyClose = TRUE ))
          df_dataspecs$channel_number <- NULL
          df_dataspecs$channel_name_specification <- NULL ### save_parser
          df_dataspecs$channel_name_indices <- NULL ### save_parser
          df_dataspecs$channel_names <- NULL
          return()
        }

        # Update channel_names
        df_dataspecs$channel_names <- temp_channelnameslist

      } # channel names as select or manual

    } # std and timecourse

    # Add text to spectrum vars for UI indication
    # possibly redundant now Spectrum dataspecs do not show up in non-Spectrum data
    if(df_dataspecs$datatype == "datatype_standard"){
      df_dataspecs$wav_min <- "Wavelength inputs irrelevant for Standard format data."
      df_dataspecs$wav_max <- "Wavelength inputs irrelevant for Standard format data."
      df_dataspecs$wav_interval <- "Wavelength inputs irrelevant for Standard format data."
    } else if(df_dataspecs$datatype == "datatype_timecourse"){
      df_dataspecs$wav_min <- "Wavelength inputs irrelevant for Timecourse format data."
      df_dataspecs$wav_max <- "Wavelength inputs irrelevant for Timecourse format data."
      df_dataspecs$wav_interval <- "Wavelength inputs irrelevant for Timecourse format data."
    }

    # FOR SPECTRUM DATA - work out channel names from wavelengths -----
    if(df_dataspecs$datatype == "datatype_spectrum"){

      # Don't expect anyone to manually select 800 wells!
      # Work out channel names from wavelengths inputted

      df_dataspecs$channel_name_specification <- "fixed" ### saved_parser
      # meaning specified in the left hand panel, as opposed to by selection of cells

      # Save for Data Specs View tab
      df_dataspecs$wav_min <- input$wav_min
      df_dataspecs$wav_max <- input$wav_max
      df_dataspecs$wav_interval <- input$wav_interval

      # Channel number - worked out
      # old version: in step1, df_dataspecs$channel_number was overwritten by text for spectrum data to stop spectra data crashing at Step 4.
      df_dataspecs$channel_number <- length(seq(from = df_dataspecs$wav_min, to = df_dataspecs$wav_max, by = df_dataspecs$wav_interval))

      # Update channel_names
      df_dataspecs$channel_names <- seq(from = df_dataspecs$wav_min, to = df_dataspecs$wav_max, by = df_dataspecs$wav_interval)

    }

    print("channel name specification: ") ### save_parser
    print(df_dataspecs$channel_name_specification)
    print("channel name indices: ") ### save_parser
    print(df_dataspecs$channel_name_indices)
    print("channel names: ")
    print(df_dataspecs$channel_names) # this is often a list, so prints odd if i paste0 it.

  })
  output$channel_number <- renderPrint({ cat(df_dataspecs$channel_number) })
  output$channel_names_printed <- renderPrint({ cat(df_dataspecs$channel_names) })
  output$wav_min_printed <- renderPrint({ cat(df_dataspecs$wav_min) })
  output$wav_max_printed <- renderPrint({ cat(df_dataspecs$wav_max) })
  output$wav_interval_printed <- renderPrint({ cat(df_dataspecs$wav_interval) })

  # Step 2B - Timepoint vars -------------------------------------------------------------------------------------

  observeEvent(input$submit_timepointvars_button, { # update whenever Step2B Confirm button is pressed

    if(input$step2b_checkbox_button %%2 == 1){ # if checkbox button is checked/locked (clicked an odd number of times)
      # do nothing if step already complete
      message("Error: Section marked complete.")
      showModal(modalDialog(title = "Error", "Section marked complete.", easyClose = TRUE ))
      return()
    }

    # Check previous steps completed
    if(input$step1_checkbox_button %%2 == 0 | input$step2_checkbox_button %%2 == 0){ # if checkbox button is unchecked/locked (clicked an even number of times)
      # do nothing if previous steps incomplete
      message("Error: Previous sections marked incomplete.")
      showModal(modalDialog(title = "Error", "Previous sections marked incomplete.", easyClose = TRUE ))
      df_dataspecs$timecourse_specification <- NULL ### save_parser
      df_dataspecs$timecourse_indices <- NULL ### save_parser
      df_dataspecs$timecourse_firsttimepoint <- NULL
      df_dataspecs$timecourse_duration <- NULL
      df_dataspecs$timecourse_interval <- NULL
      df_dataspecs$timepoint_number_expected <- NULL
      df_dataspecs$timepoint_number <- NULL # worked out version
      df_dataspecs$list_of_timepoints <- NULL
      return()
    }

    # Update Values Depending on Data types
    if(df_dataspecs$datatype == "datatype_standard"){ # possibly redundant now that ui is hidden for other data types

      df_dataspecs$timecourse_firsttimepoint <- "First timepoint irrelevant for Standard format data."
      df_dataspecs$timecourse_duration <- "Timepoint duration irrelevant for Standard format data."
      df_dataspecs$timecourse_interval <- "Timepoint interval irrelevant for Standard format data."
      df_dataspecs$timepoint_number_expected  <- "Timepoint number (expected) irrelevant for Standard format data."
      df_dataspecs$timepoint_number <- "Timepoint number irrelevant for Standard format data."
      df_dataspecs$list_of_timepoints <- "Timepoint list irrelevant for Standard format data."

    } else if(df_dataspecs$datatype == "datatype_spectrum") { # possibly redundant now that ui is hidden for other data types

      df_dataspecs$timecourse_firsttimepoint <- "First timepoint irrelevant for Spectrum format data."
      df_dataspecs$timecourse_duration <- "Timepoint duration irrelevant for Spectrum format data."
      df_dataspecs$timecourse_interval <- "Timepoint interval irrelevant for Spectrum format data."
      df_dataspecs$timepoint_number_expected  <- "Timepoint number (expected) irrelevant for Standard format data."
      df_dataspecs$timepoint_number <- "Timepoint number irrelevant for Spectrum format data."
      df_dataspecs$list_of_timepoints <- "Timepoint list irrelevant for Standard format data."

    } else if(df_dataspecs$datatype == "datatype_timecourse") {

      if(input$timecourse_input == "timecourse_input_calculate"){ # timepoints added in the original way. added for handling: ### timepoints from data

        # save timecourse data specification - fixed or selected
        df_dataspecs$timecourse_specification <- "fixed" ### save_parser
        # save timecourse indices ### save_parser
        df_dataspecs$timecourse_indices <- NULL # overwrite previous assignments in 'select' mode

        df_dataspecs$timecourse_firsttimepoint <- input$timecourse_firsttimepoint
        df_dataspecs$timecourse_duration <- input$timecourse_duration
        df_dataspecs$timecourse_interval <- input$timecourse_interval
        df_dataspecs$timepoint_number_expected <- input$timepoint_number_expected
        # df_dataspecs$timepoint_number <- input$timepoint_number # not specified in inputs anymore, needs working out (below)

        # Work out list of timepoints from first, interval and duration
        df_dataspecs$list_of_timepoints <- seq(from = df_dataspecs$timecourse_firsttimepoint, to = df_dataspecs$timecourse_duration, by = df_dataspecs$timecourse_interval)
        print("list of timepoints (calculated from first timepoint, interval and duration): ")
        print(df_dataspecs$list_of_timepoints)

        # Work out timepoint number from list
        df_dataspecs$timepoint_number <- length(df_dataspecs$list_of_timepoints)
        print("timepoint number (calculated from first timepoint, interval and duration): ")
        print(df_dataspecs$timepoint_number)

        # Compare worked out timepoint number to expected timepoint number
        df_dataspecs$timepoint_number_expected <- input$timepoint_number_expected
        print("timepoint number expected: ")
        print(df_dataspecs$timepoint_number_expected)

        # If they don't match - show message to say timepoint list will be cropped after expected number of timepoints
        if(df_dataspecs$timepoint_number_expected > df_dataspecs$timepoint_number){

          # Use calculated list
          # no need to update timepoints

          # Use calculated timepoint number
          # no need to update timepoint_number

          # Console
          message("Warning: More expected timepoints than calculated timepoints.")
          message("Using calculated timepoints:")
          message(df_dataspecs$list_of_timepoints)

          # Modal
          showModal(modalDialog(title = "Warning",
                                # paste0("More expected timepoints than calculated timepoints. Using calculated number of timepoints (", df_dataspecs$timepoint_number, "). Resultant timepoints: ",
                                #        df_dataspecs$list_of_timepoints[1], ", ", df_dataspecs$list_of_timepoints[2], " ... ",
                                #        df_dataspecs$list_of_timepoints[length(df_dataspecs$list_of_timepoints)], " min."), # last timepoint
                                paste0("More expected timepoints than calculated timepoints. Using calculated number of timepoints (", df_dataspecs$timepoint_number, "). Resultant timepoints: ",
                                       df_dataspecs$list_of_timepoints[1], ", ", df_dataspecs$list_of_timepoints[2], " ... ",
                                       df_dataspecs$list_of_timepoints[length(df_dataspecs$list_of_timepoints)], "."), ### minutes
                                easyClose = TRUE ))
          # can't straightforwardly paste the whole list in. this is a compromise w caveat that we're assuming at least 2 timepoints (not too much of a stretch hopefully!)

        } else if(df_dataspecs$timepoint_number_expected < df_dataspecs$timepoint_number){

          # Use smaller number, the expected timepoints. Truncate list.
          df_dataspecs$list_of_timepoints <- df_dataspecs$list_of_timepoints[1:df_dataspecs$timepoint_number_expected]

          # Use expected timepoint number
          df_dataspecs$timepoint_number <- df_dataspecs$timepoint_number_expected

          # Console
          message("Warning: Fewer expected timepoints than calculated timepoints.")
          message("Truncating timepoints to expected number of timepoints:")
          message(df_dataspecs$list_of_timepoints)

          # Modal
          showModal(modalDialog(title = "Warning",
                                # paste0("Fewer expected timepoints than calculated timepoints. Truncating timepoints to expected number of timepoints (",
                                #        df_dataspecs$timepoint_number, "). Resultant timepoints: ",
                                #        df_dataspecs$list_of_timepoints[1], ", ", df_dataspecs$list_of_timepoints[2], " ... ",
                                #        df_dataspecs$list_of_timepoints[length(df_dataspecs$list_of_timepoints)], " min."), # last timepoint
                                paste0("Fewer expected timepoints than calculated timepoints. Truncating timepoints to expected number of timepoints (",
                                       df_dataspecs$timepoint_number, "). Resultant timepoints: ",
                                       df_dataspecs$list_of_timepoints[1], ", ", df_dataspecs$list_of_timepoints[2], " ... ",
                                       df_dataspecs$list_of_timepoints[length(df_dataspecs$list_of_timepoints)], "."), ### minutes
                                easyClose = TRUE ))
          # can't straightforwardly paste the whole list in. this is a compromise w caveat that we're assuming at least 2 timepoints (not too much of a stretch hopefully!)

        }

      } else if(input$timecourse_input == "timecourse_input_select"){ ### timepoints from data

        # save timecourse data specification - fixed or selected
        df_dataspecs$timecourse_specification <- "selected" ### save_parser

        all_selected_cells <- input$RawDataTable_cells_selected

        if(nrow(input$RawDataTable_cells_selected)!=2){
          # do nothing until there are selections
          message("Error: Select two cells.")
          showModal(modalDialog(title = "Error", "Select two cells.", easyClose = TRUE ))
          df_dataspecs$timecourse_specification <- NULL ### save_parser
          df_dataspecs$timecourse_indices <- NULL ### save_parser
          df_dataspecs$timepoint_number <- NULL
          df_dataspecs$list_of_timepoints <- NULL
          return()
        }

        # take lowest&highest row numbers (regardless of click order or if topleft-bottomright conventions were followed)
        # by def, all_selected_cells will be a 2by2 matrix
        row_beg <- min(all_selected_cells[1,1], all_selected_cells[2,1])
        row_end <- max(all_selected_cells[1,1], all_selected_cells[2,1])
        col_beg <- min(all_selected_cells[1,2], all_selected_cells[2,2])+1 # +1 as cols start at 0 for some reason
        col_end <- max(all_selected_cells[1,2], all_selected_cells[2,2])+1 # +1 as cols start at 0 for some reason

        # save timecourse indices ### save_parser
        df_dataspecs$timecourse_indices <- c(row_beg, row_end, col_beg, col_end)

        # rows
        if(df_dataspecs$dataformat == "dataformat_rows"){ # if data in rows, then timepoints will form a column

          # stop if selection is >1 columns
          if(col_beg != col_end){
            message("Error: Select only 1 column.")
            showModal(modalDialog(title = "Error", "Select only 1 column.", easyClose = TRUE ))
            df_dataspecs$timecourse_specification <- NULL ### save_parser
            df_dataspecs$timecourse_indices <- NULL ### save_parser
            df_dataspecs$timepoint_number <- NULL
            df_dataspecs$list_of_timepoints <- NULL
            return()
          }

          # SAVE DATA
          df_dataspecs$list_of_timepoints <- df_shiny$alldata[row_beg:row_end, col_beg:col_end] # works. not list or df, but probably an array here

        } # rows

        # columns
        if(df_dataspecs$dataformat == "dataformat_columns"){ # if data in columns, then timepoints will form a row

          # stop if selection is >1 rows
          if(row_beg != row_end){
            message("Error: Select only 1 row.")
            showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
            df_dataspecs$timecourse_specification <- NULL ### save_parser
            df_dataspecs$timecourse_indices <- NULL ### save_parser
            df_dataspecs$timepoint_number <- NULL
            df_dataspecs$list_of_timepoints <- NULL
            return()
          }

          # SAVE DATA
          if(col_end != col_beg){ # if we have several columns, it will form a df naturally
            df_dataspecs$list_of_timepoints <- as.character(df_shiny$alldata[row_beg:row_end, col_beg:col_end]) # as array, not df
          } else if(col_end == col_beg) { # if we have a single column, we need to force a dataframe
            df_dataspecs$list_of_timepoints <- as.character(v1 = df_shiny$alldata[row_beg:row_end, col_beg:col_end]) # as array, not df
          }

        } # columns

        df_dataspecs$timepoint_number <- length(df_dataspecs$list_of_timepoints)

        # Check for empty cells
        if(any(df_dataspecs$list_of_timepoints=="")){
          # if any of the wells in the list is "", stop
          message("Error: Timepoint selection cannot contain empty cells.")
          showModal(modalDialog(title = "Error", "Timepoint selection cannot contain empty cells.", easyClose = TRUE ))
          df_dataspecs$timecourse_specification <- NULL ### save_parser
          df_dataspecs$timecourse_indices <- NULL ### save_parser
          df_dataspecs$timepoint_number <- NULL
          df_dataspecs$list_of_timepoints <- NULL
          return()
        }

      } # how timepoints are specified

    } # timecourse

    print("timepoint specification:") ### save_parser
    print(df_dataspecs$timecourse_specification)
    print("timepoint indices:") ### save_parser
    print(df_dataspecs$timecourse_indices)
    print("first timepoint: ")
    print(df_dataspecs$timecourse_firsttimepoint)
    print("timepoint duration: ")
    print(df_dataspecs$timecourse_duration)
    print("timepoint interval: ")
    print(df_dataspecs$timecourse_interval)
    print("timepoint number: ")
    print(df_dataspecs$timepoint_number)
    # print("expected timepoint number: ")
    # print(df_dataspecs$timepoint_number_expected)
    print("list of timepoints: ")
    print(df_dataspecs$list_of_timepoints)

  })
  output$timecourse_firsttimepoint <- renderPrint({ cat(df_dataspecs$timecourse_firsttimepoint) })
  output$timecourse_duration <- renderPrint({ cat(df_dataspecs$timecourse_duration) })
  output$timecourse_interval <- renderPrint({ cat(df_dataspecs$timecourse_interval) })
  output$timepoint_number <- renderPrint({ cat(df_dataspecs$timepoint_number) }) # not given but worked out version
  output$timepoint_number_expected <- renderPrint({ cat(df_dataspecs$timepoint_number_expected) })
  output$list_of_timepoints <- renderPrint({ cat(df_dataspecs$list_of_timepoints) })

  # Step 3 - First channel data -------------------------------------------------------------------------------------

  observeEvent(input$submit_firstchanneldata_button, { # update whenever Step3 Confirm button is pressed

    if(input$step3_checkbox_button %%2 == 1){ # if checkbox button is checked/locked (clicked an odd number of times)
      # do nothing if step already complete
      message("Error: Section marked complete.")
      showModal(modalDialog(title = "Error", "Section marked complete.", easyClose = TRUE ))
      return()
    }

    # Check previous steps completed
    if(input$step1_checkbox_button %%2 == 0 | input$step2_checkbox_button %%2 == 0){ # if checkbox button is unchecked/locked (clicked an even number of times)
      # do nothing if previous steps incomplete
      message("Error: Previous sections marked incomplete.")
      showModal(modalDialog(title = "Error", "Previous sections marked incomplete.", easyClose = TRUE ))
      # df_dataspecs$row_beg <- NULL
      # df_dataspecs$row_end <- NULL
      # df_dataspecs$col_beg <- NULL
      # df_dataspecs$col_end <- NULL
      # df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
      return()
    }

    if(nrow(input$RawDataTable_cells_selected)!=2){
      # do nothing until there are selections
      message("Error: Select two cells.")
      showModal(modalDialog(title = "Error", "Select two cells.", easyClose = TRUE ))
      df_dataspecs$row_beg <- NULL
      df_dataspecs$row_end <- NULL
      df_dataspecs$col_beg <- NULL
      df_dataspecs$col_end <- NULL
      df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
      return()
    }

    all_selected_cells <- input$RawDataTable_cells_selected

    # take lowest&highest row numbers (regardless of click order or if topleft-bottomright conventions were followed)
    # by def, all_selected_cells will be a 2by2 matrix
    row_beg <- min(all_selected_cells[1,1], all_selected_cells[2,1])
    row_end <- max(all_selected_cells[1,1], all_selected_cells[2,1])
    col_beg <- min(all_selected_cells[1,2], all_selected_cells[2,2])+1 # +1 as cols start at 0 for some reason
    col_end <- max(all_selected_cells[1,2], all_selected_cells[2,2])+1 # +1 as cols start at 0 for some reason

    # SAVE indices of alldata at which this data can be found
    df_dataspecs$row_beg <- row_beg
    df_dataspecs$row_end <- row_end
    df_dataspecs$col_beg <- col_beg
    df_dataspecs$col_end <- col_end

    # Standard and Spectrum data -----
    if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_spectrum"){

      if(df_dataspecs$dataformat == "dataformat_rows"){ # data in rows

        # stop if selection is >1 rows
        if(row_beg != row_end){
          message("Error: Select only 1 row.")
          showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
          df_dataspecs$row_beg <- NULL
          df_dataspecs$row_end <- NULL
          df_dataspecs$col_beg <- NULL
          df_dataspecs$col_end <- NULL
          df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
          return()
        }

        # SAVE DATA
        if(col_end != col_beg){ # if we have several columns, it will form a df naturally
          df_dataspecs$firstchanneldata <- df_shiny$alldata[row_beg:row_end, col_beg:col_end]
        } else if(col_end == col_beg) { # if we have a single column, we need to force a dataframe
          df_dataspecs$firstchanneldata <- data.frame(v1 = df_shiny$alldata[row_beg:row_end, col_beg:col_end])
        }

      } # row

      if(df_dataspecs$dataformat == "dataformat_columns"){ # data in columns

        # stop if selection is >1 rows
        if(col_beg != col_end){
          message("Error: Select only 1 column.")
          showModal(modalDialog(title = "Error", "Select only 1 column.", easyClose = TRUE ))
          df_dataspecs$row_beg <- NULL
          df_dataspecs$row_end <- NULL
          df_dataspecs$col_beg <- NULL
          df_dataspecs$col_end <- NULL
          df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
          return()
        }

        # SAVE DATA
        df_dataspecs$firstchanneldata <- data.frame(v1 = df_shiny$alldata[row_beg:row_end, col_beg:col_end])

      } # column

      if(df_dataspecs$dataformat == "dataformat_matrix"){ # data in matrix

        ## v1. First channel data: Select A1 and H12 (whole matrix). [Could consider an alternative version that selects A1-A12 only first.]
        # stop if selection is NOT >1 rows and >1 columns ??
        if( ((row_beg != row_end-7) | (col_beg != col_end-11)) & ((row_beg != row_end-11) | (col_beg != col_end-7)) ){
          # first half checks for 8-row*12col format: required when matrices are printed in horizontal format: rows as A1, A2, A3
          # second half checks for 8-col*12row format: required when matrices are printed in vertical format: rows as A1, B1, C1
          message("Error: Select an 8*12 matrix.")
          showModal(modalDialog(title = "Error", "Select an 8*12 matrix.", easyClose = TRUE ))
          df_dataspecs$row_beg <- NULL
          df_dataspecs$row_end <- NULL
          df_dataspecs$col_beg <- NULL
          df_dataspecs$col_end <- NULL
          df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
          return()
        }

        # Assign matrix 'type' from coordinates:
        if( (row_beg == row_end-7) & (col_beg == col_end-11) ){
          # 8 rows*12 columns = horizontal
          df_dataspecs$matrixformat <- "horizontal"
        }
        if( (row_beg == row_end-11) & (col_beg == col_end-7) ){
          # 12 rows*8 columns = vertical
          df_dataspecs$matrixformat <- "vertical"
        }

        print("matrix format: ")
        print(df_dataspecs$matrixformat)

        # Grab matrix data
        temp_firstchanneldata <- df_shiny$alldata[row_beg:row_end, col_beg:col_end]

        # Turn this matrix into a ROW
        temp_firstchanneldata <- as.data.frame(t(c(t(temp_firstchanneldata))))
        # t: transpose. reqd bc c() turns matrix into vector by reading down columns (yikes)
        # c: turns matrix into vector (column type).
        # t again: turns it back to row?
        # as.data.frame: prev experience says using t to transpose turns a df into a matrix. so switch back.

        # SAVE DATA
        df_dataspecs$firstchanneldata <- temp_firstchanneldata

      } # matrix

    } else if(df_dataspecs$datatype == "datatype_timecourse"){ # Timecourse data -------

      # For timecourse data, need to take into account (a) timepoints (b) channels

      # Assuming timepoints together, and channels separated (this is usual format):
      if(df_dataspecs$dataformat == "dataformat_rows"){

        # stop if selection is >1 rows
        if(row_beg != row_end){
          message("Error: Select only 1 row.")
          showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
          df_dataspecs$row_beg <- NULL
          df_dataspecs$row_end <- NULL
          df_dataspecs$col_beg <- NULL
          df_dataspecs$col_end <- NULL
          df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
          return()
        }

        # FIRST CHANNEL, FIRST TIMEPOINT
        # is selection

        # FIRST CHANNEL = FIRST CHANNEL, ALL TIMEPOINTS
        print("timepoint_number: ")
        print(df_dataspecs$timepoint_number)

        if(df_dataspecs$timepoint_number > 1){
          # if we have several columns, it will form a df naturally
          df_dataspecs$firstchanneldata <- df_shiny$alldata[row_beg:(row_end+df_dataspecs$timepoint_number-1), col_beg:col_end]
        } else if(df_dataspecs$timepoint_number == 1){
          # if we have a single timepoint therefore a single row for the whole first channel, we need to force a dataframe
          df_dataspecs$firstchanneldata <- data.frame(v1 = df_shiny$alldata[row_beg:row_end, col_beg:col_end])
        }

      } # row

      if(df_dataspecs$dataformat == "dataformat_columns"){

        # stop if selection is >1 rows
        if(col_beg != col_end){
          message("Error: Select only 1 column.")
          showModal(modalDialog(title = "Error", "Select only 1 column.", easyClose = TRUE ))
          df_dataspecs$row_beg <- NULL
          df_dataspecs$row_end <- NULL
          df_dataspecs$col_beg <- NULL
          df_dataspecs$col_end <- NULL
          df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
          return()
        }

        # FIRST CHANNEL, FIRST TIMEPOINT
        # is selection

        # FIRST CHANNEL = FIRST CHANNEL, ALL TIMEPOINTS
        print("timepoint_number: ")
        print(df_dataspecs$timepoint_number)

        if(df_dataspecs$timepoint_number > 1){
          # if we have several columns, it will form a df naturally
          df_dataspecs$firstchanneldata <- df_shiny$alldata[row_beg:row_end, col_beg:(col_end+df_dataspecs$timepoint_number-1)]
        } else if(df_dataspecs$timepoint_number == 1){
          # if we have a single timepoint therefore a single row for the whole first channel, we need to force a dataframe
          df_dataspecs$firstchanneldata <- data.frame(v1 = df_shiny$alldata[row_beg:row_end, col_beg:col_end])
        }

      } # column

    } # else if timecourse

    # print("first channel data:")
    # print(df_dataspecs$firstchanneldata)

  })

  # Step 4 - Channel data spacings and Total Data -------------------------------------------------------------------------------------
  observeEvent(input$submit_channeldataspacing_button, { # update whenever Step4 Confirm button is pressed

    if(input$step4_checkbox_button %%2 == 1){ # if checkbox button is checked/locked (clicked an odd number of times)
      # do nothing if step already complete
      message("Error: Section marked complete.")
      showModal(modalDialog(title = "Error", "Section marked complete.", easyClose = TRUE ))
      return()
    }

    # Check previous steps completed
    if(input$step1_checkbox_button %%2 == 0 | input$step2_checkbox_button %%2 == 0 | input$step3_checkbox_button %%2 == 0){ # if checkbox button is unchecked/locked (clicked an even number of times)
      # do nothing if previous steps incomplete
      message("Error: Previous sections marked incomplete.")
      showModal(modalDialog(title = "Error", "Previous sections marked incomplete.", easyClose = TRUE ))
      # df_dataspecs$channeldataspacing <- NULL
      # df_shiny$totaldata <- NULL
      return()
    }

    # Check section 3 has a value!
    if(is.null(df_dataspecs$firstchanneldata)){
      message("Error: Add first reading data to Section 3 first.")
      showModal(modalDialog(title = "Error", "Add first reading data to Section 3 first.", easyClose = TRUE ))
      # df_dataspecs$channeldataspacing <- NULL
      # df_shiny$totaldata <- NULL
      return()
    }

    # Unacceptable values
    if(!is.integer(input$channeldataspacing) | input$channeldataspacing < 1){
      message("Error: Reading number must be an integer of 1 or more.")
      showModal(modalDialog(title = "Error", "Reading number must be an integer of 1 or more.", easyClose = TRUE ))
      df_dataspecs$channeldataspacing <- NULL
      df_shiny$totaldata <- NULL
      return()
    }

    # SAVE
    df_dataspecs$channeldataspacing <- input$channeldataspacing

    # Check Step4 value
    print("data spacing:")
    print(df_dataspecs$channeldataspacing)

    # TOTAL DATA THEREFORE
    # Standard and Spectrum -----
    if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_spectrum"){

      # (1) If 1 channel, totaldata is the same as the first channel data
      if(df_dataspecs$channel_number == 1){

        # Save total data
        df_shiny$totaldata <- df_dataspecs$firstchanneldata
        # print("total data table:")
        # print(df_shiny$totaldata)

      } else if(df_dataspecs$channel_number > 1){
        # (2) If >1 channel, totaldata is..

        temp_alldata <- df_shiny$alldata

        # (2a) Rows:
        if(df_dataspecs$dataformat == "dataformat_rows"){

          # print("data spacing:")
          # print(df_dataspecs$channeldataspacing)

          # row numbers needed:
          row_numbers <- c()
          for(i in 1:df_dataspecs$channel_number){
            new_rownumber <- df_dataspecs$row_beg + (i-1)*df_dataspecs$channeldataspacing
            # use (i-1) not (i) because first row needs to equal df_dataspecs$row_beg (first i is 1, so first i-1 will always be 0)
            row_numbers <- c(row_numbers, new_rownumber)
          }
          print("row numbers to use:")
          print(row_numbers)

          ## Prevent crash when row/column indexes to use don't exist in df
          print("Last row number of requested data:")
          print(row_numbers[length(row_numbers)]) # last row number of requested data
          print("Last row number of existing data:")
          print(nrow(temp_alldata)) # last row number of existing data
          if(nrow(temp_alldata) < row_numbers[length(row_numbers)]){ # if we're requesting data outside the alldata df

            # Console
            message("Error: Do not request data from outside range of file.")
            message(paste0("Requested data up to row #", row_numbers[length(row_numbers)]))
            message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

            # Modal
            showModal(modalDialog(title = "Error",
                                  paste0("Do not request data from outside range of file. ",
                                         "[Requested data up to row #", row_numbers[length(row_numbers)], ". ",
                                         "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                  easyClose = TRUE ))

            return()
          }

          # Save total data
          df_shiny$totaldata <- temp_alldata[row_numbers, df_dataspecs$col_beg:df_dataspecs$col_end]
          # print("total data table:")
          # print(df_shiny$totaldata)

        }

        # (2b) Columns:
        if(df_dataspecs$dataformat == "dataformat_columns"){

          # print("data spacing:")
          # print(df_dataspecs$channeldataspacing)

          # column numbers needed:
          column_numbers <- c()
          for(i in 1:df_dataspecs$channel_number){
            new_columnnumber <- df_dataspecs$col_beg + (i-1)*df_dataspecs$channeldataspacing
            # use (i-1) not (i) because first column needs to equal df_dataspecs$col_beg (first i is 1, so first i-1 will always be 0)
            column_numbers <- c(column_numbers, new_columnnumber)
          }
          print("column numbers to use:")
          print(column_numbers)

          ## Prevent crash when row/column indexes to use don't exist in df
          print("Last column number of requested data:")
          print(column_numbers[length(column_numbers)]) # last row number of requested data
          print("Last column number of existing data:")
          print(ncol(temp_alldata)) # last row number of existing data
          if(ncol(temp_alldata) < column_numbers[length(column_numbers)]){ # if we're requesting data outside the alldata df

            # Console
            message("Error: Do not request data from outside range of file.")
            message(paste0("Requested data up to column #", column_numbers[length(column_numbers)]))
            message(paste0("Existing data's highest column number: #", ncol(temp_alldata)))

            # Modal
            showModal(modalDialog(title = "Error",
                                  paste0("Do not request data from outside range of file. ",
                                        "[Requested data up to column #", column_numbers[length(column_numbers)], ". ",
                                        "Existing data's highest column number: #", ncol(temp_alldata), ".]"),
                                  easyClose = TRUE ))

            return()
          }

          # Save total data
          df_shiny$totaldata <- temp_alldata[df_dataspecs$row_beg:df_dataspecs$row_end, column_numbers]
          # print("total data table:")
          # print(df_shiny$totaldata)

        } # columns

        # (2c) Matrix
        if(df_dataspecs$dataformat == "dataformat_matrix"){

          # print("data spacing:")
          # print(df_dataspecs$channeldataspacing)

          if(df_dataspecs$matrixformat == "horizontal"){ # matrix horizontal is in 8row*12col format

            # row numbers needed:
            row_numbers <- c()
            for(i in 1:df_dataspecs$channel_number){
              new_rownumber <- df_dataspecs$row_beg + (i-1)*df_dataspecs$channeldataspacing
              # use (i-1) not (i) because first row needs to equal df_dataspecs$row_beg (first i is 1, so first i-1 will always be 0)
              row_numbers <- c(row_numbers, new_rownumber)
            }
            print("row numbers to use:")
            print(row_numbers)

            ## Prevent crash when row/column indexes to use don't exist in df
            print("Last row number of requested data:")
            print(row_numbers[length(row_numbers)] + 7) # last row number of requested data +7 for matrix (as row_beg = A, so row_beg+7 = H)
            print("Last row number of existing data:")
            print(nrow(temp_alldata)) # last row number of existing data
            if(nrow(temp_alldata) < row_numbers[length(row_numbers)]){ # if we're requesting data outside the alldata df

              # Console
              message("Error: Do not request data from outside range of file.")
              message(paste0("Requested data up to row #", row_numbers[length(row_numbers)]+7 ))
              message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

              # Modal
              showModal(modalDialog(title = "Error",
                                    paste0("Do not request data from outside range of file. ",
                                           "[Requested data up to row #", row_numbers[length(row_numbers)]+7, ". ",
                                           "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                    easyClose = TRUE ))

              return()
            }

            # Save total data - MATRIX
            df_shiny$totaldata <- c()

            for(i in 1:length(row_numbers)){ # for each reading
              first_row <- row_numbers[i] # A
              last_row <- first_row+7 # H

              ## Grab matrix data
              # temp_firstchanneldata <- df_shiny$alldata[row_beg:row_end, col_beg:col_end] # used in step3
              temp_channeli_data <- temp_alldata[first_row:last_row, df_dataspecs$col_beg:df_dataspecs$col_end] # used in step4 - works for each channel
              ## Turn this matrix into a ROW
              temp_channeli_data <- as.data.frame(t(c(t(temp_channeli_data))))
              ## Save data
              # df_dataspecs$firstchanneldata <- temp_firstchanneldata # step3
              df_shiny$totaldata <- rbind(df_shiny$totaldata, temp_channeli_data) # step4

            } # for each reading -> assemble data

          } # horizontal

          if(df_dataspecs$matrixformat == "vertical"){ # matrix vertical is in 12row*8col format

            # row numbers needed:
            row_numbers <- c()
            for(i in 1:df_dataspecs$channel_number){
              new_rownumber <- df_dataspecs$row_beg + (i-1)*df_dataspecs$channeldataspacing
              # use (i-1) not (i) because first row needs to equal df_dataspecs$row_beg (first i is 1, so first i-1 will always be 0)
              row_numbers <- c(row_numbers, new_rownumber)
            }
            print("row numbers to use:")
            print(row_numbers)

            ## Prevent crash when row/column indexes to use don't exist in df
            print("Last row number of requested data:")
            print(row_numbers[length(row_numbers)] + 11) # last row number of requested data +11 for matrix vertical
            # (as row_beg = 1, so row_beg+11 = 12)
            # DIFFERENCE ABOVE
            print("Last row number of existing data:")
            print(nrow(temp_alldata)) # last row number of existing data
            if(nrow(temp_alldata) < row_numbers[length(row_numbers)]){ # if we're requesting data outside the alldata df

              # Console
              message("Error: Do not request data from outside range of file.")
              message(paste0("Requested data up to row #", row_numbers[length(row_numbers)]+11 ))
              # DIFFERENCE ABOVE
              message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

              # Modal
              showModal(modalDialog(title = "Error",
                                    paste0("Do not request data from outside range of file. ",
                                           "[Requested data up to row #", row_numbers[length(row_numbers)]+11, ". ",
                                           "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                    easyClose = TRUE ))

              return()
            }

            # Save total data - MATRIX
            df_shiny$totaldata <- c()

            for(i in 1:length(row_numbers)){ # for each reading
              first_row <- row_numbers[i] # 1
              last_row <- first_row+11 # 12
              # DIFFERENCE ABOVE

              ## Grab matrix data
              # temp_firstchanneldata <- df_shiny$alldata[row_beg:row_end, col_beg:col_end] # used in step3
              temp_channeli_data <- temp_alldata[first_row:last_row, df_dataspecs$col_beg:df_dataspecs$col_end] # used in step4 - works for each channel
              ## Turn this matrix into a ROW
              temp_channeli_data <- as.data.frame(t(c(t(temp_channeli_data))))
              ## Save data
              # df_dataspecs$firstchanneldata <- temp_firstchanneldata # step3
              df_shiny$totaldata <- rbind(df_shiny$totaldata, temp_channeli_data) # step4
            } # for each reading -> assemble data

          } # vertical

          # print("total data table:")
          # print(df_shiny$totaldata)

        } # matrix

      } # channel number > 1

    } else if(df_dataspecs$datatype == "datatype_timecourse"){
      # Timecourse -----

      # (1) If 1 channel, totaldata is the same as the first channel data
      if(df_dataspecs$channel_number == 1){

        if(df_dataspecs$dataformat == "dataformat_rows"){

          # Save total data
          df_shiny$totaldata <- df_dataspecs$firstchanneldata

          # EDIT: different from non-timecourse data, add in column names from well name (step 5)
          # and add in columns for reading name and timepoint time (here):

          # reading name as 'channel' column:
          df_shiny$totaldata <- df_shiny$totaldata %>%
            dplyr::mutate(channel = df_dataspecs$channel_names) # should only be one

          # timepoints as 'time' column:
          timepoints_df <- data.frame(time = df_dataspecs$list_of_timepoints)
          df_shiny$totaldata <- cbind(df_shiny$totaldata, timepoints_df)

          # print("total data table:")
          # print(df_shiny$totaldata)

        }

        if(df_dataspecs$dataformat == "dataformat_columns"){

          # Save total data
          df_shiny$totaldata <- df_dataspecs$firstchanneldata

          # EDIT: different from non-timecourse data, add in column names from timepoint time (here)
          # and columns for reading name (here) and well name (step 5):

          # timepoints as column names:
          timepoints_colnames <- paste0("timepoint_", df_dataspecs$list_of_timepoints)
          colnames(df_shiny$totaldata) <- timepoints_colnames

          # reading name as 'channel' column:
          df_shiny$totaldata$channel <- df_dataspecs$channel_names # should just be one here

          # print("total data table:")
          # print(df_shiny$totaldata)

        }

      } else if(df_dataspecs$channel_number > 1){
        # (2) If >1 channel, totaldata is..

        temp_alldata <- df_shiny$alldata

        # (2a) Rows:
        if(df_dataspecs$dataformat == "dataformat_rows"){

          # print("data spacing:")
          # print(df_dataspecs$channeldataspacing)

          # Get data, but also add cols for channel and time

          ## Prevent crash when row/column indexes to use don't exist in df
          print("Last row number of requested data:")
          # print(row_numbers[length(row_numbers)]) # last row number of requested data (+all its timepoints)
          largest_rownumber_needed <- df_dataspecs$row_beg+(df_dataspecs$channel_number-1)*df_dataspecs$channeldataspacing+(df_dataspecs$timepoint_number-1)
          print(largest_rownumber_needed)
          print("Last row number of existing data:")
          print(nrow(temp_alldata)) # last row number of existing data
          if(nrow(temp_alldata) < largest_rownumber_needed){
            # if we're requesting data outside the alldata df

            # Console
            message("Error: Do not request data from outside range of file.")
            message(paste0("Requested data up to row #", largest_rownumber_needed))
            message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

            # Modal
            showModal(modalDialog(title = "Error",
                                  paste0("Do not request data from outside range of file. ",
                                         "[Requested data up to row #", largest_rownumber_needed, ". ",
                                         "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                  easyClose = TRUE ))

            return()
          }

          df_shiny$totaldata <- c()
          for(i in 1:df_dataspecs$channel_number){

            # find first row of data for current reading:
            firstrownumber <- df_dataspecs$row_beg + (i-1)*df_dataspecs$channeldataspacing

            # extract data for current reading:
            temp_channeldata <- temp_alldata[(firstrownumber):(firstrownumber+df_dataspecs$timepoint_number-1), # rows
                                             df_dataspecs$col_beg:df_dataspecs$col_end] # cols

            # EDIT: different from non-timecourse data, add in column names from well name (step 5)
            # and add in columns for reading name and timepoint time (here):

            # # make temp name for wells (not essential)
            # temp_colnames <- seq(from = 1, to = ncol(temp_channeldata), by = 1)
            # temp_colnames <- paste0("well_", temp_colnames)
            # colnames(temp_channeldata) <- temp_colnames

            # reading name as 'channel' column:
            temp_channeldata$channel <- df_dataspecs$channel_names[i]

            # timepoints as 'time' column:
            timepoints_df <- data.frame(time = df_dataspecs$list_of_timepoints)
            temp_channeldata <- cbind(temp_channeldata, timepoints_df)

            # bind data for current reading to final totaldata df:
            df_shiny$totaldata <- rbind(df_shiny$totaldata, temp_channeldata)
          }

          # print("total data table:")
          # print(df_shiny$totaldata)

        } # rows

        # (2b) Columns:
        if(df_dataspecs$dataformat == "dataformat_columns"){

          # print("data spacing:")
          # print(df_dataspecs$channeldataspacing)

          # Get data - but also add cols for channel and well
          # correct version = exactly like rows version above. but for cols.

          ## Prevent crash when row/column indexes to use don't exist in df
          print("Last col number of requested data:")
          largest_colnumber_needed <- df_dataspecs$col_beg+(df_dataspecs$channel_number-1)*df_dataspecs$channeldataspacing+(df_dataspecs$timepoint_number-1)
          print(largest_colnumber_needed)
          print("Last col number of existing data:")
          print(ncol(temp_alldata)) # last col number of existing data
          if(ncol(temp_alldata) < largest_colnumber_needed){
            # if we're requesting data outside the alldata df

            # Console
            message("Error: Do not request data from outside range of file.")
            message(paste0("Requested data up to col #", largest_colnumber_needed))
            message(paste0("Existing data's highest col number: #", ncol(temp_alldata)))

            # Modal
            showModal(modalDialog(title = "Error",
                                  paste0("Do not request data from outside range of file. ",
                                         "[Requested data up to col #", largest_colnumber_needed, ". ",
                                         "Existing data's highest col number: #", ncol(temp_alldata), ".]"),
                                  easyClose = TRUE ))

            return()
          }

          df_shiny$totaldata <- c()
          for(i in 1:df_dataspecs$channel_number){

            # find first col of data for current reading:
            firstcolnumber <- df_dataspecs$col_beg + (i-1)*df_dataspecs$channeldataspacing

            # extract data for current reading:
            temp_channeldata <- temp_alldata[df_dataspecs$row_beg:df_dataspecs$row_end, (firstcolnumber):(firstcolnumber+df_dataspecs$timepoint_number-1)]

            # EDIT: different from non-timecourse data, add in column names from timepoint time (here)
            # and columns for reading name (here) and well name (step 5):

            # timepoints as column names:
            timepoints_colnames <- paste0("timepoint_", df_dataspecs$list_of_timepoints)
            temp_channeldata <- as.data.frame(temp_channeldata) # required for 1 line data from 1 timepoint data (else crashes)
            colnames(temp_channeldata) <- timepoints_colnames

            # reading name as 'channel' column:
            temp_channeldata$channel <- df_dataspecs$channel_names[i]

            # # make temp name for wells (not essential)
            # temp_wellnames <- seq(from = 1, to = nrow(temp_channeldata), by = 1)
            # temp_wellnames <- paste0("well_", temp_wellnames)
            # temp_channeldata$well <- temp_wellnames

            # bind to final df:
            df_shiny$totaldata <- rbind(df_shiny$totaldata, temp_channeldata)

          }

          # print("total data table:")
          # print(df_shiny$totaldata)

        } # columns

        # (2c) Matrix - not avail for timecourse data

      } # channel number > 1

    } # timecourse

    # # Console checks
    # print("total data table:")
    # print(df_shiny$totaldata)

    # Show Cropped Data Tab (tab is now visible, but isn't automatically selected)
    showTab(inputId = "byop_mainpaneldata_tabset", target = "rawdata_cropped_tab", select = FALSE)

  })
  output$channeldataspacing_printed <- renderPrint({ cat(df_dataspecs$channeldataspacing) })

  #

  # Step 5 - Well numbering -------------------------------------------------------------------------------------
  observeEvent(input$submit_readingorientation_button, { # update whenever Step5 Confirm button is pressed # CORRECT

    if(input$step5_checkbox_button %%2 == 1){ # if checkbox button is checked/locked (clicked an odd number of times)
      # do nothing if step already complete
      message("Error: Section marked complete.")
      showModal(modalDialog(title = "Error", "Section marked complete.", easyClose = TRUE ))
      return()
    }

    # Check previous steps completed
    if(input$step1_checkbox_button %%2 == 0 | input$step2_checkbox_button %%2 == 0 |
       input$step3_checkbox_button %%2 == 0 | input$step4_checkbox_button %%2 == 0){ # if checkbox button is unchecked/locked (clicked an even number of times)
      # do nothing if previous steps incomplete
      message("Error: Previous sections marked incomplete.")
      showModal(modalDialog(title = "Error", "Previous sections marked incomplete.", easyClose = TRUE ))
      # df_dataspecs$starting_well <- NULL
      # df_dataspecs$readingorientation <- NULL
      # df_dataspecs$used_wells <- NULL
      # df_shiny$totaldata <- NULL
      return()
    }

    # Check Matrix values respected
    if( (df_dataspecs$dataformat == "dataformat_matrix") & (input$starting_well != "A1") ){
      message("Error: Matrix format requires Starting Well = 'A1'.")
      showModal(modalDialog(title = "Error", "Matrix format requires Starting Well = 'A1'.", easyClose = TRUE ))
      df_dataspecs$well_data_specification <- NULL ### save_parser
      df_dataspecs$well_data_indices <- NULL ### save_parser
      df_dataspecs$starting_well <- NULL
      df_dataspecs$readingorientation <- NULL
      df_dataspecs$used_wells <- NULL
      df_shiny$totaldata <- NULL
      return()
    }

    # Work out which wells were used ----------

    # Number of wells:
    # (2a) Rows:
    if(df_dataspecs$dataformat == "dataformat_rows"){
      n_wells <- df_dataspecs$col_end - df_dataspecs$col_beg + 1
    }
    # (2b) Columns:
    if(df_dataspecs$dataformat == "dataformat_columns"){
      n_wells <- df_dataspecs$row_end - df_dataspecs$row_beg + 1
    }
    # (2c) Matrix:
    if(df_dataspecs$dataformat == "dataformat_matrix"){
      n_wells <- 96
    }
    print("n_wells:")
    print(n_wells)

    # # Starting well: ### well: moved down into "not custom" section
    # df_dataspecs$starting_well <- input$starting_well # save value # may not need this bc don't need it in future steps
    # print("starting_well:")
    # print(df_dataspecs$starting_well)

    # Reading orientation:
    df_dataspecs$readingorientation <- input$readingorientation # save value # may not need this bc don't need it in future steps
    print("readingorientation:")
    print(df_dataspecs$readingorientation)

    # reading orientation presets ### well ----
    if(df_dataspecs$readingorientation == "A1->A12"){

      # # list of wells
      # listofwells <- c("A01", "A02", "A03", "A04", "A05", "A06", "A07", "A08", "A09", "A10", "A11", "A12",
      #                  "B01", "B02", "B03", "B04", "B05", "B06", "B07", "B08", "B09", "B10", "B11", "B12",
      #                  "C01", "C02", "C03", "C04", "C05", "C06", "C07", "C08", "C09", "C10", "C11", "C12",
      #                  "D01", "D02", "D03", "D04", "D05", "D06", "D07", "D08", "D09", "D10", "D11", "D12",
      #                  "E01", "E02", "E03", "E04", "E05", "E06", "E07", "E08", "E09", "E10", "E11", "E12",
      #                  "F01", "F02", "F03", "F04", "F05", "F06", "F07", "F08", "F09", "F10", "F11", "F12",
      #                  "G01", "G02", "G03", "G04", "G05", "G06", "G07", "G08", "G09", "G10", "G11", "G12",
      #                  "H01", "H02", "H03", "H04", "H05", "H06", "H07", "H08", "H09", "H10", "H11", "H12")

      # list of wells
      listofwells <- c("A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10", "A11", "A12",
                       "B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "B9", "B10", "B11", "B12",
                       "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10", "C11", "C12",
                       "D1", "D2", "D3", "D4", "D5", "D6", "D7", "D8", "D9", "D10", "D11", "D12",
                       "E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "E10", "E11", "E12",
                       "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
                       "G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10", "G11", "G12",
                       "H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8", "H9", "H10", "H11", "H12")

    }
    if(df_dataspecs$readingorientation == "A1->H1"){

      # # list of wells
      # listofwells <- c("A01", "B01", "C01", "D01", "E01", "F01", "G01", "H01",
      #                  "A02", "B02", "C02", "D02", "E02", "F02", "G02", "H02",
      #                  "A03", "B03", "C03", "D03", "E03", "F03", "G03", "H03",
      #                  "A04", "B04", "C04", "D04", "E04", "F04", "G04", "H04",
      #                  "A05", "B05", "C05", "D05", "E05", "F05", "G05", "H05",
      #                  "A06", "B06", "C06", "D06", "E06", "F06", "G06", "H06",
      #                  "A07", "B07", "C07", "D07", "E07", "F07", "G07", "H07",
      #                  "A08", "B08", "C08", "D08", "E08", "F08", "G08", "H08",
      #                  "A09", "B09", "C09", "D09", "E09", "F09", "G09", "H09",
      #                  "A10", "B10", "C10", "D10", "E10", "F10", "G10", "H10",
      #                  "A11", "B11", "C11", "D11", "E11", "F11", "G11", "H11",
      #                  "A12", "B12", "C12", "D12", "E12", "F12", "G12", "H12")

      # list of wells
      listofwells <- c("A1", "B1", "C1", "D1", "E1", "F1", "G1", "H1",
                       "A2", "B2", "C2", "D2", "E2", "F2", "G2", "H2",
                       "A3", "B3", "C3", "D3", "E3", "F3", "G3", "H3",
                       "A4", "B4", "C4", "D4", "E4", "F4", "G4", "H4",
                       "A5", "B5", "C5", "D5", "E5", "F5", "G5", "H5",
                       "A6", "B6", "C6", "D6", "E6", "F6", "G6", "H6",
                       "A7", "B7", "C7", "D7", "E7", "F7", "G7", "H7",
                       "A8", "B8", "C8", "D8", "E8", "F8", "G8", "H8",
                       "A9", "B9", "C9", "D9", "E9", "F9", "G9", "H9",
                       "A10", "B10", "C10", "D10", "E10", "F10", "G10", "H10",
                       "A11", "B11", "C11", "D11", "E11", "F11", "G11", "H11",
                       "A12", "B12", "C12", "D12", "E12", "F12", "G12", "H12")

    }

    if(df_dataspecs$readingorientation != "custom"){ ### well

      # save well data specification - fixed or selected
      df_dataspecs$well_data_specification <- "fixed" ### save_parser
      df_dataspecs$well_data_indices <- NULL ### save_parser

      # Starting well: ### well: moved from above
      df_dataspecs$starting_well <- input$starting_well # save value # may not need this bc don't need it in future steps
      print("starting_well:")
      print(df_dataspecs$starting_well)

      # Which wells of the listofwells are the used wells? ### well: moved from below
      starting_well_idx <- which(listofwells == df_dataspecs$starting_well)
      print("starting_well_idx:")
      print(starting_well_idx)
      df_dataspecs$used_wells <- listofwells[starting_well_idx:(starting_well_idx+n_wells-1)]
      print("used wells:")
      print(df_dataspecs$used_wells)

    } ### well

    # reading orientation custom ### well ----
    if(df_dataspecs$readingorientation == "custom"){

      # save well data specification - fixed or select
      df_dataspecs$well_data_specification <- "selected" ### save_parser

      all_selected_cells <- input$RawDataTable_cells_selected

      if(nrow(input$RawDataTable_cells_selected) != 2){
        # do nothing until there are selections
        message("Error: Select two cells.")
        showModal(modalDialog(title = "Error", "Select two cells.", easyClose = TRUE ))
        df_dataspecs$well_data_specification <- NULL ### save_parser
        df_dataspecs$well_data_indices <- NULL ### save_parser
        df_dataspecs$starting_well <- NULL
        df_dataspecs$readingorientation <- NULL
        df_dataspecs$used_wells <- NULL
        df_shiny$totaldata <- NULL
        return()
      }

      # take lowest&highest row numbers (regardless of click order or if topleft-bottomright conventions were followed)
      # by def, all_selected_cells will be a 2by2 matrix
      row_beg <- min(all_selected_cells[1,1], all_selected_cells[2,1])
      row_end <- max(all_selected_cells[1,1], all_selected_cells[2,1])
      col_beg <- min(all_selected_cells[1,2], all_selected_cells[2,2])+1 # +1 as cols start at 0 for some reason
      col_end <- max(all_selected_cells[1,2], all_selected_cells[2,2])+1 # +1 as cols start at 0 for some reason

      # save well indices ### save_parser
      df_dataspecs$well_data_indices <- c(row_beg, row_end, col_beg, col_end)

      if(df_dataspecs$dataformat == "dataformat_rows"){ # if data in rows, then well names will form a row

        # stop if selection is >1 rows
        if(row_beg != row_end){
          message("Error: Select only 1 row.")
          showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
          df_dataspecs$well_data_specification <- NULL ### save_parser
          df_dataspecs$well_data_indices <- NULL ### save_parser
          df_dataspecs$starting_well <- NULL
          df_dataspecs$readingorientation <- NULL
          df_dataspecs$used_wells <- NULL
          df_shiny$totaldata <- NULL
          return()
        }

        # stop if selection is wrong length
        if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_spectrum"){
          if( (col_end-col_beg+1) != ncol(df_shiny$totaldata) ){
            # for std data, 'width' of column of wells should be equal to 'width' of data
            message("Error: Number of selected wells does not match the number of columns of selected data.")
            showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of columns of selected data.", easyClose = TRUE ))
            df_dataspecs$well_data_specification <- NULL ### save_parser
            df_dataspecs$well_data_indices <- NULL ### save_parser
            df_dataspecs$starting_well <- NULL
            df_dataspecs$readingorientation <- NULL
            df_dataspecs$used_wells <- NULL
            df_shiny$totaldata <- NULL
            return()
          }
        } else if(df_dataspecs$datatype == "datatype_timecourse"){

          if( (col_end-col_beg+1) != (ncol(df_shiny$totaldata)-2) ){
            # for timecourse data, 'width' of column of wells should be equal to ('width' of data)-2 [minus channel and time columns]
            # NB Note this is different from COLUMN-format data, where columns are ('height' of data)*(number of channels)
            message("Error: Number of selected wells does not match the number of columns of selected data.")
            showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of columns of selected data.", easyClose = TRUE ))
            df_dataspecs$well_data_specification <- NULL ### save_parser
            df_dataspecs$well_data_indices <- NULL ### save_parser
            df_dataspecs$starting_well <- NULL
            df_dataspecs$readingorientation <- NULL
            df_dataspecs$used_wells <- NULL
            df_shiny$totaldata <- NULL
            return()
          }
        }

        # SAVE DATA
        if(col_end != col_beg){ # if we have several columns, it will form a df naturally
          listofwells <- as.character(df_shiny$alldata[row_beg:row_end, col_beg:col_end]) # as array, not df
        } else if(col_end == col_beg) { # if we have a single column, we need to force a dataframe
          listofwells <- as.character(v1 = df_shiny$alldata[row_beg:row_end, col_beg:col_end]) # as array, not df
        }

      } # rows

      if(df_dataspecs$dataformat == "dataformat_columns"){ # if data in columns, then well names will form a column

        # stop if selection is >1 rows
        if(col_beg != col_end){
          message("Error: Select only 1 column.")
          showModal(modalDialog(title = "Error", "Select only 1 column.", easyClose = TRUE ))
          df_dataspecs$well_data_specification <- NULL ### save_parser
          df_dataspecs$well_data_indices <- NULL ### save_parser
          df_dataspecs$starting_well <- NULL
          df_dataspecs$readingorientation <- NULL
          df_dataspecs$used_wells <- NULL
          df_shiny$totaldata <- NULL
          return()
        }

        # stop if selection is wrong length
        if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_spectrum"){
          if( (row_end-row_beg+1) != nrow(df_shiny$totaldata) ){
            # for std data, 'height' of column of wells should be equal to 'height' of data
            message("Error: Number of selected wells does not match the number of rows of selected data.")
            showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of rows of selected data.", easyClose = TRUE ))
            df_dataspecs$well_data_specification <- NULL ### save_parser
            df_dataspecs$well_data_indices <- NULL ### save_parser
            df_dataspecs$starting_well <- NULL
            df_dataspecs$readingorientation <- NULL
            df_dataspecs$used_wells <- NULL
            df_shiny$totaldata <- NULL
            return()
          }
        } else if(df_dataspecs$datatype == "datatype_timecourse"){
          if( ((row_end-row_beg+1)*df_dataspecs$channel_number) != (nrow(df_shiny$totaldata)) ){
            # for timecourse data, ('height' of column of wells)*(number of channels) should be equal to the total 'height' of the Cropped data) (aka totaldata)
            # NB Note this is different from ROW-format data, where columns are wells+2
            message("Error: Number of selected wells does not match the number of rows of selected data.")
            showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of rows of selected data.", easyClose = TRUE ))
            df_dataspecs$well_data_specification <- NULL ### save_parser
            df_dataspecs$well_data_indices <- NULL ### save_parser
            df_dataspecs$starting_well <- NULL
            df_dataspecs$readingorientation <- NULL
            df_dataspecs$used_wells <- NULL
            df_shiny$totaldata <- NULL
            return()
          }
        }

        # SAVE DATA
        listofwells <- df_shiny$alldata[row_beg:row_end, col_beg:col_end] # works. not list or df, but probably an array here

      }

      # # Checks ### well: remove because custom could start 'C01' or 'well_15'
      # if(!any(grepl(df_dataspecs$starting_well, listofwells))){
      #   # if any of the wells matches starting well, TRUE
      #   # ! negates it, so if() fires when NONE of wells match starting well
      #   message("Error: Selected wells does not contain named starting well.")
      #   showModal(modalDialog(title = "Error", "Selected wells does not contain named starting well.", easyClose = TRUE ))
      #   df_dataspecs$starting_well <- NULL
      #   df_dataspecs$readingorientation <- NULL
      #   df_dataspecs$used_wells <- NULL
      #   df_shiny$totaldata <- NULL
      #   return()
      #   # [] This judges "A11" as containing "A1". Think about later.
      # }

      # Which wells of the listofwells are the used wells? ### well: moved from below
      # starting_well_idx is first cell selected: removed 'searching' for starting_well_idx in listofwells
      # df_dataspecs$used_wells <- listofwells[starting_well_idx:(starting_well_idx+n_wells-1)]
      df_dataspecs$used_wells <- listofwells
      print("used wells:")
      print(df_dataspecs$used_wells)

    } # custom wells

    # # Which wells of the listofwells are the used wells? ### well: moved up into "not custom"
    # starting_well_idx <- which(listofwells == df_dataspecs$starting_well)
    # print("starting_well_idx:")
    # print(starting_well_idx)

    # # Checks for empty cells at beginning ### well: don't need if custom doesn't require specified starting well
    # if(df_dataspecs$readingorientation == "custom" & starting_well_idx != 1){
    #   # for custom wells, starting well MUST be first well
    #   # otherwise next line throws undefined columns error
    #   message("Error: Starting well must be first cell selected in Custom well selection.")
    #   showModal(modalDialog(title = "Error", "Starting well must be first cell selected in Custom well selection.", easyClose = TRUE ))
    #   df_dataspecs$starting_well <- NULL
    #   df_dataspecs$readingorientation <- NULL
    #   df_dataspecs$used_wells <- NULL
    #   df_shiny$totaldata <- NULL
    #   return()
    # }

    # ### well: moved up into "not custom"
    # df_dataspecs$used_wells <- listofwells[starting_well_idx:(starting_well_idx+n_wells-1)]
    # print("used wells:")
    # print(df_dataspecs$used_wells)

    # Checks for empty cells (couldn't do above as "" catches evthg, whereas here empty cells are now NA)
    if(any(is.na(df_dataspecs$used_wells))){
      # if any of the wells is NA, stop (apart from anything all the NAs end up at the end of the list)
      message("Error: Well name selection cannot contain empty cells.")
      showModal(modalDialog(title = "Error", "Well name selection cannot contain empty cells.", easyClose = TRUE ))
      df_dataspecs$well_data_specification <- NULL ### save_parser
      df_dataspecs$well_data_indices <- NULL ### save_parser
      df_dataspecs$starting_well <- NULL
      df_dataspecs$readingorientation <- NULL
      df_dataspecs$used_wells <- NULL
      df_shiny$totaldata <- NULL
      return()
    }

    # Add well/channel/timepoint numbering to totaldata -------

    # (a) Rows:
    if(df_dataspecs$dataformat == "dataformat_rows"){

      if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_spectrum"){

        # if data is in rows, wells are in columns.
        # so wells need to be the column names
        colnames(df_shiny$totaldata) <- df_dataspecs$used_wells
        rownames(df_shiny$totaldata) <- df_dataspecs$channel_names # fails for timecourse bc there are rows for each timepoint

      } else if(df_dataspecs$datatype == "datatype_timecourse"){

        ## timecourse - rows - 1 channel and >1 channel

        # changes from standard data version:
        # colnames(df_shiny$totaldata) <- df_dataspecs$used_wells # yes but include the two new columns (see below)
        # rownames(df_shiny$totaldata) <- df_dataspecs$channel_names # no need for rownames

        colnames(df_shiny$totaldata) <- c(df_dataspecs$used_wells, "channel", "time")

      } # timecourse
    } # rows

    # (b) Columns:
    if(df_dataspecs$dataformat == "dataformat_columns"){

      if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_spectrum"){

        # if data is in columns., wells are in rows.
        # so wells need to be the row names
        rownames(df_shiny$totaldata) <- df_dataspecs$used_wells
        colnames(df_shiny$totaldata) <- df_dataspecs$channel_names

      } else if(df_dataspecs$datatype == "datatype_timecourse"){

        ## timecourse - cols - 1 or >1 channel

        # changes from standard data version:
        # rownames(df_shiny$totaldata) <- df_dataspecs$used_wells # replace rownames with "well" column - see below
        # colnames(df_shiny$totaldata) <- df_dataspecs$channel_names # skip

        wells_column <- rep(df_dataspecs$used_wells, df_dataspecs$channel_number) # repeat wells list as many times as channels
        df_shiny$totaldata["well"] <- wells_column

      } # timecourse

    } # columns

    # (c) Matrix (like Rows):
    if(df_dataspecs$dataformat == "dataformat_matrix"){

      # if data is in rows, wells are in columns.
      # so wells need to be the column names
      colnames(df_shiny$totaldata) <- df_dataspecs$used_wells
      rownames(df_shiny$totaldata) <- df_dataspecs$channel_names

    } # matrix

    # print("totaldata:")
    # print(df_shiny$totaldata)
    print("well data specification:") ### save_parser
    print(df_dataspecs$well_data_specification)
    print("well data indices:") ### save_parser
    print(df_dataspecs$well_data_indices)

  }) # step5 well numbering
  output$starting_well_printed <- renderPrint({ cat(df_dataspecs$starting_well) })
  output$readingorientation_printed <- renderPrint({ cat(df_dataspecs$readingorientation) })
  output$used_wells_printed <- renderPrint({ cat(df_dataspecs$used_wells) })

  #

  # Step 6 - Add metadata -------------------------------------------------------------------------------------

  # Doesn't need any more than the upload metadata section (above) and the View Metadata button (above)
  # Later - Could add checks here that catches if metadata fails to include certain columns.

  #

  # Step 7 - Parse Data -------------------------------------------------------------------------------------

  observeEvent(input$submit_parsedata_button, { # update whenever Step6 Confirm button is pressed

    if(input$step1_checkbox_button %%2 == 0 | input$step2_checkbox_button %%2 == 0 |
       input$step3_checkbox_button %%2 == 0 | input$step4_checkbox_button %%2 == 0 |
       input$step4_checkbox_button %%2 == 0 | input$step6_checkbox_button %%2 == 0){
      # if checkbox buttons are unchecked/unlocked (clicked an even number of times)
      message("Error: Mark all sections as complete before proceeding.")
      showModal(modalDialog(title = "Error", "Mark all sections as complete before proceeding.", easyClose = TRUE ))
      return()
    }

    # # Check that metadata has 'well' column ### matrix format: moved down
    # if( (isFALSE(df_shiny$metadata_skip)) ### meta
    #     & (!any(grepl("well", colnames(df_shiny$metadata)))) ){ ### R CMD check doesn't like the fact that I assume a well column. But there's a check here!
    #   message("Error: Can't merge Data and Metadata when Metadata does not contain a 'well' column.")
    #   showModal(modalDialog(title = "Error", "Can't merge Data and Metadata when Metadata does not contain a 'well' column.", easyClose = TRUE ))
    #   return()
    # }

    ## PARSE
    if(df_dataspecs$datatype == "datatype_standard" | df_dataspecs$datatype == "datatype_spectrum"){

      # 1. Make data block - format: wells in (96) rows, channels in columns
      # Add well numbering to totaldata
      # (a) Rows and (c) Matrices:
      if(df_dataspecs$dataformat == "dataformat_rows" | df_dataspecs$dataformat == "dataformat_matrix"){

        # data in rows, wells as columns

        # Remove Overflow text
        datablock <- sapply(df_shiny$totaldata, function(x) as.numeric(x) )

        if(df_dataspecs$channel_number == 1){

          # Transpose - so wells are in rows
          # Std data * one channel = "numeric", not df.
          # Forcing a df here didn't enable a transpose below. It instead caused a transpose by itself.
          datablock <- data.frame(v1 = datablock) # well colnames DO turn into rownames # but channel rownames DO NOT turn into colnames

        } else {

          # Transpose - so wells are in rows
          datablock <- t(datablock) # well colnames DO turn into rownames # but channel rownames DO NOT turn into colnames

          # Sapply / Transpose turns df into matrix. Switch back.
          datablock <- as.data.frame(datablock)

        }

        # Channels as column names
        colnames(datablock) <- df_dataspecs$channel_names # populate colnames

        # Wells from rownames to column
        datablock$well <- rownames(datablock) # make column from rownames
        rownames(datablock) <- NULL
        datablock <- datablock %>%
          dplyr::relocate(well) # make well the first column

      } # rows
      # (b) Columns:
      if(df_dataspecs$dataformat == "dataformat_columns"){

        # data in columns, wells as rows

        # Remove Overflow text
        datablock <- sapply(df_shiny$totaldata, function(x) as.numeric(x) )
        # well rownames ARE NOT retained in Parsed Data, but channel colnames ARE retained in Parsed Data

        # Sapply turns df into matrix. Switch back.
        datablock <- as.data.frame(datablock)

        # Channels as column names # already there

        # Wells as a new column
        datablock$well <- df_dataspecs$used_wells
        # rownames(datablock) <- NULL
        datablock <- datablock %>%
          dplyr::relocate(well) # make well the first column

      } # cols

    } else if(df_dataspecs$datatype == "datatype_timecourse"){

      # 1. Make data block - format: wells in (96) rows, channels in columns [ie. similar to columns format]
      # Add well numbering to totaldata [done already for timecourse]
      # (a) Rows
      if(df_dataspecs$dataformat == "dataformat_rows"){ # [matrix format doesn't exist for timecourse data]

        # data in rows, wells as columns [plus channel and time cols at end]

        # Pivot first
        # get wells down from colnames
        datablock <- df_shiny$totaldata %>%
          tidyr::pivot_longer(cols = -c("channel", "time"), names_to = "well", values_to = "value")

        # make value column numeric (it's 'character' bc of overflow wells)
        datablock <- datablock %>%
          dplyr::mutate_at(c("value"), as.numeric) # mutate() by itself fails. this works. https://www.statology.org/convert-multiple-columns-to-numeric-dplyr/

        # put channels as colnames
        datablock <- datablock %>%
          tidyr::pivot_wider(names_from = "channel", values_from = "value")

      } else if(df_dataspecs$dataformat == "dataformat_columns"){
        # (b) Columns:

        # data in columns, wells as rows

        # make numeric first - as mixture of numeric/character columns cannot be pivoted
        # then pivot - get timepoints down from colnames
        datablock <- df_shiny$totaldata %>%
          # dplyr::mutate_at(-c("channel", "well"), as.numeric) %>% # mutate() by itself fails. this works. https://www.statology.org/convert-multiple-columns-to-numeric-dplyr/
          dplyr::mutate_at(dplyr::vars(-c("channel", "well")), as.numeric) %>% # mutate_at(-c("channel", "well"), as.numeric) failed here
          tidyr::pivot_longer(cols = -c("channel", "well"), names_to = "time",
                              names_prefix = "timepoint_", values_to = "value")

        # put channels as colnames
        datablock <- datablock %>%
          tidyr::pivot_wider(names_from = "channel", values_from = "value")

      }

    } # timecourse

    # print("datablock current:")
    # print(datablock)

    ## Bind with plate layout metadata
    if( (input$metadata_input == 1 & isFALSE(df_shiny$metadata_skip))
        | input$metadata_input == 2){ ### meta
      # if we're uploading example metadata, and we have not selected "skip metadata"
      # or if we're uploading new metadata

      # Identify metadata format ### matrix format
      if(input$metadata_input == 1 & !grepl("matrix", input$select_examplemetadata)){
        # if we're uploading example metadata, and the metadata is in tidy format
        metadata_format <- "tidy"
      }
      if(input$metadata_input == 1 & grepl("matrix", input$select_examplemetadata)){
        # if we're uploading example metadata, and the metadata is in matrix format
        metadata_format <- "matrix"
      }
      if(input$metadata_input == 2 & input$metadata_format == "tidy"){
        # if we're uploading new metadata, and the metadata is in tidy format
        metadata_format <- "tidy"
      }
      if(input$metadata_input == 2 & input$metadata_format == "matrix"){
        # if we're uploading new metadata, and the metadata is in matrix format
        metadata_format <- "matrix"
      }

      # Parse data, depending on metadata format ### matrix format
      if(metadata_format == "tidy"){ # standard parsing

        # Check that metadata has 'well' column
        if( (isFALSE(df_shiny$metadata_skip)) ### meta
            & (!any(grepl("well", colnames(df_shiny$metadata)))) ){ ### R CMD check doesn't like the fact that I assume a well column. But there's a check here!
          # message("Error: Can't merge Data and Metadata when Metadata does not contain a 'well' column.")
          # showModal(modalDialog(title = "Error", "Can't merge Data and Metadata when Metadata does not contain a 'well' column.", easyClose = TRUE ))

          message("Error: Can't merge Data and tidy Metadata if Metadata does not contain a 'well' column.
                  Verify that the Metadata is in tidy format. If so, add a 'well' column.
                  If it is in matrix format, select 'Matrix format' in the Metadata upload section above, click Submit to reupload the Metadata, before retrying the Parsing.") ### matrix format
          showModal(modalDialog(title = "Error", "Can't merge Data and Metadata when Metadata does not contain a 'well' column.
                                Verify that Metadata is in tidy format. If so, add a 'well' column.
                                If it is in matrix format, select 'Matrix format' in the Metadata upload section above, click Submit to reupload the Metadata, before retrying the Parsing.",
                                easyClose = TRUE )) ### matrix format
          return()
        }
        parseddata <- dplyr::left_join(df_shiny$metadata, datablock, by = "well")
        ### R CMD check doesn't like the fact that I assume a well column. But there's a check at the top!

      }

      if(metadata_format == "matrix"){ # matrix parsing

        # parse with matrix format metadata with plater ### matrix format
        metadata_tidy <- read_matrixformat_metadata(data = df_shiny$metadata, well_ids_column = "well")
        metadata_tidy

        parseddata <- dplyr::left_join(metadata_tidy, datablock, by = "well")
        ### R CMD check doesn't like the fact that I assume a well column. But there's a check at the top!
      }

      ## Make row and column columns
      parseddata$row <- substr(x = parseddata$well, start = 1, stop = 1)
      parseddata$column <- as.numeric(substr(x = parseddata$well, start = 2, stop = nchar(parseddata$well)))
      parseddata <- dplyr::arrange_at(parseddata, dplyr::vars(.data$row, .data$column))

    } else {

      ## Skip metadata joining, and simply return tidied dataframe ### meta
      parseddata <- datablock

    } ### meta


    # SAVE
    df_shiny$parseddata <- parseddata # to save and to display as DT

    # # Switch View to Parsed Data
    # updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "parseddata_tab")

    # Show Parsed data Tab (tab is now visible, AND is automatically selected)
    showTab(inputId = "byop_mainpaneldata_tabset", target = "parseddata_tab", select = TRUE)

  })

  # Reset all -------------------------------------------------------------------------------------

  observeEvent(input$reset_dataspecs_button, {

    withProgress(message = 'Clearing data...', value = 0, {

      # Reset dataspecs
      # step1
      df_dataspecs$datatype = NULL
      df_dataspecs$dataformat = NULL
      # [] update checkbox button to even?
      # updateCheckboxInput(session, inputId = "step1_checkbox", value = FALSE) # uncheck checkbox (if it was marked complete before)

      # step2
      df_dataspecs$channel_number = NULL
      df_dataspecs$channel_names = NULL
      df_dataspecs$wav_min = NULL
      df_dataspecs$wav_max = NULL
      df_dataspecs$wav_interval = NULL
      # [] update checkbox button to even?

      # step2b
      df_dataspecs$timecourse_firsttimepoint = NULL
      df_dataspecs$timecourse_duration = NULL
      df_dataspecs$timecourse_interval = NULL
      df_dataspecs$timepoint_number_expected = NULL
      df_dataspecs$timepoint_number = NULL # worked out version
      df_dataspecs$list_of_timepoints = NULL

      # step3
      df_dataspecs$matrixformat = NULL
      df_dataspecs$firstchanneldata = NULL
      df_dataspecs$row_beg = NULL
      df_dataspecs$row_end = NULL
      df_dataspecs$col_beg = NULL
      df_dataspecs$col_end = NULL
      # [] update checkbox button to even?

      # step4
      df_dataspecs$channeldataspacing = NULL
      # [] update checkbox button to even?

      # step5
      df_dataspecs$starting_well = NULL
      df_dataspecs$readingorientation = NULL
      df_dataspecs$used_wells = NULL
      # [] update checkbox button to even?

      # step6
      # [] update checkbox button to even?

      # [] Update selectInputs?

      # RESET 'EDITED' DATASETS
      # leave raw data as is
      df_shiny$totaldata = NULL # totaldata is sum total of all cells in alldata that represents numerical data (rather than empty space/metadata)
      df_shiny$parseddata = NULL

    }) # end withprogress

  })

  #

  # View Buttons -------------------------------------------------------------------------------------

  # Start Building Parser button
  observeEvent(input$start_building_button, {
    # View Raw Data
    updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
  })

  # View 1
  observeEvent(input$view_dataspecs_button1, {
    # View Raw Data <-> Data Specs
    if( (input$view_dataspecs_button1 %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "dataspecs_tab")
    }
  })
  # View 2
  observeEvent(input$view_dataspecs_button2, {
    # View Raw Data <-> Data Specs
    if( (input$view_dataspecs_button2 %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "dataspecs_tab")
    }
  })
  # View 2B
  observeEvent(input$view_dataspecs_button2b, {
    # View Raw Data <-> Data Specs
    if( (input$view_dataspecs_button2b %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "dataspecs_tab")
    }
  })
  # View 3
  observeEvent(input$view_dataspecs_button3, {
    # View Raw Data <-> Cropped
    if( (input$view_dataspecs_button3 %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "dataspecs_tab") # rawdata_cropped_tab
    }
  })
  # View 4
  observeEvent(input$view_dataspecs_button4, {
    # View Raw Data <-> Cropped
    if( (input$view_dataspecs_button4 %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "dataspecs_tab") # rawdata_cropped_tab
    }
  })

  # View Cropped Data 4
  observeEvent(input$view_croppeddata_button4, {
    # View Raw Data <-> Cropped
    if( (input$view_croppeddata_button4 %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_cropped_tab")
    }
  })

  # View 5
  observeEvent(input$view_dataspecs_button5, {
    # View Raw Data <-> Cropped
    if( (input$view_dataspecs_button5 %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "dataspecs_tab") # rawdata_cropped_tab
    }
  })

  # View Cropped Data 5
  observeEvent(input$view_croppeddata_button5, {
    # View Raw Data <-> Cropped
    if( (input$view_croppeddata_button5 %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_cropped_tab")
    }
  })

  # View 6
  observeEvent(input$view_metadata_button, { # view_metadata_button # view_dataspecs_button6
    # View Raw Data <-> Metadata
    if( (input$view_metadata_button %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "rawdata_tab")
    } else {
      updateTabsetPanel(session, inputId = "byop_mainpaneldata_tabset", selected = "metadata_tab")
    }
  })

  # Checkbox buttons -----

  # Step 1
  observeEvent(input$step1_checkbox_button, {
    if( (input$step1_checkbox_button %% 2) == 0 ){ # n%%2 tests remainder when n is divided by 2. so evens = 0, odds = 1
      updateActionButton(session, inputId = "step1_checkbox_button", icon = icon("lock-open"))
    } else {
      updateActionButton(session, inputId = "step1_checkbox_button", icon = icon("lock"))
    }
  })
  # Step 2
  observeEvent(input$step2_checkbox_button, {
    if( (input$step2_checkbox_button %% 2) == 0 ){
      updateActionButton(session, inputId = "step2_checkbox_button", icon = icon("lock-open"))
    } else {
      updateActionButton(session, inputId = "step2_checkbox_button", icon = icon("lock"))
    }
  })
  # Step 2b
  observeEvent(input$step2b_checkbox_button, {
    if( (input$step2b_checkbox_button %% 2) == 0 ){
      updateActionButton(session, inputId = "step2b_checkbox_button", icon = icon("lock-open"))
    } else {
      updateActionButton(session, inputId = "step2b_checkbox_button", icon = icon("lock"))
    }
  })
  # Step 3
  observeEvent(input$step3_checkbox_button, {
    if( (input$step3_checkbox_button %% 2) == 0 ){
      updateActionButton(session, inputId = "step3_checkbox_button", icon = icon("lock-open"))
    } else {
      updateActionButton(session, inputId = "step3_checkbox_button", icon = icon("lock"))
    }
  })
  # Step 4
  observeEvent(input$step4_checkbox_button, {
    if( (input$step4_checkbox_button %% 2) == 0 ){
      updateActionButton(session, inputId = "step4_checkbox_button", icon = icon("lock-open"))
    } else {
      updateActionButton(session, inputId = "step4_checkbox_button", icon = icon("lock"))
    }
  })
  # Step 5
  observeEvent(input$step5_checkbox_button, {
    if( (input$step5_checkbox_button %% 2) == 0 ){
      updateActionButton(session, inputId = "step5_checkbox_button", icon = icon("lock-open"))
    } else {
      updateActionButton(session, inputId = "step5_checkbox_button", icon = icon("lock"))
    }
  })
  # Step 6
  observeEvent(input$step6_checkbox_button, {
    if( (input$step6_checkbox_button %% 2) == 0 ){
      updateActionButton(session, inputId = "step6_checkbox_button", icon = icon("lock-open"))
    } else {
      updateActionButton(session, inputId = "step6_checkbox_button", icon = icon("lock"))
    }
  })


  # DOWNLOAD CSV BUTTON ------

  output$download_table_CSV <- downloadHandler(
    filename <- function() {
      time <- format(Sys.time(), "%Y%m%d_%H.%M") # ie. "20190827_17.33"
      paste("data_parsedByParsley_", time, ".csv", sep = "")
    },
    content <- function(file) { # just leave in "file", this is default and does refer to your file that will be made
      df <- df_shiny$parseddata
      utils::write.csv(df, file, row.names = FALSE)
    },
    contentType = "text/csv" # from downloadHandler help page
  )

  # Tab2: SAVE and DOWNLOAD PARSER FUNCTION ### save_parser ------

  # Tab2: DATA SPECS ------

  # The parser function here is a list of input parameters stored in a reactiveValues list.
  tab2_df_dataspecs <- reactiveValues(

    # step1
    datatype = NULL,
    dataformat = NULL,

    # step2
    channel_name_specification = NULL, # fixed/selected
    channel_name_indices = NULL,
    channel_number = NULL,
    channel_names = NULL,
    wav_min = NULL, # [] not strictly needed
    wav_max = NULL, # not strictly needed
    wav_interval = NULL, # not strictly needed

    # step2b
    timecourse_specification = NULL, # fixed/selected
    timecourse_indices = NULL,
    # timecourse_firsttimepoint = NULL,
    # timecourse_duration = NULL,
    # timecourse_interval = NULL,
    # timepoint_number_expected = NULL,
    timepoint_number = NULL, # worked out version
    list_of_timepoints = NULL,

    # step3
    matrixformat = NULL,
    firstchanneldata = NULL, # don't transfer the data itself from saved parser, but work it out from row_beg...
    row_beg = NULL,
    row_end = NULL,
    col_beg = NULL,
    col_end = NULL,

    # step4
    channeldataspacing = NULL,

    # step5
    well_data_specification = NULL, # fixed/selected
    well_data_indices = NULL,
    # starting_well = NULL,
    # readingorientation = NULL,
    used_wells = NULL

  )

  # update inputs into 'saved' parser ----------------
  observeEvent(input$save_parser_button, {

    # save parser
    ## v4. one by one
    # step1
    tab2_df_dataspecs$datatype = df_dataspecs$datatype
    tab2_df_dataspecs$dataformat = df_dataspecs$dataformat

    # step2
    tab2_df_dataspecs$channel_name_specification = df_dataspecs$channel_name_specification
    tab2_df_dataspecs$channel_name_indices = df_dataspecs$channel_name_indices
    tab2_df_dataspecs$channel_number = df_dataspecs$channel_number
    tab2_df_dataspecs$channel_names = df_dataspecs$channel_names
    tab2_df_dataspecs$wav_min = df_dataspecs$wav_min
    tab2_df_dataspecs$wav_max = df_dataspecs$wav_max
    tab2_df_dataspecs$wav_interval = df_dataspecs$wav_interval

    # step2b
    tab2_df_dataspecs$timecourse_specification = df_dataspecs$timecourse_specification
    tab2_df_dataspecs$timecourse_indices = df_dataspecs$timecourse_indices
    # tab2_df_dataspecs$timecourse_firsttimepoint = df_dataspecs$timecourse_firsttimepoint
    # tab2_df_dataspecs$timecourse_duration = df_dataspecs$timecourse_duration
    # tab2_df_dataspecs$timecourse_interval = df_dataspecs$timecourse_interval
    # tab2_df_dataspecs$timepoint_number_expected = df_dataspecs$timepoint_number_expected
    tab2_df_dataspecs$timepoint_number = df_dataspecs$timepoint_number # worked out version
    tab2_df_dataspecs$list_of_timepoints = df_dataspecs$list_of_timepoints

    # step3
    tab2_df_dataspecs$matrixformat = df_dataspecs$matrixformat
    # tab2_df_dataspecs$firstchanneldata = df_dataspecs$firstchanneldata
    tab2_df_dataspecs$row_beg = df_dataspecs$row_beg
    tab2_df_dataspecs$row_end = df_dataspecs$row_end
    tab2_df_dataspecs$col_beg = df_dataspecs$col_beg
    tab2_df_dataspecs$col_end = df_dataspecs$col_end

    # step4
    tab2_df_dataspecs$channeldataspacing = df_dataspecs$channeldataspacing

    # step5
    tab2_df_dataspecs$well_data_specification = df_dataspecs$well_data_specification
    tab2_df_dataspecs$well_data_indices = df_dataspecs$well_data_indices
    # tab2_df_dataspecs$starting_well = df_dataspecs$starting_well
    # tab2_df_dataspecs$readingorientation = df_dataspecs$readingorientation
    tab2_df_dataspecs$used_wells = df_dataspecs$used_wells

    # Check parser function is complete
    current_parser_parameters <- reactiveValuesToList(tab2_df_dataspecs) # can wrap in isolate(). ?reactiveValuesToList
    current_parser_parameters
    check_parser_complete(parser_parameters = current_parser_parameters)

    # message("Parser function saved.")
    # print(paste0("tab2_df_dataspecs$datatype: ", tab2_df_dataspecs$datatype))

  })
  # confirm save
  output$save_parser_button_feedback1 <- renderPrint({ cat("Parser function created.") })
  output$save_parser_button_feedback2 <- renderPrint({ cat("Parser function updated.") })

  # switch tab
  observeEvent(input$switch_to_saved_parser_tab_button, {
    updateNavbarPage(session, inputId = "navbarpage", selected = "usp")
  })

  # download parser
  output$download_saved_parser <- downloadHandler(
    filename <- function() {
      time <- format(Sys.time(), "%Y%m%d_%H.%M") # ie. "20190827_17.33"
      # .RData file / RDS
      paste(time, "_saved_parser_function_for_Parsley.RDS", sep = "")
    },
    content <- function(file) { # just leave in "file", this is default and does refer to your file that will be made
      # .RDS file (1 R object) # saveRDS # .RData file (many R objects) # save
      saveRDS(tab2_df_dataspecs, file = file) # v3b. save reactivevalues directly
    },
    contentType = "text/plain" # from downloadHandler help page
  )

  # Tab2: Load Parser Function ### save_parser ------------------------------------------------------------

  # use example parser
  observeEvent(input$submit_exampleparser_button, {

    # Hide all tabs but Data Specs:
    # Hide raw data - unless it already exists
    if(is.null(tab2_df_shiny$alldata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")
    }
    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }
    # Hide Processed Data tabs
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")

    withProgress(message = 'Loading parser...', value = 0, {

      # RESET
      # Reset Parser
      ## v4
      tab2_df_dataspecs$datatype = NULL # to be flagged by check_parser_complete
      # Reset Processed Data
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL

      ##

      # LOAD
      # update parser parameters
      filepathtouse <- system.file("extdata", paste0(input$select_exampleparser, ".RDS"), package = "parsleyapp") ###

      ## v4. one by one
      temp_list <- readRDS(filepathtouse) # assign to reactivevalues
      # step1
      tab2_df_dataspecs$datatype = temp_list$datatype
      tab2_df_dataspecs$dataformat = temp_list$dataformat
      # step2
      tab2_df_dataspecs$channel_number = temp_list$channel_number
      tab2_df_dataspecs$channel_name_specification = temp_list$channel_name_specification
      tab2_df_dataspecs$channel_name_indices = temp_list$channel_name_indices
      tab2_df_dataspecs$channel_names = temp_list$channel_names
      tab2_df_dataspecs$wav_min = temp_list$wav_min
      tab2_df_dataspecs$wav_max = temp_list$wav_max
      tab2_df_dataspecs$wav_interval = temp_list$wav_interval
      # step2b
      tab2_df_dataspecs$timecourse_specification = temp_list$timecourse_specification
      tab2_df_dataspecs$timecourse_indices = temp_list$timecourse_indices
      # tab2_df_dataspecs$timecourse_firsttimepoint = temp_list$timecourse_firsttimepoint
      # tab2_df_dataspecs$timecourse_duration = temp_list$timecourse_duration
      # tab2_df_dataspecs$timecourse_interval = temp_list$timecourse_interval
      # tab2_df_dataspecs$timepoint_number_expected = temp_list$timepoint_number_expected
      tab2_df_dataspecs$timepoint_number = temp_list$timepoint_number # worked out version
      tab2_df_dataspecs$list_of_timepoints = temp_list$list_of_timepoints
      # step3
      tab2_df_dataspecs$matrixformat = temp_list$matrixformat
      # tab2_df_dataspecs$firstchanneldata = temp_list$firstchanneldata
      tab2_df_dataspecs$row_beg = temp_list$row_beg
      tab2_df_dataspecs$row_end = temp_list$row_end
      tab2_df_dataspecs$col_beg = temp_list$col_beg
      tab2_df_dataspecs$col_end = temp_list$col_end
      # step4
      tab2_df_dataspecs$channeldataspacing = temp_list$channeldataspacing
      # step5
      tab2_df_dataspecs$well_data_specification = temp_list$well_data_specification
      tab2_df_dataspecs$well_data_indices = temp_list$well_data_indices
      # tab2_df_dataspecs$starting_well = temp_list$starting_well
      # tab2_df_dataspecs$readingorientation = temp_list$readingorientation
      tab2_df_dataspecs$used_wells = temp_list$used_wells

      # Check parser function is complete
      current_parser_parameters <- reactiveValuesToList(tab2_df_dataspecs) # can wrap in isolate(). ?reactiveValuesToList
      current_parser_parameters
      check_parser_complete(parser_parameters = current_parser_parameters)

    }) # end withprogress

    # Show Data Specs Tab
    showTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab", select = TRUE)

    # # Console checks
    # message("Parser function uploaded.")
    # print(paste0("tab2_df_dataspecs$datatype: ", tab2_df_dataspecs$datatype))

  })
  # reset
  observeEvent(input$reset_exampleparser_button, {

    # Hide all tabs but Data Specs:
    # Hide raw data - unless it already exists
    if(is.null(tab2_df_shiny$alldata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")
    }
    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }
    # Hide Processed Data tabs
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")
    # Hide Parser Function tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab")

    withProgress(message = 'Clearing parser...', value = 0, {
      # CLEAR PARSER
      ## v4
      tab2_df_dataspecs$datatype = NULL # to be flagged by check_parser_complete
      # CLEAR PROCESSED DATA
      # 1. Reset all data
      # tab2_df_shiny$alldata = NULL
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL
    })

    # # Console checks
    # message("Parser function reset.")
    # print(paste0("tab2_df_dataspecs$datatype: ", tab2_df_dataspecs$datatype))

  })

  # use current (saved) parser
  observeEvent(input$submit_currentparser_button, {

    # Hide all tabs but Data Specs:
    # Hide raw data - unless it already exists
    if(is.null(tab2_df_shiny$alldata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")
    }
    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }
    # Hide Processed Data tabs
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")

    withProgress(message = 'Loading parser...', value = 0, {

      # RESET
      # Reset Parser
      ## v4
      tab2_df_dataspecs$datatype = NULL # to be flagged by check_parser_complete
      # Reset Processed Data
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL

      ##

      # LOAD

      # check current parser is saved. or, just re-save it:
      ## v4. one by one
      # step1
      tab2_df_dataspecs$datatype = df_dataspecs$datatype
      tab2_df_dataspecs$dataformat = df_dataspecs$dataformat

      # step2
      tab2_df_dataspecs$channel_number = df_dataspecs$channel_number
      tab2_df_dataspecs$channel_name_specification = df_dataspecs$channel_name_specification
      tab2_df_dataspecs$channel_name_indices = df_dataspecs$channel_name_indices
      tab2_df_dataspecs$channel_names = df_dataspecs$channel_names
      tab2_df_dataspecs$wav_min = df_dataspecs$wav_min
      tab2_df_dataspecs$wav_max = df_dataspecs$wav_max
      tab2_df_dataspecs$wav_interval = df_dataspecs$wav_interval

      # step2b
      tab2_df_dataspecs$timecourse_specification = df_dataspecs$timecourse_specification
      tab2_df_dataspecs$timecourse_indices = df_dataspecs$timecourse_indices
      # tab2_df_dataspecs$timecourse_firsttimepoint = df_dataspecs$timecourse_firsttimepoint
      # tab2_df_dataspecs$timecourse_duration = df_dataspecs$timecourse_duration
      # tab2_df_dataspecs$timecourse_interval = df_dataspecs$timecourse_interval
      # tab2_df_dataspecs$timepoint_number_expected = df_dataspecs$timepoint_number_expected
      tab2_df_dataspecs$timepoint_number = df_dataspecs$timepoint_number # worked out version
      tab2_df_dataspecs$list_of_timepoints = df_dataspecs$list_of_timepoints

      # step3
      tab2_df_dataspecs$matrixformat = df_dataspecs$matrixformat
      # tab2_df_dataspecs$firstchanneldata = df_dataspecs$firstchanneldata
      tab2_df_dataspecs$row_beg = df_dataspecs$row_beg
      tab2_df_dataspecs$row_end = df_dataspecs$row_end
      tab2_df_dataspecs$col_beg = df_dataspecs$col_beg
      tab2_df_dataspecs$col_end = df_dataspecs$col_end

      # step4
      tab2_df_dataspecs$channeldataspacing = df_dataspecs$channeldataspacing

      # step5
      tab2_df_dataspecs$well_data_specification = df_dataspecs$well_data_specification
      tab2_df_dataspecs$well_data_indices = df_dataspecs$well_data_indices
      # tab2_df_dataspecs$starting_well = df_dataspecs$starting_well
      # tab2_df_dataspecs$readingorientation = df_dataspecs$readingorientation
      tab2_df_dataspecs$used_wells = df_dataspecs$used_wells

      # Check parser function is complete
      current_parser_parameters <- reactiveValuesToList(tab2_df_dataspecs) # can wrap in isolate(). ?reactiveValuesToList
      current_parser_parameters
      check_parser_complete(parser_parameters = current_parser_parameters)

    }) # end withprogress

    # Show Data Specs Tab
    showTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab", select = TRUE)

    # # Console checks
    # message("Parser function updated.")
    # print(paste0("tab2_df_dataspecs$datatype: ", tab2_df_dataspecs$datatype))

  })
  # reset
  observeEvent(input$reset_currentparser_button, {

    # Hide all tabs but Data Specs:
    # Hide raw data - unless it already exists
    if(is.null(tab2_df_shiny$alldata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")
    }
    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }
    # Hide Processed Data tabs
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")
    # Hide Parser Function tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab")

    withProgress(message = 'Clearing parser...', value = 0, {
      # CLEAR PARSER
      ## v4
      tab2_df_dataspecs$datatype = NULL # to be flagged by check_parser_complete
      # CLEAR PROCESSED DATA
      # 1. Reset all data
      # tab2_df_shiny$alldata = NULL
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL
    })

    # # Console checks
    # message("Parser function reset.")
    # print(paste0("tab2_df_dataspecs$datatype: ", tab2_df_dataspecs$datatype))

  })

  # upload saved parser
  observeEvent(input$submit_savedparser_button, {

    # Hide all tabs but Data Specs:
    # Hide raw data - unless it already exists
    if(is.null(tab2_df_shiny$alldata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")
    }
    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }
    # Hide Processed Data tabs
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")

    withProgress(message = 'Loading data...', value = 0, {

      # RESET
      # Reset Parser
      ## v4
      tab2_df_dataspecs$datatype = NULL # to be flagged by check_parser_complete
      # Reset Processed Data
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL

      ##

      # Missing files:
      if (is.null(input$upload_parser)) {
        # Error handling: stop
        req(!is.null(input$upload_parser))
      }

      ##

      # LOAD:
      # only upload data if extension is valid # https://mastering-shiny.org/action-transfer.html#uploading-data
      ext <- tools::file_ext(input$upload_parser$name)
      if(grepl(pattern = ext, x = c("RDS"))){

        # create input_list object
        temp_list <- NULL

        # read RDS
        ## v1 v2 v3
        temp_list <- readRDS(input$upload_parser$datapath)

        if(!is.null(temp_list)){

          # LOAD
          ## v4. one by one
          # step1
          tab2_df_dataspecs$datatype = temp_list$datatype
          tab2_df_dataspecs$dataformat = temp_list$dataformat
          # step2
          tab2_df_dataspecs$channel_number = temp_list$channel_number
          tab2_df_dataspecs$channel_name_specification = temp_list$channel_name_specification
          tab2_df_dataspecs$channel_name_indices = temp_list$channel_name_indices
          tab2_df_dataspecs$channel_names = temp_list$channel_names
          tab2_df_dataspecs$wav_min = temp_list$wav_min
          tab2_df_dataspecs$wav_max = temp_list$wav_max
          tab2_df_dataspecs$wav_interval = temp_list$wav_interval
          # step2b
          tab2_df_dataspecs$timecourse_specification = temp_list$timecourse_specification
          tab2_df_dataspecs$timecourse_indices = temp_list$timecourse_indices
          # tab2_df_dataspecs$timecourse_firsttimepoint = temp_list$timecourse_firsttimepoint
          # tab2_df_dataspecs$timecourse_duration = temp_list$timecourse_duration
          # tab2_df_dataspecs$timecourse_interval = temp_list$timecourse_interval
          # tab2_df_dataspecs$timepoint_number_expected = temp_list$timepoint_number_expected
          tab2_df_dataspecs$timepoint_number = temp_list$timepoint_number # worked out version
          tab2_df_dataspecs$list_of_timepoints = temp_list$list_of_timepoints
          # step3
          tab2_df_dataspecs$matrixformat = temp_list$matrixformat
          # tab2_df_dataspecs$firstchanneldata = temp_list$firstchanneldata
          tab2_df_dataspecs$row_beg = temp_list$row_beg
          tab2_df_dataspecs$row_end = temp_list$row_end
          tab2_df_dataspecs$col_beg = temp_list$col_beg
          tab2_df_dataspecs$col_end = temp_list$col_end
          # step4
          tab2_df_dataspecs$channeldataspacing = temp_list$channeldataspacing
          # step5
          tab2_df_dataspecs$well_data_specification = temp_list$well_data_specification
          tab2_df_dataspecs$well_data_indices = temp_list$well_data_indices
          # tab2_df_dataspecs$starting_well = temp_list$starting_well
          # tab2_df_dataspecs$readingorientation = temp_list$readingorientation
          tab2_df_dataspecs$used_wells = temp_list$used_wells

        } else {
          message("Error: Parser file could not be uploaded. Check that it is a .RDS file created with Parsley.")
          showModal(modalDialog(title = "Error", "Parser file could not be uploaded.
                            Check that it is a .RDS file created with Parsley.",
                                easyClose = TRUE ))
        }

      } else {

        # if extension is not on the list of permissible extensions, throw error
        message("Error: The file extension for a parser need to be 'RDS'.")
        showModal(modalDialog(title = "Error", "The file extension for a parser need to be 'RDS'.", easyClose = TRUE ))

      } # only upload data if extension is valid

      # Check parser function is complete
      current_parser_parameters <- reactiveValuesToList(tab2_df_dataspecs) # can wrap in isolate(). ?reactiveValuesToList
      current_parser_parameters
      check_parser_complete(parser_parameters = current_parser_parameters)

    }) # end withprogress

    # Show Data Specs Tab
    showTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab", select = TRUE)

    # # Console checks
    # message("Parser function uploaded.")
    # print(paste0("tab2_df_dataspecs$datatype: ", tab2_df_dataspecs$datatype))

  })
  # reset
  observeEvent(input$reset_savedparser_button, {

    # Hide all tabs but Data Specs:
    # Hide raw data - unless it already exists
    if(is.null(tab2_df_shiny$alldata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")
    }
    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }
    # Hide Processed Data tabs
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")
    # Hide Parser Function tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab")

    withProgress(message = 'Clearing parser...', value = 0, {
      # CLEAR PARSER
      ## v4
      tab2_df_dataspecs$datatype = NULL # to be flagged by check_parser_complete
      # CLEAR PROCESSED DATA
      # 1. Reset all data
      # tab2_df_shiny$alldata = NULL
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL
    })

    # # Console checks
    # message("Parser function reset.")
    # print(paste0("tab2_df_dataspecs$datatype: ", tab2_df_dataspecs$datatype))

  })

  # Tab2: Filename extraction ---------------------------------------------

  # Filename extraction for single files
  # ...using reactiveValues and observeEvent()
  tab2_uploaded_files <- reactiveValues(
    parsername_as_string = NULL,
    filename_as_string = NULL,
    filename_as_string_metadata = NULL
  )
  observeEvent(input$submit_savedparser_button, {
    inFile <- input$upload_parser
    if (is.null(inFile)) { return(NULL) }
    tab2_uploaded_files$parsername_as_string <- stringi::stri_extract_first(str = inFile$name, regex = ".*")
  })
  observeEvent(input$reset_savedparser_button, {
    tab2_uploaded_files$parsername_as_string <- NULL
  })
  output$parserfile_name <- renderPrint({ cat(tab2_uploaded_files$parsername_as_string) })

  # Data
  observeEvent(input$tab2_submit_datafile_button, { # Submit button

    inFile <- input$tab2_upload_data
    if (is.null(inFile)) { return(NULL) }
    tab2_uploaded_files$filename_as_string <- stringi::stri_extract_first(str = inFile$name, regex = ".*")
    # regex "" gives me NA # regex "." gives me 2 # regex ".*" gives me basename(file)
    # regex "*" gives me syntax error # regex ".*(?=\\.)" gives me basename wo extension

  })
  observeEvent(input$tab2_reset_datafile_button, { # Reset button
    tab2_uploaded_files$filename_as_string <- NULL
  })
  output$tab2_rawdatafile_name <- renderPrint({ cat(tab2_uploaded_files$filename_as_string) })

  # Metadata
  observeEvent(input$tab2_submit_metadatafile_button, { # Submit button

    inFile <- input$tab2_upload_metadata
    if (is.null(inFile)) { return(NULL) }
    tab2_uploaded_files$filename_as_string_metadata <- stringi::stri_extract_first(str = inFile$name, regex = ".*")

  })
  observeEvent(input$tab2_reset_metadatafile_button, { # Reset button
    tab2_uploaded_files$filename_as_string_metadata <- NULL
  })
  output$tab2_metadatafile_name <- renderPrint({ cat(tab2_uploaded_files$filename_as_string_metadata) })

  ##

  # Tab2: Data specs to display -------

  output$tab2_datatype_printed <- renderPrint({temp <- unlist(strsplit(tab2_df_dataspecs$datatype, "_"))[2]; cat(temp)})
  output$tab2_dataformat_printed <- renderPrint({temp <- unlist(strsplit(tab2_df_dataspecs$dataformat, "_"))[2]; cat(temp)})

  output$tab2_channel_number_printed <- renderPrint({ cat(tab2_df_dataspecs$channel_number) })
  output$tab2_channel_name_specification_printed <- renderPrint({ cat(tab2_df_dataspecs$channel_name_specification) })
  # output$tab2_channel_name_indices_printed <- renderPrint({ cat(tab2_df_dataspecs$channel_name_indices) }) # see DT below
  output$tab2_channel_names_printed <- renderPrint({
    if(tab2_df_dataspecs$channel_name_specification == "fixed"){cat(tab2_df_dataspecs$channel_names)} else {cat("N/A")}})

  output$tab2_wav_min_printed <- renderPrint({
    if(tab2_df_dataspecs$datatype == "datatype_spectrum"){cat(tab2_df_dataspecs$wav_min)} else {cat("N/A")}})
  output$tab2_wav_max_printed <- renderPrint({
    if(tab2_df_dataspecs$datatype == "datatype_spectrum"){cat(tab2_df_dataspecs$wav_max)} else {cat("N/A")}})
  output$tab2_wav_interval_printed <- renderPrint({
    if(tab2_df_dataspecs$datatype == "datatype_spectrum"){cat(tab2_df_dataspecs$wav_interval)} else {cat("N/A")}})

  output$tab2_timecourse_specification_printed <- renderPrint({
    if(tab2_df_dataspecs$datatype == "datatype_timecourse"){cat(tab2_df_dataspecs$timecourse_specification)} else {cat("N/A")}})
  # output$tab2_timecourse_indices_printed <- renderPrint({
  #   if(tab2_df_dataspecs$timecourse_specification == "selected"){cat(tab2_df_dataspecs$timecourse_indices)} else { cat("N/A") }}) # replaced w DT see below
  output$tab2_timepoint_number_printed <- renderPrint({
    if(tab2_df_dataspecs$datatype == "datatype_timecourse"){cat(tab2_df_dataspecs$timepoint_number)} else { cat("N/A") }})
  output$tab2_list_of_timepoints_printed <- renderPrint({
    if(tab2_df_dataspecs$datatype == "datatype_timecourse"){
      if(tab2_df_dataspecs$timecourse_specification == "fixed"){
        cat(tab2_df_dataspecs$list_of_timepoints)
      } else { cat("N/A") }
    } else { cat("N/A") }
  })

  output$tab2_matrixformat_printed <- renderPrint({
    if(tab2_df_dataspecs$datatype == "dataformat_matrix"){cat(tab2_df_dataspecs$matrixformat)} else { cat("N/A") }})
  output$tab2_row_beg_printed <- renderPrint({ cat(tab2_df_dataspecs$row_beg) })
  output$tab2_row_end_printed <- renderPrint({ cat(tab2_df_dataspecs$row_end) })
  output$tab2_col_beg_printed <- renderPrint({ cat(tab2_df_dataspecs$col_beg) })
  output$tab2_col_end_printed <- renderPrint({ cat(tab2_df_dataspecs$col_end) })

  output$tab2_channeldataspacing_printed <- renderPrint({ cat(tab2_df_dataspecs$channeldataspacing) })

  output$tab2_well_data_specification_printed <- renderPrint({ cat(tab2_df_dataspecs$well_data_specification) })
  # output$tab2_well_data_indices_printed <- renderPrint({
  #   if(tab2_df_dataspecs$well_data_specification == "selected"){cat(tab2_df_dataspecs$well_data_indices)} else { cat("N/A") }}) # replaced w DT see below
  output$tab2_used_wells_printed <- renderPrint({
    if(tab2_df_dataspecs$well_data_specification == "fixed"){cat(tab2_df_dataspecs$used_wells)} else { cat("N/A") }})

  # indices tables
  output$tab2_channel_name_indices_printed = DT::renderDataTable({

    if(tab2_df_dataspecs$channel_name_specification == "selected"){
      temp_df <- as.data.frame(tab2_df_dataspecs$channel_name_indices)
      names(temp_df) <- c("row", "column")
      temp_df <- temp_df %>%
        dplyr::mutate(column = column+1)
    } else {temp_df <- data.frame(x = "N/A")}

    DT::datatable(temp_df,
                  escape = TRUE, # default but impt. 'escapes' html content of tables.
                  rownames = TRUE,
                  class = "compact", # removes row highlighting and compacts rows a bit
                  options = list(
                    dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                    paging = FALSE # only ever show all rows
                  )
    )
  })

  output$tab2_timecourse_indices_printed = DT::renderDataTable({

    temp_df <- data.frame(x = "N/A") # default
    if(tab2_df_dataspecs$datatype == "datatype_timecourse"){
      if(tab2_df_dataspecs$timecourse_specification == "selected"){
        temp_matrix <- matrix(data = tab2_df_dataspecs$timecourse_indices, ncol = 2)
        temp_matrix
        temp_df <- as.data.frame(temp_matrix)
        names(temp_df) <- c("row", "column")
        temp_df
      }
    }

    DT::datatable(temp_df,
                  escape = TRUE, # default but impt. 'escapes' html content of tables.
                  rownames = TRUE,
                  class = "compact", # removes row highlighting and compacts rows a bit
                  options = list(
                    dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                    paging = FALSE # only ever show all rows
                  )
    )
  })

  output$tab2_well_data_indices_printed = DT::renderDataTable({

    if(tab2_df_dataspecs$well_data_specification == "selected"){
      temp_matrix <- matrix(data = tab2_df_dataspecs$well_data_indices, ncol = 2)
      temp_matrix
      temp_df <- as.data.frame(temp_matrix)
      names(temp_df) <- c("row", "column")
      temp_df
    } else {temp_df <- data.frame(x = "N/A")}

    DT::datatable(temp_df,
                  escape = TRUE, # default but impt. 'escapes' html content of tables.
                  rownames = TRUE,
                  class = "compact", # removes row highlighting and compacts rows a bit
                  options = list(
                    dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                    paging = FALSE # only ever show all rows
                  )
    )
  })

  # Tab2: DATAFRAME ----

  tab2_df_shiny <- reactiveValues(

    # 1. alldata is all data
    alldata = NULL,

    # 3. totaldata is sum total of all cells in alldata that represents numerical data (rather than empty space/metadata)
    totaldata = NULL,

    # 4. metadata is plate layout
    metadata = NULL,
    metadata_skip = FALSE,

    # 5. parsed data
    parseddata = NULL

  )

  # Tab2: Input 1: Load example data ----
  observeEvent(input$tab2_submit_exampledata_button, {

    # # Console checks
    # print("example data check:")
    # print(paste0("tab2_df_dataspecs$dataformat: ", tab2_df_dataspecs$dataformat))

    # Show only Raw data tab
    # hideTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")

    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }

    withProgress(message = 'Loading data...', value = 0, {

      # RESET
      # 1. Reset all data
      tab2_df_shiny$alldata = NULL
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL

      # LOAD
      # 1. Update all data
      filepathtouse <- system.file("extdata", paste0(input$tab2_select_exampledata, ".csv"), package = "parsleyapp") ###
      tab2_df_shiny$alldata <- utils::read.csv(filepathtouse, header = FALSE)

    }) # end withprogress

    # Show Raw data Tab
    showTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab", select = TRUE)

  })
  # Input 1: Reset
  observeEvent(input$tab2_reset_exampledata_button, {

    withProgress(message = 'Clearing data...', value = 0, {
      # 1. Reset all data
      tab2_df_shiny$alldata = NULL
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL
    }) # end withprogress

    # Hide processed data tabs
    # hideTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")

    # Hide Raw data Tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")

  })

  # Tab2: Input 2: Upload one CSV file ----
  observeEvent(input$tab2_submit_datafile_button, {

    # Show only Raw data tab
    # hideTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")

    # Hide metadata - unless it already exists
    if(is.null(tab2_df_shiny$metadata)){
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")
    }

    withProgress(message = 'Loading data...', value = 0, {

      # Missing files:
      if (is.null(input$tab2_upload_data)) {
        # Error handling: stop
        req(!is.null(input$tab2_upload_data))
      }

      # RESET
      # 1. Reset all data
      tab2_df_shiny$alldata = NULL
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL

      # LOAD:
      # fileinput # only upload data if extension is valid
      ext <- tools::file_ext(input$tab2_upload_data$name)
      if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt", "xls", "xlsx")))){

        data <- NULL

        if(grepl(pattern = ext, x = c("csv")) & input$tab2_upload_data_delim == ","){
          data <- utils::read.csv(input$tab2_upload_data$datapath, header = FALSE)
        }
        if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt"))) &
           (input$tab2_upload_data_delim == ";" | input$tab2_upload_data_delim == "\t")){
          data <- utils::read.table(input$tab2_upload_data$datapath, header = FALSE, sep = input$tab2_upload_data_delim)
        }
        if(any(grepl(pattern = ext, x = c("xls", "xlsx"))) & input$tab2_upload_data_delim == "excel"){
          data <- readxl::read_excel(input$tab2_upload_data$datapath, col_names = FALSE)
        }

        if(!is.null(data)){
          # LOAD
          # 1. Update all data (# Update tab2_df_shiny with converted dataframe)
          tab2_df_shiny$alldata <- data
        } else {
          # if data doesn't exist, there must be a mix up between file extension and file type specified
          message("Error: Ensure that the specified file type matches uploaded file's extension.")
          showModal(modalDialog(title = "Error", "Ensure that the specified file type matches uploaded file's extension.",
                                easyClose = TRUE ))
        }

      } else {

        # if extension is not on the list of permissible extensions, throw error
        message("Error: File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.")
        showModal(modalDialog(title = "Error", "File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.",
                              easyClose = TRUE ))

      } # only upload data if extension is valid

    }) # end withprogress

    # Show Raw data Tab
    showTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab", select = TRUE)

  })
  # Input 2: Reset
  observeEvent(input$tab2_reset_datafile_button, {

    withProgress(message = 'Clearing data...', value = 0, {

      ## RESET DATA DFS
      # 1. alldata to be reset
      tab2_df_shiny$alldata = NULL
      # 3. Reset total data
      tab2_df_shiny$totaldata = NULL
      # 4. Reset parsed data
      tab2_df_shiny$parseddata = NULL

    }) # end withprogress

    # Hide processed data tabs
    # hideTab(inputId = "usp_mainpaneldata_tabset", target = "dataspecs_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab")
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")

    # Hide Raw data Tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_tab")

  })

  # Tab2: Metadata Input 1: Load example metadata ----
  observeEvent(input$tab2_submit_examplemetadata_button, {

    # if skipping metadata:
    if(input$tab2_select_examplemetadata == "metadata_skip"){

      ## RESET
      # 1. Reset metadata
      tab2_df_shiny$metadata = NULL
      tab2_df_shiny$metadata_skip = FALSE
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      tab2_df_shiny$parseddata = NULL

      ## 1. Don't add metadata
      tab2_df_shiny$metadata_skip = TRUE
      tab2_df_shiny$metadata <- data.frame(metadata = "No metadata has been uploaded.")

      # Show Metadata Tab
      showTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)
    }

    if(input$tab2_select_examplemetadata != "metadata_skip"){

      withProgress(message = 'Loading metadata...', value = 0, {

        # RESET
        # 1. Reset metadata
        tab2_df_shiny$metadata = NULL
        tab2_df_shiny$metadata_skip = FALSE
        # Also Reset parsed data (in case this has already taken place w a previous metadata)
        tab2_df_shiny$parseddata = NULL

        # LOAD
        # 1. Update metadata
        filepathtouse <- system.file("extdata", paste0(input$tab2_select_examplemetadata, ".csv"), package = "parsleyapp") ###

        # v2
        if(grepl("matrix", input$tab2_select_examplemetadata)){
          tab2_df_shiny$metadata <- utils::read.csv(filepathtouse, header = FALSE) # matrix
        } else {
          tab2_df_shiny$metadata <- utils::read.csv(filepathtouse, header = TRUE) # tidy
        }

      }) # end withprogress

      # Hide parsed data tab
      hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")
      # Show Metadata Tab
      showTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)

    }

  })

  # Metadata Input 1: Reset
  observeEvent(input$tab2_reset_examplemetadata_button, {

    withProgress(message = 'Clearing metadata...', value = 0, {

      # 1. Reset metadata
      tab2_df_shiny$metadata = NULL
      tab2_df_shiny$metadata_skip = FALSE
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      tab2_df_shiny$parseddata = NULL

    }) # end withprogress

    # Hide parsed data tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")
    # Hide Metadata Tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")

  })

  # Tab2: Metadata Input 2: Upload one CSV file ----
  observeEvent(input$tab2_submit_metadatafile_button, {

    withProgress(message = 'Loading metadata...', value = 0, {

      # Missing files:
      if (is.null(input$tab2_upload_metadata)) {
        # Error handling: stop
        req(!is.null(input$tab2_upload_metadata))
      }

      # RESET
      # 1. Reset metadata
      tab2_df_shiny$metadata = NULL
      tab2_df_shiny$metadata_skip = FALSE
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      tab2_df_shiny$parseddata = NULL

      # LOAD:
      # fileinput # only upload metadata if extension is valid
      ext <- tools::file_ext(input$tab2_upload_metadata$name)
      if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt", "xls", "xlsx")))){

        data <- NULL

        if(grepl(pattern = ext, x = c("csv")) & input$tab2_metadata_delim == ","){

          if(input$tab2_metadata_format == "tidy"){
            data <- utils::read.csv(input$tab2_upload_metadata$datapath, header = TRUE) # read.csv
          } else if(input$tab2_metadata_format == "matrix"){
            data <- utils::read.csv(input$tab2_upload_metadata$datapath, header = FALSE)
          }

        }
        if(any(grepl(pattern = ext, x = c("csv", "tsv", "txt"))) & (input$tab2_metadata_delim == ";" | input$tab2_metadata_delim == "\t")){

          if(input$tab2_metadata_format == "tidy"){
            data <- utils::read.table(input$tab2_upload_metadata$datapath, header = TRUE, sep = input$tab2_metadata_delim)
          } else if(input$tab2_metadata_format == "matrix"){
            data <- utils::read.table(input$tab2_upload_metadata$datapath, header = FALSE, sep = input$tab2_metadata_delim)
          }

        }
        if(any(grepl(pattern = ext, x = c("xls", "xlsx"))) & input$tab2_metadata_delim == "excel"){

          if(input$tab2_metadata_format == "tidy"){
            data <- readxl::read_excel(input$tab2_upload_metadata$datapath, col_names = TRUE)
          } else if(input$tab2_metadata_format == "matrix"){
            data <- readxl::read_excel(input$tab2_upload_metadata$datapath, col_names = FALSE)
          }

        }

        if(!is.null(data)){
          # LOAD
          # 1. Update metadata
          tab2_df_shiny$metadata <- data
        } else {
          # if data doesn't exist, there must be a mix up between file extension and file type specified
          message("Error: Ensure that the specified file type matches uploaded file's extension.")
          showModal(modalDialog(title = "Error", "Ensure that the specified file type matches uploaded file's extension.",
                                easyClose = TRUE ))
        }

      } else {

        # if extension is not on the list of permissible extensions, throw error
        message("Error: File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.")
        showModal(modalDialog(title = "Error", "File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.",
                              easyClose = TRUE ))

      } # only upload data if extension is valid

    }) # end withprogress

    # Hide parsed data tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")
    # Show Metadata Tab
    showTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab", select = TRUE)

  })
  # Metadata Input 2: Reset
  observeEvent(input$tab2_reset_metadatafile_button, {

    withProgress(message = 'Clearing metadata...', value = 0, {

      # 1. Reset metadata
      tab2_df_shiny$metadata = NULL
      tab2_df_shiny$metadata_skip = FALSE
      # Also Reset parsed data (in case this has already taken place w a previous metadata)
      tab2_df_shiny$parseddata = NULL

    }) # end withprogress

    # Hide parsed data tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab")
    # Hide Metadata Tab
    hideTab(inputId = "usp_mainpaneldata_tabset", target = "metadata_tab")

  })

  # Tab2: DATATABLES ----

  # alldata ----
  output$tab2_RawDataTable = DT::renderDataTable({

    # Remove error message from DT output after clearing data
    if(is.null(tab2_df_shiny$alldata)){
      df_temp <- data.frame(v1 = c(NA))
      DT::datatable(df_temp)
      return()
    }

    DT::datatable(tab2_df_shiny$alldata, # raw_data
                  escape = TRUE, # default but impt. 'escapes' html content of tables.
                  # selection = list(target = 'cell'), ### saved parser tab2
                  # rownames = FALSE, # remove row numbering
                  rownames = TRUE, ### rownumbers # can't enable, as disrupts cell selection function.
                  # enabling for tab2 ### saved parser tab2
                  class = "compact", # removes row highlighting and compacts rows a bit
                  options = list(
                    dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                    paging = FALSE # only ever show all rows
                    # pageLength = -1, # rows to show initially (-1 = all rows)
                    # lengthMenu = list(c(-1, 10, 50), c('All', '10 rows', '100 rows')) # row number options
                    # searching = FALSE,

                    # # how to fix col widths?
                    # scrollX = TRUE # autoWidth = TRUE, columnDefs = list(list(width = '50px', targets = "_all"))
                    # # supposedly this fixes columns but fails for long-text columns
                    # # issue still unsolved https://github.com/rstudio/DT/issues/29

                  ) # DT options https://shiny.rstudio.com/gallery/datatables-options.html
    ) #%>%
    # DT::formatStyle(c(1:dim(tab2_df_shiny$alldata)[2]), # all columns # https://stackoverflow.com/questions/50751568/add-cell-borders-in-an-r-datatable
    #                 border = '1px solid #ddd', # https://stackoverflow.com/questions/50751568/add-cell-borders-in-an-r-datatable
    #                 fontSize = '10px', # reduce font size # can also do '50%' https://stackoverflow.com/questions/44101055/changing-font-size-in-r-datatables-dt
    #                 cursor = 'pointer' # fun. adds "hand" pointer to make it clear it's clickable
    # ) ### saved parser tab2

  }) # renderdatatable

  #

  # # first channel data (data from first reading) ----
  #
  # # FirstChannelDataTable - first row/column
  # output$tab2_FirstChannelDataTable = DT::renderDataTable({
  #
  #   DT::datatable(df_dataspecs$firstchanneldata,
  #                 escape = TRUE, # default but impt. 'escapes' html content of tables.
  #                 # rownames = FALSE, # remove row numbering
  #                 rownames = TRUE, ### rownumbers
  #                 class = "compact", # removes row highlighting and compacts rows a bit
  #                 options = list(
  #                   dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
  #                   paging = FALSE # only ever show all rows
  #                 )
  #   )
  #
  # }) # renderdatatable

  #

  # totaldata (cropped data) ----

  # TotalDataTable - all cells w numeric data - for Cropped Data Tab page
  output$tab2_TotalDataTable = DT::renderDataTable({

    DT::datatable(tab2_df_shiny$totaldata,
                  escape = TRUE, # default but impt. 'escapes' html content of tables.
                  rownames = TRUE, # keep row numbering - required to show reading names post step 5
                  class = "compact", # removes row highlighting and compacts rows a bit
                  options = list(
                    dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                    paging = FALSE # only ever show all rows
                  )
    )

  }) # renderdatatable

  #

  # metadata table ----
  output$tab2_MetaDataTable = DT::renderDataTable({

    DT::datatable(tab2_df_shiny$metadata,
                  escape = TRUE, # default but impt. 'escapes' html content of tables.
                  # rownames = FALSE, # remove row numbering
                  rownames = TRUE, ### rownumbers
                  class = "compact", # removes row highlighting and compacts rows a bit
                  options = list(
                    dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                    paging = FALSE # only ever show all rows
                  )
    )

  }) # renderdatatable

  #

  # parsed data table ----
  output$tab2_ParsedDataTable = DT::renderDataTable({

    DT::datatable(tab2_df_shiny$parseddata,
                  escape = TRUE, # default but impt. 'escapes' html content of tables.
                  # selection = list(target = 'cell'),
                  # rownames = FALSE, # remove row numbering
                  rownames = TRUE, ### rownumbers
                  class = "compact", # removes row highlighting and compacts rows a bit
                  options = list(
                    dom = "t", # only show table - no search, no pagination options, no summary "showing rows 1-185 of 185'
                    paging = FALSE # only ever show all rows
                  )
    )

  }) # renderdatatable

  # Tab2: Use Saved Parser ---------------------------------------

  observeEvent(input$use_saved_parser_button, {

    withProgress(message = 'Parsing data...', value = 0, {

      # Reset parsed data
      tab2_df_shiny$parseddata = NULL

      ## Check that the parser function is complete
      current_parser_parameters <- reactiveValuesToList(tab2_df_dataspecs) # can wrap in isolate(). ?reactiveValuesToList
      current_parser_parameters
      error_detected <- check_parser_complete(parser_parameters = current_parser_parameters)
      # TRUE if error, NULL otherwise (as nothing is returned)
      # when parser missing -> error message but also crash. need extra return step.
      if(isTRUE(error_detected)){ return() }
      error_detected <- NULL # reset

      ## Check that data and metadata files are uploaded
      if(is.null(tab2_df_shiny$alldata)){
        message("Error: Upload a raw data file.")
        showModal(modalDialog(title = "Error", "Upload a raw data file.", easyClose = TRUE ))
        return()
      }
      if(is.null(tab2_df_shiny$metadata)){ # works even for skipped metadata as then metadata is "No metadata has been uploaded."
        message("Error: Upload a metadata file.")
        showModal(modalDialog(title = "Error", "Upload a metadata file.", easyClose = TRUE ))
        return()
      }

      # parse -----------------------------------------------------

      # Step3: FIRST CHANNEL DATA ----

      # To make Step3 bit easier to follow:
      row_beg <- tab2_df_dataspecs$row_beg
      row_end <- tab2_df_dataspecs$row_end
      col_beg <- tab2_df_dataspecs$col_beg
      col_end <- tab2_df_dataspecs$col_end

      # Standard and Spectrum data (essentially copied from Tab1Step3) -----
      if(tab2_df_dataspecs$datatype == "datatype_standard" | tab2_df_dataspecs$datatype == "datatype_spectrum"){

        if(tab2_df_dataspecs$dataformat == "dataformat_rows"){ # data in rows

          # stop if selection is >1 rows
          if(row_beg != row_end){
            # message("Error: Select only 1 row.")
            # showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
            tab2_df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
            return()
          }

          # SAVE DATA
          if(col_end != col_beg){ # if we have several columns, it will form a df naturally
            tab2_df_dataspecs$firstchanneldata <- tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end]
          } else if(col_end == col_beg) { # if we have a single column, we need to force a dataframe
            tab2_df_dataspecs$firstchanneldata <- data.frame(v1 = tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end])
          }

        } # row

        if(tab2_df_dataspecs$dataformat == "dataformat_columns"){ # data in columns

          # stop if selection is >1 rows
          if(col_beg != col_end){
            # message("Error: Select only 1 column.")
            # showModal(modalDialog(title = "Error", "Select only 1 column.", easyClose = TRUE ))
            tab2_df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
            return()
          }

          # SAVE DATA
          tab2_df_dataspecs$firstchanneldata <- data.frame(v1 = tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end])

        } # column

        if(tab2_df_dataspecs$dataformat == "dataformat_matrix"){ # data in matrix

          ## v1. First channel data: Select A1 and H12 (whole matrix). [Could consider an alternative version that selects A1-A12 only first.]
          # stop if selection is NOT >1 rows and >1 columns ??
          if( ((row_beg != row_end-7) | (col_beg != col_end-11)) &
              ((row_beg != row_end-11) | (col_beg != col_end-7)) ){
            # first half checks for 8-row*12col format: required when matrices are printed in horizontal format: rows as A1, A2, A3
            # second half checks for 8-col*12row format: required when matrices are printed in vertical format: rows as A1, B1, C1
            # message("Error: Select an 8*12 matrix.")
            # showModal(modalDialog(title = "Error", "Select an 8*12 matrix.", easyClose = TRUE ))
            tab2_df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
            return()
          }

          # Assign matrix 'type' from coordinates:
          if( (row_beg == row_end-7) & (col_beg == col_end-11) ){
            # 8 rows*12 columns = horizontal
            tab2_df_dataspecs$matrixformat <- "horizontal"
          }
          if( (row_beg == row_end-11) & (col_beg == col_end-7) ){
            # 12 rows*8 columns = vertical
            tab2_df_dataspecs$matrixformat <- "vertical"
          }

          print("matrix format: ")
          print(tab2_df_dataspecs$matrixformat)

          # Grab matrix data
          temp_firstchanneldata <- tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end]

          # Turn this matrix into a ROW
          temp_firstchanneldata <- as.data.frame(t(c(t(temp_firstchanneldata))))
          # t: transpose. reqd bc c() turns matrix into vector by reading down columns (yikes)
          # c: turns matrix into vector (column type).
          # t again: turns it back to row?
          # as.data.frame: prev experience says using t to transpose turns a df into a matrix. so switch back.

          # SAVE DATA
          tab2_df_dataspecs$firstchanneldata <- temp_firstchanneldata

        } # matrix

      } else if(tab2_df_dataspecs$datatype == "datatype_timecourse"){ # Timecourse data (essentially copied from Tab1Step3) -------

        # For timecourse data, need to take into account (a) timepoints (b) channels

        # Assuming timepoints together, and channels separated (this is usual format):
        if(tab2_df_dataspecs$dataformat == "dataformat_rows"){

          # stop if selection is >1 rows
          if(row_beg != row_end){
            # message("Error: Select only 1 row.")
            # showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
            tab2_df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
            return()
          }

          # FIRST CHANNEL, FIRST TIMEPOINT
          # is selection

          # FIRST CHANNEL = FIRST CHANNEL, ALL TIMEPOINTS
          # print("timepoint_number: ")
          # print(tab2_df_dataspecs$timepoint_number)

          if(tab2_df_dataspecs$timepoint_number > 1){
            # if we have several columns, it will form a df naturally
            tab2_df_dataspecs$firstchanneldata <- tab2_df_shiny$alldata[row_beg:(row_end+tab2_df_dataspecs$timepoint_number-1), col_beg:col_end]
          } else if(tab2_df_dataspecs$timepoint_number == 1){
            # if we have a single timepoint therefore a single row for the whole first channel, we need to force a dataframe
            tab2_df_dataspecs$firstchanneldata <- data.frame(v1 = tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end])
          }

        } # row

        if(tab2_df_dataspecs$dataformat == "dataformat_columns"){

          # stop if selection is >1 rows
          if(col_beg != col_end){
            # message("Error: Select only 1 column.")
            # showModal(modalDialog(title = "Error", "Select only 1 column.", easyClose = TRUE ))
            tab2_df_dataspecs$firstchanneldata <- NULL # so that any 'set' click undoes previous setting even if there's an error
            return()
          }

          # FIRST CHANNEL, FIRST TIMEPOINT
          # is selection

          # FIRST CHANNEL = FIRST CHANNEL, ALL TIMEPOINTS
          # print("timepoint_number: ")
          # print(tab2_df_dataspecs$timepoint_number)

          if(tab2_df_dataspecs$timepoint_number > 1){
            # if we have several columns, it will form a df naturally
            tab2_df_dataspecs$firstchanneldata <- tab2_df_shiny$alldata[row_beg:row_end, col_beg:(col_end+tab2_df_dataspecs$timepoint_number-1)]
          } else if(tab2_df_dataspecs$timepoint_number == 1){
            # if we have a single timepoint therefore a single row for the whole first channel, we need to force a dataframe
            tab2_df_dataspecs$firstchanneldata <- data.frame(v1 = tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end])
          }

        } # column

      } # else if timecourse

      print("first channel data:")
      print(tab2_df_dataspecs$firstchanneldata)

      # Step4: TOTAL DATA (essentially copied from Tab1Step4) -----
      # Standard and Spectrum -----
      if(tab2_df_dataspecs$datatype == "datatype_standard" | tab2_df_dataspecs$datatype == "datatype_spectrum"){

        # (1) If 1 channel, totaldata is the same as the first channel data
        if(tab2_df_dataspecs$channel_number == 1){

          # Save total data
          tab2_df_shiny$totaldata <- tab2_df_dataspecs$firstchanneldata
          # print("total data table:")
          # print(tab2_df_shiny$totaldata)

        } else if(tab2_df_dataspecs$channel_number > 1){
          # (2) If >1 channel, totaldata is..

          temp_alldata <- tab2_df_shiny$alldata

          # (2a) Rows:
          if(tab2_df_dataspecs$dataformat == "dataformat_rows"){

            # print("data spacing:")
            # print(tab2_df_dataspecs$channeldataspacing)

            # row numbers needed:
            row_numbers <- c()
            for(i in 1:tab2_df_dataspecs$channel_number){
              new_rownumber <- tab2_df_dataspecs$row_beg + (i-1)*tab2_df_dataspecs$channeldataspacing
              # use (i-1) not (i) because first row needs to equal tab2_df_dataspecs$row_beg (first i is 1, so first i-1 will always be 0)
              row_numbers <- c(row_numbers, new_rownumber)
            }
            print("row numbers to use:")
            print(row_numbers)

            ## Prevent crash when row/column indexes to use don't exist in df
            print("Last row number of requested data:")
            print(row_numbers[length(row_numbers)]) # last row number of requested data
            print("Last row number of existing data:")
            print(nrow(temp_alldata)) # last row number of existing data
            if(nrow(temp_alldata) < row_numbers[length(row_numbers)]){ # if we're requesting data outside the alldata df

              # Console
              message("Error: Do not request data from outside range of file.")
              message(paste0("Requested data up to row #", row_numbers[length(row_numbers)]))
              message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

              # Modal
              showModal(modalDialog(title = "Error",
                                    paste0("Do not request data from outside range of file. ",
                                           "[Requested data up to row #", row_numbers[length(row_numbers)], ". ",
                                           "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                    easyClose = TRUE ))

              return()
            }

            # Save total data
            tab2_df_shiny$totaldata <- temp_alldata[row_numbers, tab2_df_dataspecs$col_beg:tab2_df_dataspecs$col_end]
            # print("total data table:")
            # print(tab2_df_shiny$totaldata)

          }

          # (2b) Columns:
          if(tab2_df_dataspecs$dataformat == "dataformat_columns"){

            # print("data spacing:")
            # print(tab2_df_dataspecs$channeldataspacing)

            # column numbers needed:
            column_numbers <- c()
            for(i in 1:tab2_df_dataspecs$channel_number){
              new_columnnumber <- tab2_df_dataspecs$col_beg + (i-1)*tab2_df_dataspecs$channeldataspacing
              # use (i-1) not (i) because first column needs to equal tab2_df_dataspecs$col_beg (first i is 1, so first i-1 will always be 0)
              column_numbers <- c(column_numbers, new_columnnumber)
            }
            print("column numbers to use:")
            print(column_numbers)

            ## Prevent crash when row/column indexes to use don't exist in df
            print("Last column number of requested data:")
            print(column_numbers[length(column_numbers)]) # last row number of requested data
            print("Last column number of existing data:")
            print(ncol(temp_alldata)) # last row number of existing data
            if(ncol(temp_alldata) < column_numbers[length(column_numbers)]){ # if we're requesting data outside the alldata df

              # Console
              message("Error: Do not request data from outside range of file.")
              message(paste0("Requested data up to column #", column_numbers[length(column_numbers)]))
              message(paste0("Existing data's highest column number: #", ncol(temp_alldata)))

              # Modal
              showModal(modalDialog(title = "Error",
                                    paste0("Do not request data from outside range of file. ",
                                           "[Requested data up to column #", column_numbers[length(column_numbers)], ". ",
                                           "Existing data's highest column number: #", ncol(temp_alldata), ".]"),
                                    easyClose = TRUE ))

              return()
            }

            # Save total data
            tab2_df_shiny$totaldata <- temp_alldata[tab2_df_dataspecs$row_beg:tab2_df_dataspecs$row_end, column_numbers]
            # print("total data table:")
            # print(tab2_df_shiny$totaldata)

          } # columns

          # (2c) Matrix
          if(tab2_df_dataspecs$dataformat == "dataformat_matrix"){

            # print("data spacing:")
            # print(tab2_df_dataspecs$channeldataspacing)

            if(tab2_df_dataspecs$matrixformat == "horizontal"){ # matrix horizontal is in 8row*12col format

              # row numbers needed:
              row_numbers <- c()
              for(i in 1:tab2_df_dataspecs$channel_number){
                new_rownumber <- tab2_df_dataspecs$row_beg + (i-1)*tab2_df_dataspecs$channeldataspacing
                # use (i-1) not (i) because first row needs to equal tab2_df_dataspecs$row_beg (first i is 1, so first i-1 will always be 0)
                row_numbers <- c(row_numbers, new_rownumber)
              }
              print("row numbers to use:")
              print(row_numbers)

              ## Prevent crash when row/column indexes to use don't exist in df
              print("Last row number of requested data:")
              print(row_numbers[length(row_numbers)] + 7) # last row number of requested data +7 for matrix (as row_beg = A, so row_beg+7 = H)
              print("Last row number of existing data:")
              print(nrow(temp_alldata)) # last row number of existing data
              if(nrow(temp_alldata) < row_numbers[length(row_numbers)]){ # if we're requesting data outside the alldata df

                # Console
                message("Error: Do not request data from outside range of file.")
                message(paste0("Requested data up to row #", row_numbers[length(row_numbers)]+7 ))
                message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

                # Modal
                showModal(modalDialog(title = "Error",
                                      paste0("Do not request data from outside range of file. ",
                                             "[Requested data up to row #", row_numbers[length(row_numbers)]+7, ". ",
                                             "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                      easyClose = TRUE ))

                return()
              }

              # Save total data - MATRIX
              tab2_df_shiny$totaldata <- c()

              for(i in 1:length(row_numbers)){ # for each reading
                first_row <- row_numbers[i] # A
                last_row <- first_row+7 # H

                ## Grab matrix data
                # temp_firstchanneldata <- tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end] # used in step3
                temp_channeli_data <- temp_alldata[first_row:last_row, tab2_df_dataspecs$col_beg:tab2_df_dataspecs$col_end] # used in step4 - works for each channel
                ## Turn this matrix into a ROW
                temp_channeli_data <- as.data.frame(t(c(t(temp_channeli_data))))
                ## Save data
                # tab2_df_dataspecs$firstchanneldata <- temp_firstchanneldata # step3
                tab2_df_shiny$totaldata <- rbind(tab2_df_shiny$totaldata, temp_channeli_data) # step4

              } # for each reading -> assemble data

            } # horizontal

            if(tab2_df_dataspecs$matrixformat == "vertical"){ # matrix vertical is in 12row*8col format

              # row numbers needed:
              row_numbers <- c()
              for(i in 1:tab2_df_dataspecs$channel_number){
                new_rownumber <- tab2_df_dataspecs$row_beg + (i-1)*tab2_df_dataspecs$channeldataspacing
                # use (i-1) not (i) because first row needs to equal tab2_df_dataspecs$row_beg (first i is 1, so first i-1 will always be 0)
                row_numbers <- c(row_numbers, new_rownumber)
              }
              print("row numbers to use:")
              print(row_numbers)

              ## Prevent crash when row/column indexes to use don't exist in df
              print("Last row number of requested data:")
              print(row_numbers[length(row_numbers)] + 11) # last row number of requested data +11 for matrix vertical
              # (as row_beg = 1, so row_beg+11 = 12)
              # DIFFERENCE ABOVE
              print("Last row number of existing data:")
              print(nrow(temp_alldata)) # last row number of existing data
              if(nrow(temp_alldata) < row_numbers[length(row_numbers)]){ # if we're requesting data outside the alldata df

                # Console
                message("Error: Do not request data from outside range of file.")
                message(paste0("Requested data up to row #", row_numbers[length(row_numbers)]+11 ))
                # DIFFERENCE ABOVE
                message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

                # Modal
                showModal(modalDialog(title = "Error",
                                      paste0("Do not request data from outside range of file. ",
                                             "[Requested data up to row #", row_numbers[length(row_numbers)]+11, ". ",
                                             "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                      easyClose = TRUE ))

                return()
              }

              # Save total data - MATRIX
              tab2_df_shiny$totaldata <- c()

              for(i in 1:length(row_numbers)){ # for each reading
                first_row <- row_numbers[i] # 1
                last_row <- first_row+11 # 12
                # DIFFERENCE ABOVE

                ## Grab matrix data
                # temp_firstchanneldata <- tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end] # used in step3
                temp_channeli_data <- temp_alldata[first_row:last_row, tab2_df_dataspecs$col_beg:tab2_df_dataspecs$col_end] # used in step4 - works for each channel
                ## Turn this matrix into a ROW
                temp_channeli_data <- as.data.frame(t(c(t(temp_channeli_data))))
                ## Save data
                # tab2_df_dataspecs$firstchanneldata <- temp_firstchanneldata # step3
                tab2_df_shiny$totaldata <- rbind(tab2_df_shiny$totaldata, temp_channeli_data) # step4
              } # for each reading -> assemble data

            } # vertical

            # print("total data table:")
            # print(tab2_df_shiny$totaldata)

          } # matrix

        } # channel number > 1

      } else if(tab2_df_dataspecs$datatype == "datatype_timecourse"){
        # Timecourse -----

        # (1) If 1 channel, totaldata is the same as the first channel data
        if(tab2_df_dataspecs$channel_number == 1){

          if(tab2_df_dataspecs$dataformat == "dataformat_rows"){

            # Save total data
            tab2_df_shiny$totaldata <- tab2_df_dataspecs$firstchanneldata

            # EDIT: different from non-timecourse data, add in column names from well name (step 5)
            # and add in columns for reading name and timepoint time (here):

            # reading name as 'channel' column:
            tab2_df_shiny$totaldata <- tab2_df_shiny$totaldata %>%
              dplyr::mutate(channel = tab2_df_dataspecs$channel_names) # should only be one

            # timepoints as 'time' column:
            timepoints_df <- data.frame(time = tab2_df_dataspecs$list_of_timepoints)
            tab2_df_shiny$totaldata <- cbind(tab2_df_shiny$totaldata, timepoints_df)

            # print("total data table:")
            # print(tab2_df_shiny$totaldata)

          }

          if(tab2_df_dataspecs$dataformat == "dataformat_columns"){

            # Save total data
            tab2_df_shiny$totaldata <- tab2_df_dataspecs$firstchanneldata

            # EDIT: different from non-timecourse data, add in column names from timepoint time (here)
            # and columns for reading name (here) and well name (step 5):

            # timepoints as column names:
            timepoints_colnames <- paste0("timepoint_", tab2_df_dataspecs$list_of_timepoints)
            colnames(tab2_df_shiny$totaldata) <- timepoints_colnames

            # reading name as 'channel' column:
            tab2_df_shiny$totaldata$channel <- tab2_df_dataspecs$channel_names # should just be one here

            # print("total data table:")
            # print(tab2_df_shiny$totaldata)

          }

        } else if(tab2_df_dataspecs$channel_number > 1){
          # (2) If >1 channel, totaldata is..

          temp_alldata <- tab2_df_shiny$alldata

          # (2a) Rows:
          if(tab2_df_dataspecs$dataformat == "dataformat_rows"){

            # print("data spacing:")
            # print(tab2_df_dataspecs$channeldataspacing)

            # Get data, but also add cols for channel and time

            ## Prevent crash when row/column indexes to use don't exist in df
            print("Last row number of requested data:")
            # print(row_numbers[length(row_numbers)]) # last row number of requested data (+all its timepoints)
            largest_rownumber_needed <- tab2_df_dataspecs$row_beg+(tab2_df_dataspecs$channel_number-1)*tab2_df_dataspecs$channeldataspacing+(tab2_df_dataspecs$timepoint_number-1)
            print(largest_rownumber_needed)
            print("Last row number of existing data:")
            print(nrow(temp_alldata)) # last row number of existing data
            if(nrow(temp_alldata) < largest_rownumber_needed){
              # if we're requesting data outside the alldata df

              # Console
              message("Error: Do not request data from outside range of file.")
              message(paste0("Requested data up to row #", largest_rownumber_needed))
              message(paste0("Existing data's highest row number: #", nrow(temp_alldata)))

              # Modal
              showModal(modalDialog(title = "Error",
                                    paste0("Do not request data from outside range of file. ",
                                           "[Requested data up to row #", largest_rownumber_needed, ". ",
                                           "Existing data's highest row number: #", nrow(temp_alldata), ".]"),
                                    easyClose = TRUE ))

              return()
            }

            tab2_df_shiny$totaldata <- c()
            for(i in 1:tab2_df_dataspecs$channel_number){

              # find first row of data for current reading:
              firstrownumber <- tab2_df_dataspecs$row_beg + (i-1)*tab2_df_dataspecs$channeldataspacing

              # extract data for current reading:
              temp_channeldata <- temp_alldata[(firstrownumber):(firstrownumber+tab2_df_dataspecs$timepoint_number-1), # rows
                                               tab2_df_dataspecs$col_beg:tab2_df_dataspecs$col_end] # cols

              # EDIT: different from non-timecourse data, add in column names from well name (step 5)
              # and add in columns for reading name and timepoint time (here):

              # # make temp name for wells (not essential)
              # temp_colnames <- seq(from = 1, to = ncol(temp_channeldata), by = 1)
              # temp_colnames <- paste0("well_", temp_colnames)
              # colnames(temp_channeldata) <- temp_colnames

              # reading name as 'channel' column:
              temp_channeldata$channel <- tab2_df_dataspecs$channel_names[i]

              # timepoints as 'time' column:
              timepoints_df <- data.frame(time = tab2_df_dataspecs$list_of_timepoints)
              temp_channeldata <- cbind(temp_channeldata, timepoints_df)

              # bind data for current reading to final totaldata df:
              tab2_df_shiny$totaldata <- rbind(tab2_df_shiny$totaldata, temp_channeldata)
            }

            # print("total data table:")
            # print(tab2_df_shiny$totaldata)

          } # rows

          # (2b) Columns:
          if(tab2_df_dataspecs$dataformat == "dataformat_columns"){

            # print("data spacing:")
            # print(tab2_df_dataspecs$channeldataspacing)

            # Get data - but also add cols for channel and well
            # correct version = exactly like rows version above. but for cols.

            ## Prevent crash when row/column indexes to use don't exist in df
            print("Last col number of requested data:")
            largest_colnumber_needed <- tab2_df_dataspecs$col_beg+(tab2_df_dataspecs$channel_number-1)*tab2_df_dataspecs$channeldataspacing+(tab2_df_dataspecs$timepoint_number-1)
            print(largest_colnumber_needed)
            print("Last col number of existing data:")
            print(ncol(temp_alldata)) # last col number of existing data
            if(ncol(temp_alldata) < largest_colnumber_needed){
              # if we're requesting data outside the alldata df

              # Console
              message("Error: Do not request data from outside range of file.")
              message(paste0("Requested data up to col #", largest_colnumber_needed))
              message(paste0("Existing data's highest col number: #", ncol(temp_alldata)))

              # Modal
              showModal(modalDialog(title = "Error",
                                    paste0("Do not request data from outside range of file. ",
                                           "[Requested data up to col #", largest_colnumber_needed, ". ",
                                           "Existing data's highest col number: #", ncol(temp_alldata), ".]"),
                                    easyClose = TRUE ))

              return()
            }

            tab2_df_shiny$totaldata <- c()
            for(i in 1:tab2_df_dataspecs$channel_number){

              # find first col of data for current reading:
              firstcolnumber <- tab2_df_dataspecs$col_beg + (i-1)*tab2_df_dataspecs$channeldataspacing

              # extract data for current reading:
              temp_channeldata <- temp_alldata[tab2_df_dataspecs$row_beg:tab2_df_dataspecs$row_end, (firstcolnumber):(firstcolnumber+tab2_df_dataspecs$timepoint_number-1)]

              # EDIT: different from non-timecourse data, add in column names from timepoint time (here)
              # and columns for reading name (here) and well name (step 5):

              # timepoints as column names:
              timepoints_colnames <- paste0("timepoint_", tab2_df_dataspecs$list_of_timepoints)
              temp_channeldata <- as.data.frame(temp_channeldata) # required for 1 line data from 1 timepoint data (else crashes)
              colnames(temp_channeldata) <- timepoints_colnames

              # reading name as 'channel' column:
              temp_channeldata$channel <- tab2_df_dataspecs$channel_names[i]

              # # make temp name for wells (not essential)
              # temp_wellnames <- seq(from = 1, to = nrow(temp_channeldata), by = 1)
              # temp_wellnames <- paste0("well_", temp_wellnames)
              # temp_channeldata$well <- temp_wellnames

              # bind to final df:
              tab2_df_shiny$totaldata <- rbind(tab2_df_shiny$totaldata, temp_channeldata)

            }

            # print("total data table:")
            # print(tab2_df_shiny$totaldata)

          } # columns

          # (2c) Matrix - not avail for timecourse data

        } # channel number > 1

      } # timecourse

      # # Console checks
      # print("total data table:")
      # print(tab2_df_shiny$totaldata)

      # Show Cropped Data Tab (tab is now visible, but isn't automatically selected)
      showTab(inputId = "usp_mainpaneldata_tabset", target = "rawdata_cropped_tab", select = FALSE)

      ## SPECIFICATIONS for channel names, times and wells --------------

      if(tab2_df_dataspecs$channel_name_specification == "selected"){

        # ignore provided channel_names
        tab2_df_dataspecs$channel_names <- NULL

        # replace w values from selected cells from data
        tab2_df_dataspecs$channel_names <- c()
        for(i in 1:nrow(tab2_df_dataspecs$channel_name_indices)){
          row <- tab2_df_dataspecs$channel_name_indices[i,1]
          col <- tab2_df_dataspecs$channel_name_indices[i,2]+1
          new_channelname <- tab2_df_shiny$alldata[row,col]
          tab2_df_dataspecs$channel_names <- c(tab2_df_dataspecs$channel_names, new_channelname)
        }

      }
      print("channel_names:")
      print(tab2_df_dataspecs$channel_names)

      if(tab2_df_dataspecs$datatype == "datatype_timecourse"){
        if(tab2_df_dataspecs$timecourse_specification == "selected"){

          # ignore provided list_of_timepoints
          tab2_df_dataspecs$list_of_timepoints <- NULL

          # replace w values from selected cells from data
          tab2_df_dataspecs$list_of_timepoints <- c()
          for(i in 1:nrow(tab2_df_dataspecs$timecourse_indices)){
            row <- tab2_df_dataspecs$timecourse_indices[i,1]
            col <- tab2_df_dataspecs$timecourse_indices[i,2]+1
            new_timepoint <- tab2_df_shiny$alldata[row,col]
            tab2_df_dataspecs$list_of_timepoints <- c(tab2_df_dataspecs$list_of_timepoints, new_timepoint)
          }

        }
        print("list_of_timepoints:")
        print(tab2_df_dataspecs$list_of_timepoints)
      }

      # well data spec: see step5 below

      ## Step 5 - Well numbering (copied from parts of Tab1Step5) ---------------------

      # Used Wells -----

      if(tab2_df_dataspecs$well_data_specification == "selected"){

        # ignore provided used_wells
        tab2_df_dataspecs$used_wells <- NULL

        # replace w values from selected cells from data
        tab2_df_dataspecs$used_wells <- c()
        # overwrite row_beg etc from above
        rm(row_beg, row_end, col_beg, col_end)
        row_beg <- tab2_df_dataspecs$well_data_indices[1]
        row_end <- tab2_df_dataspecs$well_data_indices[2]
        col_beg <- tab2_df_dataspecs$well_data_indices[3]
        col_end <- tab2_df_dataspecs$well_data_indices[4]

        ##

        if(tab2_df_dataspecs$dataformat == "dataformat_rows"){ # if data in rows, then well names will form a row
          # stop if selection is >1 rows
          if(row_beg != row_end){
            message("Error: Select only 1 row.")
            showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
            tab2_df_dataspecs$used_wells <- NULL
            tab2_df_shiny$totaldata <- NULL
            return()
          }
          # stop if selection is wrong length
          if(tab2_df_dataspecs$datatype == "datatype_standard" | tab2_df_dataspecs$datatype == "datatype_spectrum"){
            if( (col_end-col_beg+1) != ncol(tab2_df_shiny$totaldata) ){
              # for std data, 'width' of column of wells should be equal to 'width' of data
              message("Error: Number of selected wells does not match the number of columns of selected data.")
              showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of columns of selected data.", easyClose = TRUE ))
              tab2_df_dataspecs$used_wells <- NULL
              tab2_df_shiny$totaldata <- NULL
              return()
            }
          } else if(tab2_df_dataspecs$datatype == "datatype_timecourse"){
            if( (col_end-col_beg+1) != (ncol(tab2_df_shiny$totaldata)-2) ){
              # for timecourse data, 'width' of column of wells should be equal to ('width' of data)-2 [minus channel and time columns]
              # NB Note this is different from COLUMN-format data, where columns are ('height' of data)*(number of channels)
              message("Error: Number of selected wells does not match the number of columns of selected data.")
              showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of columns of selected data.", easyClose = TRUE ))
              tab2_df_dataspecs$used_wells <- NULL
              tab2_df_shiny$totaldata <- NULL
              return()
            }
          }

          # SAVE DATA
          if(col_end != col_beg){ # if we have several columns, it will form a df naturally
            listofwells <- as.character(tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end]) # as array, not df
          } else if(col_end == col_beg) { # if we have a single column, we need to force a dataframe
            listofwells <- as.character(v1 = tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end]) # as array, not df
          }

        } # rows

        if(tab2_df_dataspecs$dataformat == "dataformat_columns"){ # if data in columns, then well names will form a column

          # stop if selection is >1 rows
          if(col_beg != col_end){
            message("Error: Select only 1 column.")
            showModal(modalDialog(title = "Error", "Select only 1 column.", easyClose = TRUE ))
            tab2_df_dataspecs$used_wells <- NULL
            tab2_df_shiny$totaldata <- NULL
            return()
          }

          # stop if selection is wrong length
          if(tab2_df_dataspecs$datatype == "datatype_standard" | tab2_df_dataspecs$datatype == "datatype_spectrum"){
            if( (row_end-row_beg+1) != nrow(tab2_df_shiny$totaldata) ){
              # for std data, 'height' of column of wells should be equal to 'height' of data
              message("Error: Number of selected wells does not match the number of rows of selected data.")
              showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of rows of selected data.", easyClose = TRUE ))
              tab2_df_dataspecs$used_wells <- NULL
              tab2_df_shiny$totaldata <- NULL
              return()
            }
          } else if(tab2_df_dataspecs$datatype == "datatype_timecourse"){
            if( ((row_end-row_beg+1)*tab2_df_dataspecs$channel_number) != (nrow(tab2_df_shiny$totaldata)) ){
              # for timecourse data, ('height' of column of wells)*(number of channels) should be equal to the total 'height' of the Cropped data) (aka totaldata)
              # NB Note this is different from ROW-format data, where columns are wells+2
              message("Error: Number of selected wells does not match the number of rows of selected data.")
              showModal(modalDialog(title = "Error", "Number of selected wells does not match the number of rows of selected data.", easyClose = TRUE ))
              tab2_df_dataspecs$used_wells <- NULL
              tab2_df_shiny$totaldata <- NULL
              return()
            }
          }

          # SAVE DATA
          listofwells <- tab2_df_shiny$alldata[row_beg:row_end, col_beg:col_end] # works. not list or df, but probably an array here

        }

        # assign
        tab2_df_dataspecs$used_wells <- listofwells
        print("used wells:")
        print(tab2_df_dataspecs$used_wells)

        # Checks for empty cells (couldn't do above as "" catches evthg, whereas here empty cells are now NA)
        if(any(is.na(tab2_df_dataspecs$used_wells))){
          # if any of the wells is NA, stop (apart from anything all the NAs end up at the end of the list)
          message("Error: Well name selection cannot contain empty cells.")
          showModal(modalDialog(title = "Error", "Well name selection cannot contain empty cells.", easyClose = TRUE ))
          tab2_df_dataspecs$used_wells <- NULL
          tab2_df_shiny$totaldata <- NULL
          return()
        }

      } # well data spec = select
      print("used_wells:")
      print(tab2_df_dataspecs$used_wells)

      # Add well/channel/timepoint numbering to totaldata -------

      # (a) Rows:
      if(tab2_df_dataspecs$dataformat == "dataformat_rows"){

        if(tab2_df_dataspecs$datatype == "datatype_standard" | tab2_df_dataspecs$datatype == "datatype_spectrum"){

          # if data is in rows, wells are in columns.
          # so wells need to be the column names
          colnames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$used_wells
          rownames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$channel_names # fails for timecourse bc there are rows for each timepoint

        } else if(tab2_df_dataspecs$datatype == "datatype_timecourse"){

          ## timecourse - rows - 1 channel and >1 channel

          # changes from standard data version:
          # colnames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$used_wells # yes but include the two new columns (see below)
          # rownames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$channel_names # no need for rownames

          colnames(tab2_df_shiny$totaldata) <- c(tab2_df_dataspecs$used_wells, "channel", "time")

        } # timecourse
      } # rows

      # (b) Columns:
      if(tab2_df_dataspecs$dataformat == "dataformat_columns"){

        if(tab2_df_dataspecs$datatype == "datatype_standard" | tab2_df_dataspecs$datatype == "datatype_spectrum"){

          # if data is in columns., wells are in rows.
          # so wells need to be the row names
          rownames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$used_wells
          colnames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$channel_names

        } else if(tab2_df_dataspecs$datatype == "datatype_timecourse"){

          ## timecourse - cols - 1 or >1 channel

          # changes from standard data version:
          # rownames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$used_wells # replace rownames with "well" column - see below
          # colnames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$channel_names # skip

          wells_column <- rep(tab2_df_dataspecs$used_wells, tab2_df_dataspecs$channel_number) # repeat wells list as many times as channels
          tab2_df_shiny$totaldata["well"] <- wells_column

        } # timecourse

      } # columns

      # (c) Matrix (like Rows):
      if(tab2_df_dataspecs$dataformat == "dataformat_matrix"){

        # if data is in rows, wells are in columns.
        # so wells need to be the column names
        colnames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$used_wells
        rownames(tab2_df_shiny$totaldata) <- tab2_df_dataspecs$channel_names

      } # matrix

      # print("totaldata:")
      # print(tab2_df_shiny$totaldata)

      ## Step7: PARSED DATA (essentially copied from Tab1Step7) -----------

      if(tab2_df_dataspecs$datatype == "datatype_standard" | tab2_df_dataspecs$datatype == "datatype_spectrum"){

        # 1. Make data block - format: wells in (96) rows, channels in columns
        # Add well numbering to totaldata
        # (a) Rows and (c) Matrices:
        if(tab2_df_dataspecs$dataformat == "dataformat_rows" | tab2_df_dataspecs$dataformat == "dataformat_matrix"){

          # data in rows, wells as columns

          # Remove Overflow text
          datablock <- sapply(tab2_df_shiny$totaldata, function(x) as.numeric(x) )

          if(tab2_df_dataspecs$channel_number == 1){

            # Transpose - so wells are in rows
            # Std data * one channel = "numeric", not df.
            # Forcing a df here didn't enable a transpose below. It instead caused a transpose by itself.
            datablock <- data.frame(v1 = datablock) # well colnames DO turn into rownames # but channel rownames DO NOT turn into colnames

          } else {

            # Transpose - so wells are in rows
            datablock <- t(datablock) # well colnames DO turn into rownames # but channel rownames DO NOT turn into colnames

            # Sapply / Transpose turns df into matrix. Switch back.
            datablock <- as.data.frame(datablock)

          }

          # Channels as column names
          colnames(datablock) <- tab2_df_dataspecs$channel_names # populate colnames

          # Wells from rownames to column
          datablock$well <- rownames(datablock) # make column from rownames
          rownames(datablock) <- NULL
          datablock <- datablock %>%
            dplyr::relocate(well) # make well the first column

        } # rows
        # (b) Columns:
        if(tab2_df_dataspecs$dataformat == "dataformat_columns"){

          # data in columns, wells as rows

          # Remove Overflow text
          datablock <- sapply(tab2_df_shiny$totaldata, function(x) as.numeric(x) )
          # well rownames ARE NOT retained in Parsed Data, but channel colnames ARE retained in Parsed Data

          # Sapply turns df into matrix. Switch back.
          datablock <- as.data.frame(datablock)

          # Channels as column names # already there

          # Wells as a new column
          datablock$well <- tab2_df_dataspecs$used_wells
          # rownames(datablock) <- NULL
          datablock <- datablock %>%
            dplyr::relocate(well) # make well the first column

        } # cols

      } else if(tab2_df_dataspecs$datatype == "datatype_timecourse"){

        # 1. Make data block - format: wells in (96) rows, channels in columns [ie. similar to columns format]
        # Add well numbering to totaldata [done already for timecourse]
        # (a) Rows
        if(tab2_df_dataspecs$dataformat == "dataformat_rows"){ # [matrix format doesn't exist for timecourse data]

          # data in rows, wells as columns [plus channel and time cols at end]

          # Pivot first
          # get wells down from colnames
          datablock <- tab2_df_shiny$totaldata %>%
            tidyr::pivot_longer(cols = -c("channel", "time"), names_to = "well", values_to = "value")

          # make value column numeric (it's 'character' bc of overflow wells)
          datablock <- datablock %>%
            dplyr::mutate_at(c("value"), as.numeric) # mutate() by itself fails. this works. https://www.statology.org/convert-multiple-columns-to-numeric-dplyr/

          # put channels as colnames
          datablock <- datablock %>%
            tidyr::pivot_wider(names_from = "channel", values_from = "value")

        } else if(tab2_df_dataspecs$dataformat == "dataformat_columns"){
          # (b) Columns:

          # data in columns, wells as rows

          # make numeric first - as mixture of numeric/character columns cannot be pivoted
          # then pivot - get timepoints down from colnames
          datablock <- tab2_df_shiny$totaldata %>%
            # dplyr::mutate_at(-c("channel", "well"), as.numeric) %>% # mutate() by itself fails. this works. https://www.statology.org/convert-multiple-columns-to-numeric-dplyr/
            dplyr::mutate_at(dplyr::vars(-c("channel", "well")), as.numeric) %>% # mutate_at(-c("channel", "well"), as.numeric) failed here
            tidyr::pivot_longer(cols = -c("channel", "well"), names_to = "time",
                                names_prefix = "timepoint_", values_to = "value")

          # put channels as colnames
          datablock <- datablock %>%
            tidyr::pivot_wider(names_from = "channel", values_from = "value")

        }

      } # timecourse

      # print("datablock current:")
      # print(datablock)

      ## Bind with plate layout metadata
      if( (input$tab2_metadata_input == 1 & isFALSE(tab2_df_shiny$metadata_skip)) | input$tab2_metadata_input == 2){ ### meta
        # if we're uploading example metadata, and we have not selected "skip metadata"
        # or if we're uploading new metadata

        # Identify metadata format ### matrix format
        if(input$tab2_metadata_input == 1 & !grepl("matrix", input$tab2_select_examplemetadata)){
          # if we're uploading example metadata, and the metadata is in tidy format
          metadata_format <- "tidy"
        }
        if(input$tab2_metadata_input == 1 & grepl("matrix", input$tab2_select_examplemetadata)){
          # if we're uploading example metadata, and the metadata is in matrix format
          metadata_format <- "matrix"
        }
        if(input$tab2_metadata_input == 2 & input$tab2_metadata_format == "tidy"){
          # if we're uploading new metadata, and the metadata is in tidy format
          metadata_format <- "tidy"
        }
        if(input$tab2_metadata_input == 2 & input$tab2_metadata_format == "matrix"){
          # if we're uploading new metadata, and the metadata is in matrix format
          metadata_format <- "matrix"
        }

        # Parse data, depending on metadata format ### matrix format
        if(metadata_format == "tidy"){ # standard parsing

          # Check that metadata has 'well' column
          if( (isFALSE(tab2_df_shiny$metadata_skip)) ### meta
              & (!any(grepl("well", colnames(tab2_df_shiny$metadata)))) ){ ### R CMD check doesn't like the fact that I assume a well column. But there's a check here!
            # message("Error: Can't merge Data and Metadata when Metadata does not contain a 'well' column.")
            # showModal(modalDialog(title = "Error", "Can't merge Data and Metadata when Metadata does not contain a 'well' column.", easyClose = TRUE ))

            message("Error: Can't merge Data and tidy Metadata if Metadata does not contain a 'well' column.
                  Verify that the Metadata is in tidy format. If so, add a 'well' column.
                  If it is in matrix format, select 'Matrix format' in the Metadata upload section above, click Submit to reupload the Metadata, before retrying the Parsing.") ### matrix format
            showModal(modalDialog(title = "Error", "Can't merge Data and Metadata when Metadata does not contain a 'well' column.
                                Verify that Metadata is in tidy format. If so, add a 'well' column.
                                If it is in matrix format, select 'Matrix format' in the Metadata upload section above, click Submit to reupload the Metadata, before retrying the Parsing.",
                                  easyClose = TRUE )) ### matrix format
            return()
          }
          parseddata <- dplyr::left_join(tab2_df_shiny$metadata, datablock, by = "well")
          ### R CMD check doesn't like the fact that I assume a well column. But there's a check at the top!

        }

        if(metadata_format == "matrix"){ # matrix parsing

          # parse with matrix format metadata with plater ### matrix format
          metadata_tidy <- read_matrixformat_metadata(data = tab2_df_shiny$metadata, well_ids_column = "well")
          metadata_tidy

          parseddata <- dplyr::left_join(metadata_tidy, datablock, by = "well")
          ### R CMD check doesn't like the fact that I assume a well column. But there's a check at the top!
        }

        ## Make row and column columns
        parseddata$row <- substr(x = parseddata$well, start = 1, stop = 1)
        parseddata$column <- as.numeric(substr(x = parseddata$well, start = 2, stop = nchar(parseddata$well)))
        parseddata <- dplyr::arrange_at(parseddata, dplyr::vars(.data$row, .data$column))

      } else {

        ## Skip metadata joining, and simply return tidied dataframe ### meta
        parseddata <- datablock

      } ### meta

      # print("parseddata:")
      # print(parseddata)

      # SAVE / assign to reactive -------
      tab2_df_shiny$parseddata <- parseddata # to save and to display as DT

    }) # end withprogress

    # Show Parsed data Tab (tab is now visible, AND is automatically selected)
    showTab(inputId = "usp_mainpaneldata_tabset", target = "parseddata_tab", select = TRUE)

  }) # use saved parser

  # Tab2: DOWNLOAD CSV BUTTON ------

  output$tab2_download_table_CSV <- downloadHandler(
    filename <- function() {
      time <- format(Sys.time(), "%Y%m%d_%H.%M") # ie. "20190827_17.33"
      paste("data_parsedByParsley_", time, ".csv", sep = "")
    },
    content <- function(file) { # just leave in "file", this is default and does refer to your file that will be made
      df <- tab2_df_shiny$parseddata
      utils::write.csv(df, file, row.names = FALSE)
    },
    contentType = "text/csv" # from downloadHandler help page
  )

} # server

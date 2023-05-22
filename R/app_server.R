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

      # Which file to upload
      file_in <- input$upload_data # the fileInput file selection device for Uploading one file was named "upload_data"
      # print(file_in) # check
      # print(file_in$datapath) # check

      # Do the upload

      # Reading the file:
      isolate({

        # Error handling when you try and upload the wrong file type: # 1. trycatch catches error
        tryCatch({

          if(input$upload_data_delim == ","){ ### delim

            # read.csv
            data <- utils::read.csv(file_in$datapath, header = FALSE) ###
            # print(head(data)) # check

          } ### delim

          if(input$upload_data_delim != ","){ ### delim

            # read.table
            data <- utils::read.table(file_in$datapath, header = FALSE,
                                      sep = input$upload_data_delim)

          } ### delim

        }, # end first {} block in tryCatch
        error = function(err) { message(err) },
        warning = function(warn) { message(warn) }
        ) # end tryCatch
        # Error handling when you try and upload the wrong file type: # 2. req() stops rest of function
        req(is.data.frame(data)) # read_delim produces tibbles. tibble::is_tibble(data) also works.

      }) # end isolate

      # LOAD
      # 1. Update all data (# Update df_shiny with converted dataframe)
      df_shiny$alldata <- data

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
        df_shiny$metadata <- utils::read.csv(filepathtouse)
        # print(names(df_shiny$metadata)) # check # works

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

      # Which file to upload
      file_in <- input$upload_metadata # the fileInput file selection device for Uploading one file was named "upload_metadata"
      # print(file_in) # check
      # print(file_in$datapath) # check

      # Do the upload

      # Reading the file:
      isolate({

        # Error handling when you try and upload the wrong file type: # 1. trycatch catches error
        tryCatch({

          # read.csv
          data <- utils::read.csv(file_in$datapath, header = TRUE) # metadata should always have header (ie 1st row = colnames)
          # print(head(data)) # check

        }, # end first {} block in tryCatch
        error = function(err) { message(err) },
        warning = function(warn) { message(warn) }
        ) # end tryCatch
        # Error handling when you try and upload the wrong file type: # 2. req() stops rest of function
        req(is.data.frame(data)) # read_delim produces tibbles. tibble::is_tibble(data) also works.

      }) # end isolate

      # LOAD
      # 1. Update metadata
      df_shiny$metadata <- data

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
              rownames = FALSE, # remove row numbering
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
              rownames = FALSE, # remove row numbering
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
              rownames = FALSE, # remove row numbering
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
    channel_names = NULL,
    wav_min = NULL,
    wav_max = NULL,
    wav_interval = NULL,

    # step2b
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
        df_dataspecs$channel_names <- NULL
        df_dataspecs$channel_number <- NULL
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
          df_dataspecs$channel_names <- NULL
          df_dataspecs$channel_number <- NULL
          return()
        }

        # Expected Channel Number
        nrow_expected <- df_dataspecs$channel_number
        # Channels Selected
        nrow_submitted <- nrow(input$RawDataTable_cells_selected)
        # Need as many selections as channels
        if( (nrow_expected > nrow_submitted) | (nrow_expected < nrow_submitted) ){
          message("Error: Number of reading names does not match number of readings specified.")
          showModal(modalDialog(title = "Error", "Number of reading names does not match number of readings specified.", easyClose = TRUE ))
          df_dataspecs$channel_names <- NULL
          df_dataspecs$channel_number <- NULL
          return()
        }

        # Extract values from alldata
        all_selected_cells <- input$RawDataTable_cells_selected
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
          df_dataspecs$channel_names <- NULL
          df_dataspecs$channel_number <- NULL
          return()
        }

        # Update channel_names
        df_dataspecs$channel_names <- selectedcell_values

      } else if(input$channel_names_input == "channel_names_input_manual"){

        # Channel names Option2: get channel names from text input ----

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
          df_dataspecs$channel_names <- NULL
          df_dataspecs$channel_number <- NULL
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
                              paste0("More expected timepoints than calculated timepoints. Using calculated number of timepoints (", df_dataspecs$timepoint_number, "). Resultant timepoints: ",
                                     df_dataspecs$list_of_timepoints[1], ", ", df_dataspecs$list_of_timepoints[2], " ... ",
                                     df_dataspecs$list_of_timepoints[length(df_dataspecs$list_of_timepoints)], " min."), # last timepoint
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
                              paste0("Fewer expected timepoints than calculated timepoints. Truncating timepoints to expected number of timepoints (",
                                     df_dataspecs$timepoint_number, "). Resultant timepoints: ",
                                     df_dataspecs$list_of_timepoints[1], ", ", df_dataspecs$list_of_timepoints[2], " ... ",
                                     df_dataspecs$list_of_timepoints[length(df_dataspecs$list_of_timepoints)], " min."), # last timepoint
                              easyClose = TRUE ))
        # can't straightforwardly paste the whole list in. this is a compromise w caveat that we're assuming at least 2 timepoints (not too much of a stretch hopefully!)

      }

    } # timecourse

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

    print("first channel data:")
    print(df_dataspecs$firstchanneldata)

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

    # Console checks
    print("total data table:")
    print(df_shiny$totaldata)

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

      all_selected_cells <- input$RawDataTable_cells_selected

      if(nrow(input$RawDataTable_cells_selected) != 2){
        # do nothing until there are selections
        message("Error: Select two cells.")
        showModal(modalDialog(title = "Error", "Select two cells.", easyClose = TRUE ))
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

      if(df_dataspecs$dataformat == "dataformat_rows"){ # if data in rows, then well names will form a row

        # stop if selection is >1 rows
        if(row_beg != row_end){
          message("Error: Select only 1 row.")
          showModal(modalDialog(title = "Error", "Select only 1 row.", easyClose = TRUE ))
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

    print("totaldata:")
    print(df_shiny$totaldata)

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

    # Check that metadata has 'well' column
    if( (isFALSE(df_shiny$metadata_skip)) ### meta
        & (!any(grepl("well", colnames(df_shiny$metadata)))) ){ ### R CMD check doesn't like the fact that I assume a well column. But there's a check here!
      message("Error: Can't merge Data and Metadata when Metadata does not contain a 'well' column.")
      showModal(modalDialog(title = "Error", "Can't merge Data and Metadata when Metadata does not contain a 'well' column.", easyClose = TRUE ))
      return()
    }

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

    print("datablock current:")
    print(datablock)

    ## Bind with plate layout metadata
    if(isFALSE(df_shiny$metadata_skip)){ ### meta
      parseddata <- dplyr::left_join(df_shiny$metadata, datablock, by = "well")
      ### R CMD check doesn't like the fact that I assume a well column. But there's a check at the top!

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
    contentType = "test/csv" # from downloadHandler help page
  )


} # server

#' app_ui
#'
#' ui function
#'
#' @param request internal parameter for shiny
#' @import shiny
#' @noRd

# ui ----

# library(shiny)
# library(dplyr)
# library(DT)
# library(bslib)

app_ui <- function(request) { # shiny as package requires ui as function
  navbarPage(

  # ui <- navbarPage(

  title = "Parsley",
  id = "navbarpage",
  selected = "byop", # use 'value' if 'value' exists! # reqd for waiter.

  # Theme:
  # theme = shinythemes::shinytheme("paper"),
  theme = bslib::bs_theme(bootswatch = "flatly"),
  # NB. bslib has issue with DT displaying BELOW sidebar unless the sidebarpanel and mainpanel are wrapped in sidebarLayout

  # Top Tab 1: Build Your Own Parser -------------------------------------------------------------------------------------

  tabPanel("Build Your Own Parser", icon = icon("gear"),
           value = "byop", # reqd for tab switching

           ## Data input panel (TOP)
           fluidRow(

             # Column1
             column(4,

                    strong("How to Build a Parser:"), br(), br(),
                    # p(strong("Raw Data:"), "Upload a raw data file from your plate reader experiment in CSV format."),
                    p(strong("Raw Data:"), "Upload a raw data file from your plate reader experiment."), ### excel
                    conditionalPanel(
                      condition = "input.submit_exampledata_button != '0' || input.submit_datafile_button != '0'",
                      # p(strong("Metadata:"), "Upload a metadata file in CSV format. This should include a 'well' column in 'A1->H12' format.")
                      p(strong("Metadata:"), "Upload a metadata file. For tidy format metadata files, include a 'well' column in 'A1->H12' format.
                        To skip metadata addition, choose 'Skip Metadata'.") ### excel ### matrix format
                    ),
                    conditionalPanel(
                      condition = "input.submit_examplemetadata_button != '0' || input.submit_metadatafile_button != '0'",
                      p(strong("Data Specification:"), "Follow the instructions below to build the parser for your plate reader data file.")
                    )

             ),
             # Column2
             column(4,

                    strong("Raw Data:"), br(), br(),
                    radioButtons("data_input",
                                 label = NULL, # NULL < "" in terms of space
                                 choices = list("Load example" = 1,
                                                # "Upload CSV" = 2
                                                "Upload file" = 2 ### excel
                                 ), selected = 1),

                    # Conditional Sub-Panels depending on Data Input Type
                    # Example Data
                    conditionalPanel(
                      condition = "input.data_input=='1'",
                      p("Example data:"),
                      selectInput("select_exampledata",
                                  label = NULL,
                                  list("1 - Green fluorescence data (rows)" = "data_green_rows",
                                       "2 - Green fluorescence data (cols)" = "data_green_cols",
                                       "3 - Green fluorescence data (matrix)" = "data_green_matrix",
                                       "4 - Absorbance spectrum data (cols)" = "data_absorbance_spectrum_cols",
                                       "5 - Absorbance spectrum data (rows)" = "data_absorbance_spectrum_rows",
                                       "6 - Timecourse data (rows)" = "data_timecourse_rows",
                                       "7 - Timecourse data (cols)" = "data_timecourse_columns"),
                                  selected = "data_green_rows"),
                      actionButton("submit_exampledata_button", "Submit", class = "btn-primary"),
                      actionButton("reset_exampledata_button", "Clear")
                    ),
                    # Single file upload
                    conditionalPanel(
                      condition = "input.data_input=='2'",
                      fileInput("upload_data",
                                label = NULL,
                                multiple = FALSE,
                                # accept = c("text/csv",
                                #            "text/tab-separated-values",
                                #            "text/plain",
                                #            "application/vnd.ms-excel" ### excel # https://www.iana.org/assignments/media-types/media-types.xhtml
                                #            ) # hashed after adding excel because excel MIME type fails
                      ), ### fileinput
                      selectInput("upload_data_delim",
                                  # "Delimiter (File type)", ### delim
                                  "File type", ### excel
                                  list("Comma (CSV)" = ",",
                                       "Semicolon (CSV)" = ";",
                                       "Tab (TSV)" = "\t",
                                       # "Space" = " "
                                       "Excel (XLSX)" = "excel" ### excel
                                  ),
                                  selected = "Comma (CSV)"),
                      actionButton("submit_datafile_button", "Submit", class = "btn-primary"),
                      actionButton("reset_datafile_button", "Clear"), # Reset button akin to https://shiny.rstudio.com/articles/action-buttons.html
                      conditionalPanel(
                        condition = "input.submit_datafile_button != '0'",
                        br(),
                        p("Uploaded file name:"),
                        verbatimTextOutput("myFileName")
                      )
                    ) # single file upload

             ),
             # Column3
             column(4,

                    # Metadata upload
                    conditionalPanel(
                      condition = "input.submit_exampledata_button != '0' || input.submit_datafile_button != '0'",

                      strong("Metadata:"), br(), br(),
                      radioButtons("metadata_input",
                                   label = NULL,
                                   choices = list("Load example" = 1,
                                                  # "Upload CSV" = 2
                                                  "Upload file" = 2 ### excel
                                   ), selected = 1),

                      # Conditional Sub-Panels depending on Data Input Type
                      # Example metadata
                      conditionalPanel(
                        condition = "input.metadata_input == '1'",
                        p("Example metadata:"),
                        selectInput("select_examplemetadata",
                                    label = NULL,
                                    # list("1 - Green fluorescence data" = "metadata_green",
                                    #      "2 - Timecourse data" = "metadata_timecourse",
                                    #      "Skip metadata" = "metadata_skip" ### meta
                                    #      ),
                                    list("1 - Green fluorescence data (tidy)" = "metadata_green",
                                         "2 - Green fluorescence data (matrix)" = "metadata_green_matrix", ### matrix format
                                         "3 - Timecourse data (tidy)" = "metadata_timecourse",
                                         "4 - Timecourse data (matrix)" = "metadata_timecourse_matrix", ### matrix format
                                         "SKIP METADATA" = "metadata_skip" ### meta
                                    ), ### matrix format
                                    selected = "metadata_green"),
                        actionButton("submit_examplemetadata_button", "Submit", class = "btn-primary"),
                        actionButton("reset_examplemetadata_button", "Clear")
                      ),
                      # Upload metadata
                      conditionalPanel(
                        condition = "input.metadata_input == '2'",
                        fileInput("upload_metadata",
                                  label = NULL,
                                  multiple = FALSE
                                  # accept = c("text/csv",
                                  #            "application/vnd.ms-excel" ### excel
                                  # ) # hashed after adding excel because excel MIME type fails
                        ), ### fileinput
                        selectInput("metadata_delim",
                                    # "Delimiter (File type)", ### delim
                                    "File type", ### excel
                                    list("Comma (CSV)" = ",",
                                         "Semicolon (CSV)" = ";",
                                         "Tab (TSV)" = "\t",
                                         # "Space" = " "
                                         "Excel (XLSX)" = "excel" ### excel
                                    ),
                                    selected = "Comma"), # added back after adding excel option
                        selectInput("metadata_format", ### matrix format
                                    "Metadata format",
                                    list("Tidy format" = "tidy",
                                         "Matrix format" = "matrix"
                                    ),
                                    selected = "Tidy format"), # added back after adding excel option
                        actionButton("submit_metadatafile_button", "Submit", class = "btn-primary"),
                        actionButton("reset_metadatafile_button", "Clear"),
                        conditionalPanel(
                          condition = "input.submit_metadatafile_button != '0'",
                          br(),
                          p("Uploaded file name:"),
                          verbatimTextOutput("metadata_name")
                        )
                      ) # metdata upload
                    ) # conditional panel for metadata

             ) # column3

           ), # fluidrow, top row

           hr(),

           ## Main UI revealed when data is uploaded ---------------------------------------------------------
           conditionalPanel(
             condition = "input.submit_exampledata_button != '0' || input.submit_datafile_button != '0'",

             # shinythemes version:
             # sidebarPanel(),
             # mainPanel(),

             # # bslib theme version: (without this mainpanel is served under sidebarpanel)
             # sidebarLayout(
             #   sidebarPanel(),
             #   mainPanel()
             # ),

             sidebarLayout(

               ## Left hand sidebar -------------------------------------------------------------------------------------
               sidebarPanel(
                 width = 4,
                 style = "height: 90vh; overflow-y: auto; padding-top: 10px; padding-bottom: 10px;",
                 # css to make scrollbar for the sidebar # https://www.r-bloggers.com/2022/06/scrollbar-for-the-shiny-sidebar/
                 # padding 10px allows sidebar text to be in line w mainpanel text (think default is 20px)

                 # Temporary placeholder text for sidebar before start button is pressed
                 conditionalPanel(
                   condition = "input.start_building_button == '0'", # before start button is pressed

                   strong("Instructions for Data Specification steps"), br(), br(),
                   p(icon("table"), " Uploaded data file contents are displayed in tabs on the right. These are there to allow you to check you are using the correct files,
                   and that the parser is being built correctly."),
                   p(icon("hand-pointer"), " Note that the Raw Data table has clickable/selectable cells. This is important for some of the later steps."),
                   p(icon("circle-exclamation"), " Be careful: clicking on the column names of any of these data tables reorders those columns.
                 As this action cannot be undone and interferes with a number of steps, it is best to re-upload files if you accidentally click on the column names."),
                   p("Once both data and metadata are uploaded, you can begin building the parser.")

                 ),

                 # Build Parser button - visible after metadata - but only visible until pressed
                 conditionalPanel(
                   condition = "(input.submit_examplemetadata_button != '0' || input.submit_metadatafile_button != '0') && input.start_building_button == '0'",

                   hr(),
                   actionButton("start_building_button",
                                "Build Parser",
                                icon = icon("gear"), class = "btn-success"),
                 ),

                 # Rest of sidebarpanel - reveal after 'build parser' button is pressed
                 conditionalPanel(
                   condition = "input.start_building_button != '0'",

                   strong("Data specification"), br(), br(),
                   p("Proceed through the sections in order. Follow the instructions under each step, then click 'Set'.
                 Check the submitted values and their results with 'View' to toggle the 'Data specifications' tab.
               When satisfied, 'Lock' the section to mark it as complete, before proceeding to the next one."), hr(),

                   # Step 1 -----
                   strong("1) Data format"), br(),
                   p("Choose data type and format."),
                   selectInput("datatype", label = NULL, # NULL < "" in terms of space
                               list(
                                 "[Data type]" = "datatype_null",
                                 "Standard" = "datatype_standard", # "standard absorbance/fluorescence data" is how it was first written
                                 "Spectrum" = "datatype_spectrum", # spectra
                                 "Timecourse" = "datatype_timecourse" # timecourse data
                               ),
                               selected = "datatype_null"),
                   selectInput("dataformat", label = NULL,
                               list("[Data format]" = "dataformat_null",
                                    "Data in Rows (Wells in Columns)" = "dataformat_rows",
                                    "Data in Columns (Wells in Rows)" = "dataformat_columns",
                                    "Data in Matrix format" = "dataformat_matrix"),
                               selected = "dataformat_null"),

                   actionButton("submit_dataformat_button", "Set", class = "btn-primary"),
                   actionButton("view_dataspecs_button1", "View", class = "btn-info"),

                   ## "Mark as complete" v2 - actionbutton whose icon is updated when clicked
                   actionButton("step1_checkbox_button",
                                label = NULL, icon("lock-open"),
                                class = "btn-default"),

                   br(), br(),

                   # Steps 2-7 -----
                   conditionalPanel(
                     condition = "input.step1_checkbox_button %2 == 1",

                     # Step 2 -----
                     strong("2) Reading names"), br(),

                     # STD AND TIMECOURSE
                     conditionalPanel(
                       condition = "input.datatype == 'datatype_standard' || input.datatype == 'datatype_timecourse'",

                       p("Specify the number and names of all the readings taken."),
                       p(icon("circle-info"), "Readings from a plate reader are typically absorbance or fluorescence measurements.
                       The reading names are the labels you want to give each reading. These will become column names in the parsed data.
                     As such, it's important that the names are unique (no duplicates), and that they do not contain spaces or punctuation, although underscores (_) are OK."),

                       numericInput("channel_number", label = "# Readings", value = 1, min = 1, max = NA), # reading notation changed (but only for ui text, haven't changed server objects)

                       selectInput("channel_names_input", label = "Reading names specification",
                                   list("[Reading names input]" = "channel_names_input_null",
                                        "Select cells with reading names" = "channel_names_input_select",
                                        "Enter reading names manually" = "channel_names_input_manual"),
                                   selected = "channel_names_input_null"), # reading notation changed (but only for ui text, haven't changed server objects)
                       conditionalPanel(
                         condition = "input.channel_names_input == 'channel_names_input_select'",
                         p(icon("hand-pointer"), "Select the cells in the Raw Data table that contain the reading names, in order from first to last."),
                         # arrow-pointer # hand-pointer
                         p(icon("circle-info"), "Selections on large data files can be slow.")
                       ),
                       conditionalPanel(
                         condition = "input.channel_names_input == 'channel_names_input_manual'",
                         p(icon("pencil"), "Manually enter a comma-separated list of reading names."),
                         textInput("channel_names_manual_input", label = NULL,
                                   placeholder = "eg: OD600, 700, GFP, G1G2_060")
                       )

                     ),
                     # SPECTRA
                     conditionalPanel(
                       condition = "input.datatype == 'datatype_spectrum'",

                       p("Enter spectrum wavelength settings."),

                       numericInput("wav_min", label = "min (eg. 200nm)", value = 200, min = 1, max = NA),
                       numericInput("wav_max", label = "max (eg. 1000nm)", value = 1000, min = 1, max = NA),
                       numericInput("wav_interval", label = "interval (eg. 1nm)", value = 1, min = 1, max = NA)
                     ),

                     actionButton("submit_channelnames_button", "Set", class = "btn-primary"),
                     actionButton("view_dataspecs_button2", "View", class = "btn-info"),
                     actionButton("step2_checkbox_button",
                                  label = NULL, icon("lock-open"),
                                  class = "btn-default"),
                     br(), br(),

                     # Step 2B - Timecourse settings ------
                     conditionalPanel(
                       condition = "input.datatype == 'datatype_timecourse'",

                       strong("2b) Timecourse settings"), br(),
                       p("Specify the time points in the data."),

                       # # v1
                       # p("Enter timecourse settings."),
                       #
                       # # for timecourse data:
                       # numericInput("timecourse_firsttimepoint", label = "First timepoint (min)", value = 0, min = 0, max = NA),
                       # numericInput("timecourse_duration", label = "Duration  (min)", value = 960, min = 1, max = NA),
                       # numericInput("timecourse_interval", label = "Interval  (min)", value = 30, min = 1, max = NA),
                       # numericInput("timepoint_number_expected", label = "# Timepoints expected", value = 32, min = 1, max = NA),

                       # v2 ### timepoints from data
                       selectInput("timecourse_input", label = "Time course specification",
                                   list("[Time course input]" = "timecourse_input_null",
                                        "Select cells with timepoints" = "timecourse_input_select",
                                        "Enter timecourse settings" = "timecourse_input_manual"),
                                   selected = "timecourse_input_null"),
                       conditionalPanel(
                         condition = "input.timecourse_input == 'timecourse_input_select'",
                         p(icon("hand-pointer"), "Select the cells in the Raw Data table that contain the timepoints, in order from first to last."),
                         p(icon("circle-info"), "Selections on large data files can be slow.")
                       ),
                       conditionalPanel(
                         condition = "input.timecourse_input == 'timecourse_input_manual'",
                         # numericInput("timecourse_firsttimepoint", label = "First timepoint (min)", value = 0, min = 0, max = NA),
                         # numericInput("timecourse_duration", label = "Duration  (min)", value = 960, min = 1, max = NA),
                         # numericInput("timecourse_interval", label = "Interval  (min)", value = 30, min = 1, max = NA),
                         # numericInput("timepoint_number_expected", label = "# Timepoints expected", value = 32, min = 1, max = NA)

                         numericInput("timecourse_firsttimepoint", label = "First timepoint", value = 0, min = 0, max = NA), ### minutes
                         numericInput("timecourse_duration", label = "Duration", value = 960, min = 1, max = NA),
                         numericInput("timecourse_interval", label = "Interval", value = 30, min = 1, max = NA),
                         numericInput("timepoint_number_expected", label = "# Timepoints expected", value = 32, min = 1, max = NA)
                       ),
                       # v2 end

                       actionButton("submit_timepointvars_button", "Set", class = "btn-primary"),
                       actionButton("view_dataspecs_button2b", "View", class = "btn-info"),
                       actionButton("step2b_checkbox_button",
                                    label = NULL, icon("lock-open"),
                                    class = "btn-default"),
                       br(), br()
                     ),

                     # Step 3 -------
                     strong("3) Data from first reading"), br(),
                     conditionalPanel(
                       condition = "input.datatype == 'datatype_standard'",
                       p(icon("hand-pointer"), "Select first and last cell from the first reading."),
                       p(icon("circle-info"), "If data is in rows, both cells need to be in the same row. If data is in columns, both cells need to be in the same column.
                       For matrix format data, select cells corresponding to wells A1 and H12."),
                       p(icon("triangle-exclamation"), "Selections on large data files can be slow.")
                     ),
                     conditionalPanel(
                       condition = "input.datatype == 'datatype_spectrum'",
                       p(icon("hand-pointer"), "Select first and last cell from the first reading."),
                       p(icon("circle-info"), "If data is in rows, both cells need to be in the same row. If data is in columns, both cells need to be in the same column."),
                       p(icon("triangle-exclamation"), "Selections on large data files can be slow.")
                     ),
                     conditionalPanel(
                       condition = "input.datatype == 'datatype_timecourse'",
                       p(icon("hand-pointer"), "Select first and last cell from the first timepoint of the first reading."),
                       p(icon("circle-info"), "The app assumes consecutive timepoints within a single channel are grouped together in consecutive rows or columns without breaks."),
                       p(icon("triangle-exclamation"), "Selections on large data files can be slow.")
                     ),

                     actionButton("submit_firstchanneldata_button", "Set", class = "btn-primary"),
                     actionButton("view_dataspecs_button3", "View", class = "btn-info"),
                     actionButton("step3_checkbox_button",
                                  label = NULL, icon("lock-open"),
                                  class = "btn-default"),
                     br(), br(),

                     # Step 4 -----
                     strong("4) Total data"), br(),
                     p("Enter the spacing between data in consecutive readings, to allow the app to find and extract the data from all readings.
                     If data contains only 1 reading, the number below will be ignored."),
                     conditionalPanel(
                       condition = "input.dataformat == 'dataformat_rows' && input.datatype == 'datatype_standard'",
                       p(icon("circle-info"), "How many rows separate the data in the first and second readings?
                         (Data in consecutive rows = 1; Data with 1 blank row between channels = 2.)")
                     ),
                     conditionalPanel(
                       condition = "input.dataformat == 'dataformat_columns' && input.datatype == 'datatype_standard'",
                       p(icon("circle-info"), "How many columns separate the data in the first and second readings?
                        (Data in consecutive columns = 1; Data with 1 blank column between channels = 2.)")
                     ),
                     conditionalPanel(
                       condition = "input.dataformat == 'dataformat_matrix' && input.datatype == 'datatype_standard'",
                       p(icon("circle-info"), "How many rows separate the first row of the first reading and the first row of the second reading?
                       For 'horizontal' matrix data: Data without gaps = 8; Data with 1 blank row between readings = 9.
                       For 'vertical' matrix data: Data without gaps = 12; Data with 1 blank row between readings = 13.")
                     ),
                     conditionalPanel(
                       condition = "input.dataformat == 'dataformat_rows' && input.datatype == 'datatype_timecourse'",
                       p(icon("circle-info"), "How many rows separate the first timepoint of the first reading and the first timepoint of the second reading?
                       For 10 timepoints: Data without gaps = 10; Data with 1 blank row between readings = 11.")
                     ),
                     conditionalPanel(
                       condition = "input.dataformat == 'dataformat_columns' && input.datatype == 'datatype_timecourse'",
                       p(icon("circle-info"), "How many columns separate the first timepoint of the first reading and the first timepoint of the second reading?
                       For 10 timepoints: Data without gaps = 10; Data with 1 blank column between readings = 11.")
                     ),

                     numericInput("channeldataspacing", label = NULL,
                                  value = 1, min = 1, max = NA),

                     actionButton("submit_channeldataspacing_button", "Set", class = "btn-primary"),
                     actionButton("view_dataspecs_button4", "View", class = "btn-info"),
                     actionButton("step4_checkbox_button",
                                  label = NULL, icon("lock-open"),
                                  class = "btn-default"),

                     # VIEW CROPPED DATA
                     actionButton("view_croppeddata_button4", "View Cropped Data", class = "btn-success"),
                     # success = green, secondary = white, warning = yellow etc https://getbootstrap.com/docs/4.0/components/buttons/
                     br(), br(),

                     # Step 5 -----
                     strong("5) Well numbering"), br(),

                     # # v1 ### well
                     # p("Select starting well and orientation of data."),
                     # p(icon("circle-info"), "The app assumes use of a 96-well plate (A1-H12) configuration with no wells missing.
                     # If the well order doesn't conform to either given orientation (A1->A12 or A1->H1), or if wells are missing, choose 'Custom' well orientation."),
                     # # starting well
                     # selectInput("starting_well", label = NULL, # NULL < "" in terms of space
                     #             # list("A1" = "A01", "A2" = "A02", "A3" = "A03", "A4" = "A04", "A5" = "A05", "A6" = "A06",
                     #             #      "A7" = "A07", "A8" = "A08", "A9" = "A09", "A10" = "A10", "A11" = "A11", "A12" = "A12",
                     #             #      "B1" = "B01", "B2" = "B02", "B3" = "B03", "B4" = "B04", "B5" = "B05", "B6" = "B06",
                     #             #      "B7" = "B07", "B8" = "B08", "B9" = "B09", "B10" = "B10", "B11" = "B11", "B12" = "B12",
                     #             #      "C1" = "C01", "C2" = "C02", "C3" = "C03", "C4" = "C04", "C5" = "C05", "C6" = "C06",
                     #             #      "C7" = "C07", "C8" = "C08", "C9" = "C09", "C10" = "C10", "C11" = "C11", "C12" = "C12",
                     #             #      "D1" = "D01", "D2" = "D02", "D3" = "D03", "D4" = "D04", "D5" = "D05", "D6" = "D06",
                     #             #      "D7" = "D07", "D8" = "D08", "D9" = "D09", "D10" = "D10", "D11" = "D11", "D12" = "D12",
                     #             #      "E1" = "E01", "E2" = "E02", "E3" = "E03", "E4" = "E04", "E5" = "E05", "E6" = "E06",
                     #             #      "E7" = "E07", "E8" = "E08", "E9" = "E09", "E10" = "E10", "E11" = "E11", "E12" = "E12",
                     #             #      "F1" = "F01", "F2" = "F02", "F3" = "F03", "F4" = "F04", "F5" = "F05", "F6" = "F06",
                     #             #      "F7" = "F07", "F8" = "F08", "F9" = "F09", "F10" = "F10", "F11" = "F11", "F12" = "F12",
                     #             #      "G1" = "G01", "G2" = "G02", "G3" = "G03", "G4" = "G04", "G5" = "G05", "G6" = "G06",
                     #             #      "G7" = "G07", "G8" = "G08", "G9" = "G09", "G10" = "G10", "G11" = "G11", "G12" = "G12",
                     #             #      "H1" = "H01", "H2" = "H02", "H3" = "H03", "H4" = "H04", "H5" = "H05", "H6" = "H06",
                     #             #      "H7" = "H07", "H8" = "H08", "H9" = "H09", "H10" = "H10", "H11" = "H11", "H12" = "H12"),
                     #             list("A1" = "A1", "A2" = "A2", "A3" = "A3", "A4" = "A4", "A5" = "A5", "A6" = "A6",
                     #                  "A7" = "A7", "A8" = "A8", "A9" = "A9", "A10" = "A10", "A11" = "A11", "A12" = "A12",
                     #                  "B1" = "B1", "B2" = "B2", "B3" = "B3", "B4" = "B4", "B5" = "B5", "B6" = "B6",
                     #                  "B7" = "B7", "B8" = "B8", "B9" = "B9", "B10" = "B10", "B11" = "B11", "B12" = "B12",
                     #                  "C1" = "C1", "C2" = "C2", "C3" = "C3", "C4" = "C4", "C5" = "C5", "C6" = "C6",
                     #                  "C7" = "C7", "C8" = "C8", "C9" = "C9", "C10" = "C10", "C11" = "C11", "C12" = "C12",
                     #                  "D1" = "D1", "D2" = "D2", "D3" = "D3", "D4" = "D4", "D5" = "D5", "D6" = "D6",
                     #                  "D7" = "D7", "D8" = "D8", "D9" = "D9", "D10" = "D10", "D11" = "D11", "D12" = "D12",
                     #                  "E1" = "E1", "E2" = "E2", "E3" = "E3", "E4" = "E4", "E5" = "E5", "E6" = "E6",
                     #                  "E7" = "E7", "E8" = "E8", "E9" = "E9", "E10" = "E10", "E11" = "E11", "E12" = "E12",
                     #                  "F1" = "F1", "F2" = "F2", "F3" = "F3", "F4" = "F4", "F5" = "F5", "F6" = "F6",
                     #                  "F7" = "F7", "F8" = "F8", "F9" = "F9", "F10" = "F10", "F11" = "F11", "F12" = "F12",
                     #                  "G1" = "G1", "G2" = "G2", "G3" = "G3", "G4" = "G4", "G5" = "G5", "G6" = "G6",
                     #                  "G7" = "G7", "G8" = "G8", "G9" = "G9", "G10" = "G10", "G11" = "G11", "G12" = "G12",
                     #                  "H1" = "H1", "H2" = "H2", "H3" = "H3", "H4" = "H4", "H5" = "H5", "H6" = "H6",
                     #                  "H7" = "H7", "H8" = "H8", "H9" = "H9", "H10" = "H10", "H11" = "H11", "H12" = "H12"),
                     #             # display name = code name
                     #             selected = "A1"),
                     # # orientation A1->A12, B1->B12 etc. # A1->H1, A2->H2 etc.
                     # selectInput("readingorientation", label = NULL,
                     #             list("A1->A12" = "A1->A12",
                     #                  "A1->H1" = "A1->H1",
                     #                  "Custom" = "custom"), # display name = code name
                     #             selected = "A1->A12"),
                     # conditionalPanel(
                     #   condition = "input.readingorientation == 'custom'",
                     #   p(icon("hand-pointer"), "Select cells containing well numbering information.
                     #   As above, select the first and last cell of row/column of well numbers (as appropriate)."),
                     # ),

                     # v2 expanding custom well abilities - orientation first, then starting well ### well
                     p("Select well orientation and starting well."), ### well
                     p(icon("circle-info"), "Presets correspond to standard 96-well plates and assume no wells are missing.
                     Where a different multiwell plate is used, or if wells are missing, choose 'Custom'."),

                     # orientation A1->A12, B1->B12 etc. # A1->H1, A2->H2 etc.
                     selectInput("readingorientation",
                                 # label = NULL, ### well
                                 label = "Well orientation", ### well
                                 list("96-well: A1->A12" = "A1->A12", ### well
                                      "96-well: A1->H1" = "A1->H1", ### well
                                      "Custom" = "custom"
                                 ), # display name = code name
                                 selected = "A1->A12"),
                     conditionalPanel(
                       condition = "input.readingorientation == 'custom'",
                       p(icon("hand-pointer"), "Select cells containing well numbering information.
                       As above, select the first and last cell of row/column of well numbers (as appropriate)."),
                     ),
                     # starting well
                     conditionalPanel(  ### well
                       condition = "input.readingorientation != 'custom'", ### well
                       selectInput("starting_well",
                                   # label = NULL, ### well
                                   label = "Starting well", ### well
                                   # list("A1" = "A01", "A2" = "A02", "A3" = "A03", "A4" = "A04", "A5" = "A05", "A6" = "A06",
                                   #      "A7" = "A07", "A8" = "A08", "A9" = "A09", "A10" = "A10", "A11" = "A11", "A12" = "A12",
                                   #      "B1" = "B01", "B2" = "B02", "B3" = "B03", "B4" = "B04", "B5" = "B05", "B6" = "B06",
                                   #      "B7" = "B07", "B8" = "B08", "B9" = "B09", "B10" = "B10", "B11" = "B11", "B12" = "B12",
                                   #      "C1" = "C01", "C2" = "C02", "C3" = "C03", "C4" = "C04", "C5" = "C05", "C6" = "C06",
                                   #      "C7" = "C07", "C8" = "C08", "C9" = "C09", "C10" = "C10", "C11" = "C11", "C12" = "C12",
                                   #      "D1" = "D01", "D2" = "D02", "D3" = "D03", "D4" = "D04", "D5" = "D05", "D6" = "D06",
                                   #      "D7" = "D07", "D8" = "D08", "D9" = "D09", "D10" = "D10", "D11" = "D11", "D12" = "D12",
                                   #      "E1" = "E01", "E2" = "E02", "E3" = "E03", "E4" = "E04", "E5" = "E05", "E6" = "E06",
                                   #      "E7" = "E07", "E8" = "E08", "E9" = "E09", "E10" = "E10", "E11" = "E11", "E12" = "E12",
                                   #      "F1" = "F01", "F2" = "F02", "F3" = "F03", "F4" = "F04", "F5" = "F05", "F6" = "F06",
                                   #      "F7" = "F07", "F8" = "F08", "F9" = "F09", "F10" = "F10", "F11" = "F11", "F12" = "F12",
                                   #      "G1" = "G01", "G2" = "G02", "G3" = "G03", "G4" = "G04", "G5" = "G05", "G6" = "G06",
                                   #      "G7" = "G07", "G8" = "G08", "G9" = "G09", "G10" = "G10", "G11" = "G11", "G12" = "G12",
                                   #      "H1" = "H01", "H2" = "H02", "H3" = "H03", "H4" = "H04", "H5" = "H05", "H6" = "H06",
                                   #      "H7" = "H07", "H8" = "H08", "H9" = "H09", "H10" = "H10", "H11" = "H11", "H12" = "H12"),
                                   list("A1" = "A1", "A2" = "A2", "A3" = "A3", "A4" = "A4", "A5" = "A5", "A6" = "A6",
                                        "A7" = "A7", "A8" = "A8", "A9" = "A9", "A10" = "A10", "A11" = "A11", "A12" = "A12",
                                        "B1" = "B1", "B2" = "B2", "B3" = "B3", "B4" = "B4", "B5" = "B5", "B6" = "B6",
                                        "B7" = "B7", "B8" = "B8", "B9" = "B9", "B10" = "B10", "B11" = "B11", "B12" = "B12",
                                        "C1" = "C1", "C2" = "C2", "C3" = "C3", "C4" = "C4", "C5" = "C5", "C6" = "C6",
                                        "C7" = "C7", "C8" = "C8", "C9" = "C9", "C10" = "C10", "C11" = "C11", "C12" = "C12",
                                        "D1" = "D1", "D2" = "D2", "D3" = "D3", "D4" = "D4", "D5" = "D5", "D6" = "D6",
                                        "D7" = "D7", "D8" = "D8", "D9" = "D9", "D10" = "D10", "D11" = "D11", "D12" = "D12",
                                        "E1" = "E1", "E2" = "E2", "E3" = "E3", "E4" = "E4", "E5" = "E5", "E6" = "E6",
                                        "E7" = "E7", "E8" = "E8", "E9" = "E9", "E10" = "E10", "E11" = "E11", "E12" = "E12",
                                        "F1" = "F1", "F2" = "F2", "F3" = "F3", "F4" = "F4", "F5" = "F5", "F6" = "F6",
                                        "F7" = "F7", "F8" = "F8", "F9" = "F9", "F10" = "F10", "F11" = "F11", "F12" = "F12",
                                        "G1" = "G1", "G2" = "G2", "G3" = "G3", "G4" = "G4", "G5" = "G5", "G6" = "G6",
                                        "G7" = "G7", "G8" = "G8", "G9" = "G9", "G10" = "G10", "G11" = "G11", "G12" = "G12",
                                        "H1" = "H1", "H2" = "H2", "H3" = "H3", "H4" = "H4", "H5" = "H5", "H6" = "H6",
                                        "H7" = "H7", "H8" = "H8", "H9" = "H9", "H10" = "H10", "H11" = "H11", "H12" = "H12"),
                                   # display name = code name
                                   selected = "A1"),
                     ), ### well

                     actionButton("submit_readingorientation_button", "Set", class = "btn-primary"),
                     actionButton("view_dataspecs_button5", "View", class = "btn-info"),
                     actionButton("step5_checkbox_button",
                                  label = NULL, icon("lock-open"),
                                  class = "btn-default"),

                     # VIEW CROPPED DATA
                     actionButton("view_croppeddata_button5", "View Cropped Data", class = "btn-success"),
                     # success = green, secondary = white, warning = yellow etc https://getbootstrap.com/docs/4.0/components/buttons/
                     br(), br(),

                     # Step 6 -----
                     strong("6) Join metadata"), br(),
                     # p("Make sure a metadata file in the correct format has been uploaded above."), ### meta
                     # p("Make sure a metadata file in the correct format has been uploaded above (unless you selected to skip the metadata).
                     #   Make sure the 'well' column of the file contains entries for each well in the Cropped Data (in exactly the same notation)."), ### meta
                     p("Make sure a metadata file in the stated (tidy/matrix) format has been uploaded above (unless you selected to skip the metadata)."), ### matrix format
                     p(strong("Tidy format metadata"), "should be displayed in the Metadata tab with the column names in bold.
                       Make sure the 'well' column of the file contains entries for each well in the Cropped Data (in exactly the same notation)."), ### matrix format
                     p(strong("Matrix format metadata"), "should be displayed in the Metadata tab with non-specific column names (e.g. V1, V2 or '...1', '...2').
                       Each variable should be displayed as an 8-row by 12-column grid (for 96-well plates), or similarly for other plate sizes,
                       with the variable name in the top left corner of the grid,
                       and with consecutive variables entered below one another separated by a single blank row."), ### matrix format
                     actionButton("view_metadata_button", "View Metadata", class = "btn-success"), # btn-info
                     actionButton("step6_checkbox_button",
                                  label = NULL, icon("lock-open"),
                                  class = "btn-default"),
                     br(), br(),

                     ## Step 7 - Parse -----
                     strong("7) Parse data"), br(),
                     actionButton("submit_parsedata_button", "Parse Data", class = "btn-primary"),

                     # RESET
                     actionButton("reset_dataspecs_button", "Reset all"), br(), br(),

                     # DOWNLOAD
                     conditionalPanel(
                       condition = "input.submit_parsedata_button > 0",
                       downloadButton("download_table_CSV", "Download parsed data (CSV)", class = "btn-primary")
                     )

                   ) # steps 2-6 conditional on step1 checkbox

                   # # TESTS FOR TROUBLESHOOTING:
                   # br(), br(), hr(),
                   #
                   # h6("All clicks:"), # not essential
                   # verbatimTextOutput('AllClicks'),
                   # h6("Current click:"), # not essential
                   # verbatimTextOutput('CurrentClick'),
                   # br()

                 ) # conditionalpanel for Start Building Parser button

               ), # sidebar

               # Main (data) panel -------------------------------------------------------------------------------------
               mainPanel(
                 width = 8, # width should be rest!

                 tabsetPanel(id = "byop_mainpaneldata_tabset", # needed for updating view on tabset
                             tabPanel("Raw Data",
                                      value = "rawdata_tab", # needed for updating view on tabset

                                      br(),

                                      ## Raw data
                                      DT::dataTableOutput('RawDataTable')

                             ),
                             tabPanel("Data Specs", # Data Specs Tab ----
                                      value = "dataspecs_tab", # needed for updating view on tabset

                                      # Step1
                                      conditionalPanel(
                                        condition = "input.submit_dataformat_button > 0",
                                        br(),
                                        strong("Step 1: Data format"), br(),
                                        "Data Type:", br(),
                                        verbatimTextOutput("datatype_printed"),
                                        "Data Format:", br(),
                                        verbatimTextOutput("dataformat_printed")
                                      ),

                                      # Step2
                                      conditionalPanel(
                                        condition = "input.submit_channelnames_button > 0",

                                        strong("Step 2: Reading names"), br(),
                                      ),
                                      conditionalPanel(
                                        condition = "input.submit_channelnames_button > 0 && (input.datatype == 'datatype_standard' || input.datatype == 'datatype_timecourse')",

                                        "Number of readings:", br(),
                                        verbatimTextOutput("channel_number"),
                                        "Reading names:", br(),
                                        verbatimTextOutput("channel_names_printed")
                                      ),
                                      conditionalPanel(
                                        condition = "input.submit_channelnames_button > 0 && input.datatype == 'datatype_spectrum'",

                                        "Min wavelength (nm):", br(),
                                        verbatimTextOutput("wav_min_printed"),
                                        "Max wavelength (nm):", br(),
                                        verbatimTextOutput("wav_max_printed"),
                                        "Interval (nm):", br(),
                                        verbatimTextOutput("wav_interval_printed"),
                                      ),

                                      # Step 2B
                                      conditionalPanel(
                                        condition = "input.submit_timepointvars_button > 0", # submit_timepointvars_button only revealed when timecourse

                                        # # v1
                                        # strong("Step 2B: Timecourse settings"), br(),
                                        # "First timepoint (min):", br(),
                                        # verbatimTextOutput("timecourse_firsttimepoint"),
                                        # "Timecourse duration (min):", br(),
                                        # verbatimTextOutput("timecourse_duration"),
                                        # "Interval (min):", br(),
                                        # verbatimTextOutput("timecourse_interval"),
                                        # "Number of timepoints expected:", br(),
                                        # verbatimTextOutput("timepoint_number_expected"),
                                        # "Number of timepoints:", br(), # worked out version
                                        # verbatimTextOutput("timepoint_number"),
                                        # "List of timepoints:", br(),
                                        # verbatimTextOutput("list_of_timepoints")

                                        # v2 ### timepoints from data
                                        strong("Step 2B: Timecourse settings"), br(),
                                        # for manual entry timepoints:
                                        conditionalPanel(
                                          condition = "input.timecourse_input == 'timecourse_input_manual'",
                                          # "First timepoint (min):", br(),
                                          "First timepoint:", br(), ### minutes
                                          verbatimTextOutput("timecourse_firsttimepoint"),
                                          # "Timecourse duration (min):", br(),
                                          "Timecourse duration:", br(), ### minutes
                                          verbatimTextOutput("timecourse_duration"),
                                          # "Interval (min):", br(),
                                          "Interval:", br(), ### minutes
                                          verbatimTextOutput("timecourse_interval"),
                                          "Number of timepoints expected:", br(),
                                          verbatimTextOutput("timepoint_number_expected")
                                        ),
                                        # for manual entry timepoints and timepoints selected from raw data:
                                        "Number of timepoints:", br(), # worked out version
                                        verbatimTextOutput("timepoint_number"),
                                        "List of timepoints:", br(),
                                        verbatimTextOutput("list_of_timepoints")

                                      ),

                                      # Step3
                                      conditionalPanel(
                                        condition = "input.submit_firstchanneldata_button > 0",

                                        strong("Step 3: Data from first reading"), br(),
                                        "Data from first reading:", br(),
                                        DT::dataTableOutput('FirstChannelDataTable'), br() # first channel data

                                      ),

                                      # Step4
                                      conditionalPanel(
                                        condition = "input.submit_channeldataspacing_button > 0",

                                        strong("Step 4: Total data"), br(),
                                        "Spacing between readings:", br(),
                                        verbatimTextOutput("channeldataspacing_printed")

                                      ),

                                      # Step5
                                      conditionalPanel(
                                        condition = "input.submit_readingorientation_button > 0",

                                        strong("Step 5: Well numbering"), br(),
                                        "Starting well:", br(),
                                        verbatimTextOutput("starting_well_printed"),
                                        "Reading orientation:", br(),
                                        verbatimTextOutput("readingorientation_printed"),
                                        "Used wells:", br(),
                                        verbatimTextOutput("used_wells_printed")
                                      ),

                                      br(), br()
                             ),
                             tabPanel("Cropped Data",
                                      value = "rawdata_cropped_tab", # needed for updating view on tabset

                                      br(),

                                      # data
                                      DT::dataTableOutput('TotalDataTable'), br(),

                                      br(), br()
                             ),
                             tabPanel("Metadata",
                                      value = "metadata_tab", # needed for updating view on tabset

                                      br(),

                                      conditionalPanel(
                                        condition = "input.submit_examplemetadata_button == '0' && input.submit_metadatafile_button == '0'",
                                        "Upload Metadata."
                                      ),

                                      ## Metadata
                                      DT::dataTableOutput('MetaDataTable'),

                                      br(), br()
                             ),
                             tabPanel("Parsed Data",
                                      value = "parseddata_tab", # needed for updating view on tabset

                                      br(),

                                      ## Parsed Data
                                      DT::dataTableOutput('ParsedDataTable'),

                                      br(), br()
                             )
                 ) # tabsetPanel in the mainPanel

               ) # mainPanel

             ) # sidebarLayout

           ), # conditionalPanel (on uploading data)

  ), # Top Tab 1

  tabPanel("Guide", icon = icon("map"), # question
           value = "guide", # reqd for tab switching

           # style for left sidebar
           tags$head(
             tags$style("
             #guidesidebar {position: fixed; width: 200px; background-color: transparent; border: none; padding-top: 0px; padding-bottom: 0px;}
             @media (max-width: 575px) {#guidesidebar {position: relative;}}
             ")
           ),
           # @media almost perfect
           # original width cutoff 767px. # 575px corresponds to when navbar goes from one line to several lines. (keeps sidebar fixed until whole UI changes due to inbuilt Shiny defaults)
           sidebarLayout(
             sidebarPanel(
               id = "guidesidebar", # id required for tags above

               # css for Contents sidebar # moved this up to tags$head()
               # style = "
               # position: fixed;
               # background-color: transparent; border: none;
               # padding-top: 0px; padding-bottom: 0px;",
               # position: fixed; # means sidebar always visible even if you scroll down.
               # nb. the shiny arg position = "fixed" does not achieve this!
               # padding top/bottom 0: there to make top of sidebar and mainpanel line up

               width = 3, # 3/12
               uiOutput("guidecontents_text")
             ),
             mainPanel(
               id = "guidemain", # id not used (yet) but would be if i moved style to tags above
               style = "max-width: 700px;",
               width = 9, # 9/12
               uiOutput("guide_text")
             )
           )

  ), # Guide

  tabPanel("Demos", icon = icon("play"), # question
           value = "demos", # reqd for tab switching

           # style for left sidebar
           tags$head(
             tags$style("
             #demossidebar {position: fixed; width: 200px; background-color: transparent; border: none; padding-top: 0px; padding-bottom: 0px;}
             @media (max-width: 575px) {#guidesidebar {position: relative;}}
             ")
           ),
           # @media almost perfect
           # original width cutoff 767px. # 575px corresponds to when navbar goes from one line to several lines. (keeps sidebar fixed until whole UI changes due to inbuilt Shiny defaults)
           sidebarLayout(
             sidebarPanel(
               id = "demossidebar", # id required for tags above
               width = 3, # 3/12
               uiOutput("examplesdemos_contents_text")
             ),
             mainPanel(
               id = "demosmain", # id not used (yet) but would be if i moved style to tags above
               style = "max-width: 700px;",
               width = 9, # 9/12
               uiOutput("examplesdemos_text")
             )
           )

  ), # Demos

  tabPanel("Help", icon = icon("circle-question"), # question
           value = "help", # reqd for tab switching

           # style for left sidebar
           tags$head(
             tags$style("
             #helpsidebar {position: fixed; background-color: transparent; border: none; padding-top: 0px; padding-bottom: 0px;}
             @media (max-width: 575px) {#helpsidebar {position: relative;}}
             ")
           ),
           # @media almost perfect
           # original width cutoff 767px. # 575px corresponds to when navbar goes from one line to several lines. (keeps sidebar fixed until whole UI changes due to inbuilt Shiny defaults)
           sidebarLayout(
             sidebarPanel(
               id = "helpsidebar", # id required for tags above
               width = 3, # 3/12
               uiOutput("helpcontents_text")
             ),
             mainPanel(
               id = "helpmain", # id not used (yet) but would be if i moved style to tags above
               style = "max-width: 700px;",
               width = 9, # 9/12
               uiOutput("help_text")
             )
           )

  ), # Help

  tabPanel("News", icon = icon("newspaper"),
           value = "news", # reqd for tab switching

           # style for left sidebar
           tags$head(
             tags$style("
             #newssidebar {position: fixed; background-color: transparent; border: none; padding-top: 0px; padding-bottom: 0px;}
             @media (max-width: 575px) {#helpsidebar {position: relative;}}
             ")
           ),
           # @media almost perfect
           # original width cutoff 767px. # 575px corresponds to when navbar goes from one line to several lines. (keeps sidebar fixed until whole UI changes due to inbuilt Shiny defaults)
           sidebarLayout(
             sidebarPanel(
               id = "newssidebar", # id required for tags above
               width = 3, # 3/12
               uiOutput("newscontents_text")
             ),
             mainPanel(
               id = "newsmain", # id not used (yet) but would be if i moved style to tags above
               style = "max-width: 700px;",
               width = 9, # 9/12
               uiOutput("news_text")
             )
           )

  ), # News

  tabPanel("About", icon = icon("circle-info"), # info
           value = "about", # reqd for tab switching

           # images must be in www subdirectory # https://stat545.com/shiny-tutorial.html#add-images

           # style for left sidebar
           tags$head(
             tags$style("
             #aboutsidebar {position: fixed; width: 200px; background-color: transparent; border: none; padding-top: 0px; padding-bottom: 0px;}
             @media (max-width: 575px) {#aboutsidebar {position: relative;}}
             ")
           ),
           # @media almost perfect
           # original width cutoff 767px. # 575px corresponds to when navbar goes from one line to several lines. (keeps sidebar fixed until whole UI changes due to inbuilt Shiny defaults)
           sidebarLayout(
             sidebarPanel(
               id = "aboutsidebar", # id required for tags above
               width = 3, # 3/12
               uiOutput("aboutcontents_text")
             ),
             mainPanel(
               id = "aboutmain", # id not used (yet) but would be if i moved style to tags above
               style = "max-width: 700px;",
               width = 9, # 9/12
               uiOutput("about_text")
             )
           )

  ) # About
) # navbarpage

} # ui function

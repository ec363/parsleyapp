#### <a name="helpintro"> Help Page </a>

<br>

This <i class="fa-solid fa-circle-question"></i> **Help** page includes **Troubleshooting** tips to solve common problems as well as more details about the **Error messages** you might come across while using Parsley. If this page doesn't solve your problem, consult the <i class="fa-solid fa-map"></i> **Guide** tab, which contains a step by step walk through of how to use Parsley.

<!-- If your question is not answered on either page, our contact details are available on the <i class="fa-solid fa-circle-info"></i> **About** tab. -->

<br>

##### <a name="definitions"> Definitions </a>
<hr>

<!-- **Measurement channel**

Throughout Parsley, we use the term 'measurement channel' to refer to a _type_ of measurement that is taken _for an entire plate_. The closest synonym to 'measurement channel' in every day usage might be a 'reading' or a 'measurement'. Note, however that we are not referring to a reading of _one well_, but a reading of _every well of an entire plate_ (which is why the word 'reading' is not a perfect synonym).

For instance, you might run a timecourse assay in which you read a 'green' fluorescence intensity reading (to detect GFP), a 'red' fluorescence reading (to detect RFP) and an absorbance reading at 600nm at regular intervals. We might refer to these then as the first, second and third measurement channel, respectively. The names you give the measurement channels might then relate to the target molecule, eg. 'GFP, RFP, OD600', or they might refer to the filter sets used, eg. 'green, red, OD600' or 'GG2, RR1, OD600'. Most of the time, you will only take one reading in any one channel. Calibrations with the FPCountR framework are an exception to this, as they require readings in the same channel across a range of gains. In this case, you will need the measurement channel names to differ: you can't call them 'GG2, GG2, GG2..', but you might consider 'GG2_gain40, GG2_gain50, GG2_gain60..'.

For a given measurement channel, there should only be 1 value for any given well at any given timepoint.

- For a given well, Standard Mode data only has 1 value for any given measurement channel. (For Standard Mode data with 12 wells and 1 measurement channel (OD600), the app will expect 12 data points.)
- For a given well, Timecourse data only has 1 value for any given measurement channel and time point. (For Timecourse Mode data with 12 wells, 1 measurement channel (OD600), and 10 time points, the app will expect 120 data points.)
- It is assumed that all Spectrum data only consists of one spectrum, and that no plate reader would permit export of spectrum data next to non-spectrum data in the same file. But wavelengths in Spectrum data are treated as separate measurement channels (because Spectrum data is effectively a series of absorbance readings at a range of wavelengths). So for a given well, Spectrum data only has 1 value for any given wavelength (aka measurement channel). (For Spectrum Mode data with 12 wells and 800 wavelengths (= measurement channels), the app will expect 9600 data points.) -->

**Reading**

Throughout Parsley, we use the term 'Reading' to refer to a _type_ of measurement that is taken _for an entire plate_. Note, however that we are not referring to a reading of _one well_, but a reading of _every well of an entire plate_.

For instance, you might run a timecourse assay using a plate reader in which you take a 'green' fluorescence intensity measurement (to detect GFP), a 'red' fluorescence measurement (to detect RFP) and an absorbance measurement at 600nm, of your entire 96-well plate at regular intervals. We might refer to these then as the first, second and third Readings, respectively. The names you give these Readings might then relate to the target molecule, eg. 'GFP, RFP, cells', or they might refer to the filter sets used, eg. 'green, red, OD600' or 'GG2, RR1, OD600'. Most of the time, you will only take one Reading with any one filter set, which means you can call a Reading by the name of that filter set. Calibrations with the FPCountR framework are an exception to this, as they require several Readings in the same filter set across a range of gains. In this case, you will need the names for each distinct Reading to differ so you can distinguish them: you can't call them 'GG2, GG2, GG2..', but you might consider 'GG2_gain40, GG2_gain50, GG2_gain60' etc.

For a given Reading, there should only be 1 value for any given well at any given timepoint.

- For a given well, Standard Mode data only has 1 value for any given Reading. (For Standard Mode data with 12 wells and 1 Reading (OD600), the app will expect 12 data points.)
- For a given well, Timecourse data only has 1 value for any given Reading and time point. (For Timecourse Mode data with 12 wells, 1 Reading (OD600), and 10 time points, the app will expect 120 data points.)
- It is assumed that all Spectrum data only consists of one spectrum, and that no plate reader would permit export of spectrum data next to non-spectrum data in the same file. But wavelengths in Spectrum data are treated as separate Readings (because Spectrum data is effectively a series of absorbance readings at a range of wavelengths). So for a given well, Spectrum data only has 1 value for any given wavelength (aka Reading). (For Spectrum Mode data with 12 wells and 800 wavelengths (= Readings), the app will expect 9600 data points.)

<br>

##### <a name="troubleshooting"> Troubleshooting </a>
<hr>

**Data files are not uploading**

Check if an 'Uploaded file name' box has appeared beneath the Submit button. If it did not, you did not select a file with Browse. If a file name appears, check it is the right file. Wait a few seconds, as large files can take a few seconds to load, and large Excel files can be especially slow. We recommend saving Excel format files as CSV files before upload, particularly if you encounter unexpected issues. 

Allowed file formats are .csv, .tsv, .txt, .xlsx, or .xls. Make sure you have selected an appropriate file and selected the correct file type for the selected file.

If you are using CSV format files, and still see no Raw Data, the most common problem is that your CSV file may not end with a new empty line. Open the file in a text editor, put your cursor to the right end of the last line and hit Return. Save the file and try again.

**How do I create a metadata file?**

Create a new spreadsheet with Excel or similar. Create a column called 'well' (copy/paste this exactly, similar column names will cause an error). Fill this column with 'A1' to 'H12', or as many of these as you need. Add as many other columns as you need to describe the contents of each well. Save the file as a CSV.

**Data has been reordered due to clicking on column names in Raw Data tab**

This cannot be undone, unfortunately. Reload the page and start again.

<br>

##### <a name="errormessages00"> Error messages: Data upload errors </a>
<hr>

**Error: File extension needs to be one of the following: 'csv', 'tsv', 'txt', 'xls', 'xlsx'.**

The selected file does not have an extension corresponding to the appropriate file types. Select another file or save the file in an appropriate format.

**Error: Ensure that the specified file type matches uploaded file's extension.**

The selected file has an extension that doesn't match the file type selected from the 'File type' menu: perhaps you selected a '.xlsx' file but the File type menu is set to 'CSV'?

<br>

##### <a name="errormessages0"> Error messages: Generic errors </a>
<hr>

**Error: Section marked complete.**

The section whose values you are trying to change are marked complete. To undo this and update the section, unclick the lock icon.

**Error: Section X/Previous sections marked incomplete.**

There is an order to the Data Specifications that needs to be followed. Check that Section X has been completed (with 'View' or 'Data Specifications' tab). If it has, click the Lock icon next to the Section X 'Set' button to mark it as complete before moving on to the next section.

**Error: Select values/cells first.**

Use the mouse to select cells in the Raw Data table to complete this section, before clicking 'Set'.

<br>

##### <a name="errormessages1"> Error messages for Step 1: Data format </a>
<hr>

**Error: Spectrum data must be provided in row or column format.**

Parsley cannot handle spectrum data in matrix format.

**Error: Timecourse data must be provided in row or column format.**

Parsley cannot handle timecourse data in matrix format.

<br>

<!-- ##### <a name="errormessages2"> Error messages for Step 2: Measurement channel names </a> -->
##### <a name="errormessages2"> Error messages for Step 2: Reading names </a>
<hr>

<!-- **Error: Select channel names input method.**

Select an option under the 'Channel names specification' dropdown.
 -->
**Error: Select reading names input method.**

Select an option under the 'Reading names specification' dropdown.

<!-- **Error: Number of channel names does not match number of measurement channels specified.** -->

<!-- If you have stated there are X channels, you must either a) select X cells to correspond to the channel names (if you selected 'Select cells with channel names') or b) input X channel names (if you selected 'Enter channel names manually'). -->

**Error: Number of reading names does not match number of readings specified.**

If you have stated there are X readings, you must either a) select X cells to correspond to the readings names (if you selected 'Select cells with reading names') or b) input X reading names (if you selected 'Enter reading names manually').

<!-- **Error: Channel name selection cannot contain empty cells.** -->
**Error: Reading name selection cannot contain empty cells.**

Selected cell contents will become column names. Column names cannot be blank!

<br>

##### <a name="errormessages2b"> Error messages for Step 2b: Timecourse settings </a>
<hr>

**Error: Select two cells.**  
**Error: Select only 1 row/column.**  
**Error: Timepoint selection cannot contain empty cells.**  

Check you have selected the correct cells. The selection needs to be exactly two cells - in the same row for column format data, or in the same column for row format data - and none of the cells between the two selected ones can be empty.

If you are certain the selected cells are correct, check if you don't still have cells selected from Step 2. These need to be unselected. They can be easy to forget about or miss, particularly with large file uploads.

<br>

<!-- ##### <a name="errormessages3"> Error messages for Step 3: Data from first channel </a> -->
##### <a name="errormessages3"> Error messages for Step 3: Data from first reading </a>
<hr>

**Error: Select two cells.**  
**Error: Select only 1 row/column.**  
**Error: Select an 8 by 12 matrix.**  

Check you have selected the correct cells. For matrix data, Parsley looks for an 8 row by 12 column matrix and flags an error when you select cells with different spacing.

If you are certain the selected cells are correct, check if you don't still have cells selected from Step 2. These need to be unselected. They can be easy to forget about or miss, particularly with large file uploads.

<br>

##### <a name="errormessages4"> Error messages for Step 4: Total data </a>
<hr>

<!-- **Error: Add first channel data to Section 3 first.** -->
**Error: Add first reading data to Section 3 first.**

Section 3 has been marked complete (Lock icon) without being completed.

<!-- **Error: Channel number must be an integer of 1 or more.** -->
**Error: Reading number must be an integer of 1 or more.**

Though the numeric input box accepts fractions, the app does not.

**Error: Do not request data from outside range of file.**

<!-- You have requested row or column numbers that do not exist in your data. The details within the error message should help fix the problem. Probably the channel spacing number is too high. -->

You have requested row or column numbers that do not exist in your data. The details within the error message should help fix the problem. Probably the number entered for the spacing between readings is too high.

<br>

##### <a name="errormessages5"> Error messages for Step 5: Well numbering </a>
<hr>

**Error: Matrix format requires Starting Well = 'A1'.**

Matrix format assumes all wells are represented from 'A1' to 'H12'.

**Error: Select two cells.**  
**Error: Select only 1 row/column.**  
**Error: Number of selected wells does not match the number of columns/rows of selected data.**  

<!-- Custom well numbering: This works like the 'Data from first measurement channel' section. Check cell selections from earlier steps have been unclicked. -->
Custom well numbering: This works like the 'Data from first reading' section. Check cell selections from earlier steps have been unclicked.

If the data is in 'rows', Parsley expected the well names to be arranged in a row and the number of columns to match that of the data.

If the data is in 'columns', Parsley expected the well names to be arranged in a column and the number of rows to match that of the data.

**Error: Well name selection cannot contain empty cells.**

Custom well numbering: every sample must have a non-empty 'well' value or data will be lost during parsing.

<br>

##### <a name="errormessages7"> Error messages for Step 7: Parse data </a>
<hr>

**Error: Can't merge Data and tidy Metadata if Metadata does not contain a 'well' column. Verify that the Metadata is in tidy format. If so, add a 'well' column. If it is in matrix format, select 'Matrix format' in the Metadata upload section above, click Submit to reupload the Metadata, before retrying the Parsing.**

Check that the metadata file was uploaded correctly.

If you uploaded Tidy format Metadata, it needs to contain a column labelled 'well'. Check that Parsley has correctly interpreted that 'well' is the column name: column names will appear in bold at the top. If it is displayed further down, edit the CSV file so that the column names are the first line of the spreadsheet.

If you uploaded Metadata format Metadata, this error has come up because you selected 'Tidy format' under the Metadata format menu. Select 'Metadata format' instead, press Submit to re-upload the Metadata correctly, and retry the Parse step.

<br>

##### <a name="warningmessages"> Warning messages for Step 2b: Timecourse settings </a>
<hr>

> Warnings are not errors. They do not prevent you proceeding or require you to change your inputs.

**Warning: Fewer expected timepoints than calculated timepoints.**  
**Warning: More expected timepoints than calculated timepoints.**

This is a notification that Parsley has identified a mismatch between (i) the 'intuitive' calculation that the list of timepoints must start from the 'first timepoint' and carry on every interval until the 'duration' timepoint, and (ii) the list of timepoints calculated from the 'first timepoint' and the 'expected timepoint number'. 

For example, if the inputs had been: {first timepoint: 0, interval: 30, duration: 960, expected timepoint number: 32}, then the 'intuitive' calculation gives the list: {0, 30, ... 960}, whereas the 'expected' calculation gives: {0, 30, ... 930}. In case of a mismatch, Parsley chooses the shorter of the two lists, and presents a warning confirming the final list. You can then verify if this is the correct list. If it is, you can proceed. If it isn't, you can correct the inputs.

More details about these calculations are given in the Guide section. 

<br>

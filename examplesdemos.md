#### <a name="demointro"> Function Demos with Example Data </a>
<br>

A wide variety of example data is provided with the app to serve as an illustration of all the data types and formats Parsley can handle, as well as to let you test the app's functionality. This <i class="fa-solid fa-circle-play"></i> **Demos** section includes details of the provenance of each of the provided **Example data** sets and a few **Demos** that illustrate how to build parsers for each of these.

<br>

##### <a name="standardex"> Standard Data </a>
<hr>

**Example data**

<div style="text-align: center;">
<img src="guide_greenfluorescence_platelayout.png" width = "400">
</div>
<br>

A dilution series of the green fluorescent small molecule fluorescein (11 dilutions) was prepared in duplicate in rows A-B of a 96-well plate, with the highest concentration on the left (A1/B1), lowest on the right (A11/B11) and with buffer blanks in column 12 (A12/B12). The other wells of the 96-well plate were left empty. 

This plate was measured for fluorescence intensity in the green fluorescence channel (ex. 485/20, em: 535/25), which I have called the GG2 channel, in a Tecan Spark plate reader. The first reading was at gain 40, and the second at gain 50. I have called the readings "GG2_gain40" and "GG2_gain50" respectively.

<a name="standarddemo"> **Demo** </a>

[Standard Data Demo](https://youtu.be/tPG3iNgiOtM)

<!-- <div style="text-align: center;">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/tPG3iNgiOtM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>
<br>
works! -->

<div style="text-align: center;">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/tPG3iNgiOtM" frameborder="0" allowfullscreen loading="lazy"></iframe>
</div>
<br>

<!-- <div style="text-align: center;">
<iframe src="https://www.youtube.com/tPG3iNgiOtM" width="700px" height="394px" allowfullscreen loading="lazy"></iframe>
</div>
<br> -->

<!-- <div style="text-align: center;">
<iframe src="https://www.youtube-nocookie.com/tPG3iNgiOtM" width="700px" height="394px" allowfullscreen loading="lazy"></iframe>
</div>
<br> -->
<!--  -->

<!-- rel = 0 removed related videos? - fails -->
<!-- youtube videos = 16:9 ratio. 700h -> 394 wide -->
<!-- lazy loading only loads video if you scroll near it - not obvious whether this actually works -->
<!-- object of type closure https://www.youtube.com/embed/vgYS-F8opgE -->
<!-- vq=large: 480p; high quality, buffers slower
vq=hd720: 720p; best quality, buffers slowest -->

<br>

##### <a name="spectrumex"> Spectrum Data </a>
<hr>

**Example data**

<div style="text-align: center;">
<br>
<img src="guide_absorbancespectrum_platelayout.png" width = "400">
<br>
</div>

A dilution series of the green fluorescent small molecule fluorescein (11 dilutions) was prepared in duplicate in rows A-B of a 96-well plate, with the highest concentration on the left (A1/B1), lowest on the right (A11/B11) and with buffer blanks in column 12 (A12/B12). The other wells of the 96-well plate were left empty.

An absorbance spectrum scan was carried out on this plate in a Tecan Spark plate reader (wavelengths 200-800nm, with an interval of 1nm).

<a name="spectrumdemo"> **Demo** </a>

[Spectrum Data Demo](https://youtu.be/CCme-aDYyVE)

<div style="text-align: center;">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/CCme-aDYyVE" frameborder="0" allowfullscreen loading="lazy"></iframe>
</div>
<br>

<br>

##### <a name="timecourseex"> Timecourse Data </a>
<hr>

**Example data**

<div style="text-align: center;">
<br>
<img src="guide_timecourse_platelayout.png" width = "400">
<br>
</div>

In this experiment, _E. coli_ cells containing one of two fluorescent protein expression vectors (mCherry or mTagBFP2) were subjected to a titration of their transcriptional inducer (arabinose). The test plate also contained control strains containing an empty plasmid vector, and media blanks.

A timecourse experiment was carried out on this plate in a Tecan Spark plate reader, with three readings (OD600, red fluorescence and blue fluorescence) taken every 30 minutes for a total duration of 16 hours.

<a name="timecoursedemo"> **Demo** </a>

[Timecourse Data Demo](https://youtu.be/9AfOpyTv5BM)

<div style="text-align: center;">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/9AfOpyTv5BM" frameborder="0" allowfullscreen loading="lazy"></iframe>
</div>
<br>

<br>

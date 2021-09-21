# VIIRS-Nightlights-Extraction

Code to download and extract the monthly world composites VIIRs nighlights dataset found at the [Earth Observation Group](https://payneinstitute.mines.edu/eog/nighttime-lights/) 

In order to download from the EOG website an account is which can be created [here](https://eogdata.mines.edu/products/register/). 

The scripts should be run in the following order: 

1. `EOG_scrape.py` (no authentication needed), which compiles an up-to-date list of the monthly composites. 
2. `get_token.sh EOG_USERNAME EOG_PASSWORD` (substituting your username and password as the commandline arguments), which generates an OAuth token (valid for 24 hours) to download from the server 
3.  `download_viirs.sh` which will prompt you to download either the full dataset of a sample. 

Finally, I've included an example of how the rasters can be extracted into a datafile which can be used in the research context using `R`. 

The rasters are large, ending up at around ~11gb each, a year's worth of nightlights is roughly 130gb, and the full dataset comes it at around 1.1 Tb as of September of 2021. 

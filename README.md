## Exploring South Australia's Road Accidents Data

New version in progress. - 23/11/2022

## Demo

Live demo is unavailable, but you can run the app from RStudio using the following code:

```R
## Install missing packages
packagesRequired <- c("shiny", "maptools", "dplyr",
                      "leaflet", "rgeos", "RColorBrewer",
                      "data.table")
packagesToInstall <- packagesRequired[!(packagesRequired %in%
                                          installed.packages()[,"Package"])]
if(length(packagesToInstall)) install.packages(packagesToInstall)
## Run app from Github repo
shiny::runGitHub('asheshwor/crashsa')
```

## Screenshots

![app screenshot 1](img/img1.png)
<small>Screenshot of app</small>

![app screenshot 2](img/img2.png)
<small>Screenshot of app</small>

## Data source

The data from Department of Planning, Transport and Infrastructure was obtained from https://data.sa.gov.au/data/dataset/road-crashes-in-sa

Bounding box for suburbs extracted from https://data.sa.gov.au/data/dataset/suburb-boundaries

## To-do

* statistics of data being displayed - use raw data from 2011-2021 *done*
* filter by type of incidents: type of accident, licence class, licence type, vehicle year, unit type, sex, age, unit movement from "Units" file
* filter by number of casualties, casualty type, position in vehicle, injury extent, seatbelt, helmet from "Casualty" file.
* add data for multiple years
* Search feature


## New UI

Filter design based on full data.
Years: Dropdown years from 2012 to 2021
Crash type: Dropdown list
Day or night: Radio button
Position type: Dropdown list

## License:

Code distributed under the terms of the [MIT license] (https://github.com/asheshwor/crashsa/blob/master/LICENSE)

See individual licenses for external data/tools used if any.

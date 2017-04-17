## Exploring South Australia's Road Accidents Data

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
````

## Screenshots

![app screenshot 1](img/img1.png)
<small>Screenshot of app</small>

![app screenshot 2](img/img2.png)
<small>Screenshot of app</small>

## Data source

The data from Department of Planning, Transport and Infrastructure was obtained from https://data.sa.gov.au/data/dataset/road-crashes-in-sa

Bounding box for suburbs extracted from https://data.sa.gov.au/data/dataset/suburb-boundaries

## To-do

* display statistics of data being displayed
* filter by type of incidents

## License:

Code distributed under the terms of the [MIT license] (https://github.com/asheshwor/crashsa/blob/master/LICENSE)

See individual llicenses for external data/tools used if any.

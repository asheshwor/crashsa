## Exploring South Australia's Road Accidents Data

# Demo

You can also run the app locally in RStudio by using the following code.

```R
## Install missing packages
packagesRequired <- c("leaflet", "dplyr",
                      "RColorBrewer",
                      "data.table",
                      "shiny", "maptools", )
packagesToInstall <- packagesRequired[!(packagesRequired %in%
                                          installed.packages()[,"Package"])]
if(length(packagesToInstall)) install.packages(packagesToInstall)
## Run app from Github repo
shiny::runGitHub('asheshwor/crashsa/crash-app.R')
````

# Data source

The data from Department of Planning, Transport and Infrastructure was obtained from https://data.sa.gov.au/data/dataset/road-crashes-in-sa

Bounding box for suburbs extracted from https://data.sa.gov.au/data/dataset/suburb-boundaries

## License:

Code distributed under the terms of the [MIT license] (https://github.com/asheshwor/crashsa/blob/master/LICENSE)

See individual llicenses for external data/tools used if any.

require(shiny)
library(maptools)
require(dplyr)
require(leaflet)
library(data.table)
library(RColorBrewer)
library(rgdal)
library(mapview)
# library(ggplot2)
# library(ggthemes)
# library(rCharts)
# library(highcharter)
## PREPARE CRASH DATA
# THE DATA WAS DOWNLOADED AND UNZIPPED AS INDIVIDUAL CSV VILES
# READ FOLDER
path.files <- "D:/github/csa/data/original/"
all.files <- list.files(path="D:/github/csa/data/original/",
                        full.names = TRUE, pattern = ".csv")
casualty.files <- list.files(path=path.files,
                             full.names = TRUE, pattern = "Casualty.csv")
crash.files <- list.files(path=path.files,
                          full.names = TRUE, pattern = "Crash.csv")
units.files <- list.files(path=path.files,
                          full.names = TRUE, pattern = "Units.csv")
# THREE FIELS FOR EACH YEAR
# Casualty
# Crash
# Units
# VERIFY HEADERS
invisible(lapply(c(casualty.files, crash.files, units.files), function(xfile) {
  print(xfile)
  print(names(read.csv(xfile)))
}))
# CHECK LENGTHS
invisible(lapply(c(casualty.files, crash.files, units.files), function(xfile) {
  # print(xfile)
  # nrow(read.csv(xfile))
  cat(paste(xfile, nrow(read.csv(xfile)), "\n"))
}))
# COLLATE FILES
casualty.data <- data.frame(do.call("rbind",
                                    lapply(casualty.files,
                                           function(xfile) {
                                             read.csv(xfile)
                                           })))
units.data <- data.frame(do.call("rbind",
                                    lapply(units.files,
                                           function(xfile) {
                                             read.csv(xfile)
                                           })))
crash.data <- data.frame(do.call("rbind",
                                    lapply(crash.files,
                                           function(xfile) {
                                             read.csv(xfile)
                                           })))
crash.data <- crash.data %>%
  filter(!is.na(ACCLOC_X)) %>% 
  mutate(UNIQUE_LOC = as.character(UNIQUE_LOC))
head(crash.data)
#MAKE A LEAFLET MAP WITH AU PROJECTION
# epsg8059 <- leafletCRS(
#   crsClass = "L.Proj.CRS",
#   code = "EPSG:8059",
#   # proj4def = "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs",
#   proj4def = "+proj=lcc +lat_0=-32 +lon_0=135 +lat_1=-28 +lat_2=-36 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
#   resolutions = 2^(16:7))
# m <- leaflet(data = head(crash.data, 500), options = leafletOptions(crs = epsg8059)) %>%
#   # addTiles() %>%
#   setView(138.592609, -34.912760,  zoom = 12) %>%j
#   addCircleMarkers(~ACCLOC_X, ~ACCLOC_X)
# m
coordinates(crash.data) = c("ACCLOC_X", "ACCLOC_Y")
proj4string(crash.data) <- CRS("+init=epsg:8059")
# plot(head(crash.data,500)) #QUICK PLOT
# mapview(head(crash.data,500))
wgs.crs <- CRS("+init=epsg:4326") #EPSG:4326
crash.data <- spTransform(crash.data, wgs.crs)
crash.data$lon <- crash.data@coords[,1]
crash.data$lat <- crash.data@coords[,2]
# plot(head(crash.data,500)) #QUICK PLOT
# mapview(head(crash.data,500))

#NOW LEAFLET
m <- leaflet(data = crash.data) %>%
  addTiles() %>%
  setView(138.592609, -34.912760,  zoom = 12) %>%
  addCircleMarkers(~lon, ~lat, clusterOptions = markerClusterOptions())
m
## FIRST, LET'S CHECK THE CRASH DATA
str(crash.data)

## REACD CRASH DATA
crash.dt <- as.data.table(read.csv("data/crashpoints.csv",
                                   colClasses = c("character",
                                                  rep("integer", 25),
                                                  "numeric", "numeric",
                                                  "character",
                                                  "numeric", "numeric")))
crash.dt2 <- as.data.table(crash.data)
## read suburbs bounding box data
suburbs.bb <- as.data.table(read.csv("data/suburbs/suburbsbb.csv",
                                     colClasses = c("integer",
                                                    "character",
                                                    "character",
                                                    rep("numeric", 4))))
## sampling for fast demo
# crash.dt <- crash.dt[sample.int(nrow(crash.dt), 5000, replace = TRUE),
#                       -c(1, 27:29), with = FALSE]
pallet <- colorFactor(c("gray32", "dodgerblue4",  "slateblue4",
                        "purple", "firebrick1"),
                      domain = c(0, 1, 2, 3, 10))
#ALLOCATE CHOICES
# YEARS
choicesyears <- c(2012L:2021L)
names(choicesyears) <- as.character(choicesyears)
# 
ui <- bootstrapPage(
  tags$head(
    includeCSS("styles2.css")
  ),
  tags$style(type = "text/css", "html, body {width:100%;height:100%;}"
             ),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(id = "controls", class = "panel panel-default",
                top = 55, right = "auto",
                left = 20, bottom = "auto",
                width = 450, height = "auto",
                fixed = FALSE, draggable = TRUE,
                h3("Filter data"),
                selectInput("suburb",
                            label = "Zoom to suburb",
                            choices=c(None = '.',
                                      sort(
                                        setNames(suburbs.bb$suburb,
                                                 paste(suburbs.bb$suburb,
                                                       suburbs.bb$postcode))
                                        ))),
                # selectInput("LCO_NIGHT",
                #             label = "Time of incident:",
                #             choices = c("Both days and nights" = 3,
                #                         "Days only" = 0,
                #                         "Nights only" = 1),
                #             selected = 3),
                selectInput("Year",
                            label = "Select year:",
                            choices = choicesyears,
                            selected = 2021),
                # p("Notes:"),
                includeHTML("note.html")
  )
)

server <- function(input, output, session) {
  get.crash <- function(xinput) {
    if(xinput != 3) {
      xdf <- crash.dt[crash.dt$LCO_NIGHT == as.numeric(input$LCO_NIGHT),]
    }
    else {
      xdf <- crash.dt
    }
    return(xdf)
  }
  # subset based on user selection
  filteredData <- reactive({
    get.crash(input$LCO_NIGHT)
  })
  filteredPu <- reactive({
    #this can probably be avoided
    datax <- filteredData()
    pux <- paste("<b>Total crashes:</b>",
                 as.character(datax$TOTAL_CRAS), "<br>",
                 "<b>Total casualties:</b>",
                 as.character(datax$TOTAL_CASU))
    return(pux)
  })
  
  output$map <- renderLeaflet({
    pu <- filteredPu()
    leaflet(data=crash.dt) %>%
      addTiles() %>%
      setView(138.592609, -34.912760,  zoom = 9) %>%
      addCircleMarkers(~lon, ~lat,
                       popup = pu,
                       radius = ~ifelse(TOTAL_CRAS < 2, 6, 11),
                       color = ~pallet(TOTAL_CASU),
                       stroke = FALSE, fillOpacity = 0.8,
                       clusterOptions = markerClusterOptions(spiderfyOnMaxZoom = FALSE,
                                                             disableClusteringAtZoom = 16))
  })

  observe({
    if(input$suburb == ".") {
      leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>%
        clearMarkerClusters() %>%
        addCircleMarkers(~lon, ~lat,
                         popup = filteredPu(),
                         radius = ~ifelse(TOTAL_CRAS < 2, 6, 11),
                         color = ~pallet(TOTAL_CASU),
                         stroke = FALSE, fillOpacity = 0.8,
                         clusterOptions = markerClusterOptions(spiderfyOnMaxZoom = FALSE,
                                                               disableClusteringAtZoom = 16)
        )
    } else {
      this.bb <- suburbs.bb[suburbs.bb$suburb == input$suburb, ]
      leafletProxy("map", data = filteredData()) %>%
        fitBounds(this.bb$lonmin, this.bb$latmin, this.bb$lonmax, this.bb$latmax)
    }

  })
  
}

shinyApp(ui, server)
####################################
##                                ##
##    Making a simple map in R    ##
##    Dave Moyer, Feb. 2016       ##
##                                ##
####################################

rm(list = ls())

##require a number of important packages
library(ggplot2)
library(rgeos)
library(maptools)
library(rgdal)
library(Cairo)
library(leaflet)
library(ggmap)
library(RgoogleMaps)

##set directory to where all data have been collected
setwd("G:/Visualization Resources/Maps/r")

##translate the shape file into an R object
wa <- readOGR("G:/Visualization Resources/Maps/r/unsd10.shp", layer = "unsd10")
wa.f <- fortify(wa, region = "GEOID10")

##read in data to attach to the plot
grad <- read.csv("wa_2015_grad.csv")
names(grad) <- c("nces.name","state","state.id","nces.id","grad")  ##variable names

##merge data and map file
wa.df <- merge(wa.f, grad, by.x = "id", by.y = "nces.id", all.x = TRUE)

##pull in school data
schools <- read.csv("highschools.csv")
hs <- subset(schools, grade12 == "1-Yes")
hs$enroll2014 <- as.numeric(as.character(hs$enroll2014))
hs <- hs[c(1:5,7,9:11,6,8)] #reorder columns

schools <- read.csv("http://geo.wa.gov/datasets/7b7698e8a29a42f097c418130c20c345_0.csv",
                    header = TRUE)
hs <- subset(schools, Type==c("High School","Jr-Sr High School","K-12 School"))


#there's no projection associated, so we have to project the points
#make a spatialpolygonsdataframe with NAD83 projection, 
#then turn it back to df
coordinates(hs) <- ~ï..X+Y #which variables are spatial
proj4string(hs) <- CRS("+init=epsg:4326") 
hs <- spTransform(hs, CRS(proj4string(wa))) 
hs.df <- data.frame(hs)

##make layered plot
m <- ggplot() + 
  geom_polygon(data = wa.df, aes(x = long, y = lat, group = group, fill = grad), 
               color = "black", size = 0.25) +
      labs(title = "Washington 2015 Four-Year Adjusted Cohort Graduation Rate, by District") +
      theme(legend.position = "bottom", legend.box = "horizontal",
            plot.title = element_text(size = rel(2)),
            axis.ticks.y = element_blank(),
            axis.text.y = element_blank(), 
            axis.ticks.x = element_blank(),
            axis.text.x = element_blank(),
            axis.title.y = element_blank(),
            axis.title.x = element_blank(),
      panel.background = element_blank()) +
      scale_fill_gradient(name="Graduation Rate") +
      coord_equal(ratio=1) + 
  geom_point(data=hs.df, aes(x=ï..X, y=Y, size=Enroll2014), alpha = 0.5) +
      guides(size = guide_legend("2014 Total HS Enrollment"))

print(m)
                    
ggsave(plot = m, "map.png",width=12.5, height=8.25, type="cairo-png")

##make chloropleth alone
n <- ggplot() + geom_polygon(data = wa.df, 
                             aes(x = long, y = lat, group = group,
                                 fill = grad), color = "black", size = 0.25) +
        labs(title = "Washington 2015 Four-Year Adjusted Cohort Graduation Rate, by District") +
        theme(legend.position = "bottom", legend.box = "horizontal",
          plot.title = element_text(size = rel(2)),
          axis.ticks.y = element_blank(),
          axis.text.y = element_blank(), 
          axis.ticks.x = element_blank(),
          axis.text.x = element_blank(),
          axis.title.y = element_blank(),
          axis.title.x = element_blank(),
          panel.background = element_blank()) +
        scale_fill_gradient(name="Graduation Rate") +
        coord_equal(ratio=1)

ggsave(plot = n, "map1.png",width=12.5, height=8.25, type="cairo-png")

##save R objects for shiny
saveRDS(wa.df,"wa.rds")
saveRDS(hs.df, "hs.rds")

##plotly
require(plotly)

Sys.setenv("plotly_username"="davidmoyer")
Sys.setenv("plotly_api_key"="2vfdoo56ef")

(gg <- ggplotly(m))

##ggmap
CenterofMap <- geocode("Washington State")
CenterofMap <- geocode("47.401353, -120.180132")
gWa <- get_map(c(lon=CenterofMap$lon, lat=CenterofMap$lat), 
              zoom=7, maptype = "terrain-background", source = "stamen")
ggWa <- ggmap(gWa)
print(ggWa)

ggWa <- ggmap(gWa) + geom_point(data=hs.df, aes(x=long, y=lat, size=enroll2014), alpha = 0.5) +
  guides(size = guide_legend("2014 Total HS Enrollment"))





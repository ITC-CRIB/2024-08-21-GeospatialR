![ITC-CRIB Logo](/uploads/8f24674fa3405411f0ed7e800.png)

# Introduction Geospatial Raster and Vector data with R

06/06/2024, ITC, Enschede

**Welcome to The Workshop Collaborative Document!**

This document is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly.

---

This document is available at https://notes.crib.utwente.nl/2024-08-21-Geospatial-R-Workshop-Day1

Day Two: https://notes.crib.utwente.nl/2024-08-21-Geospatial-R-Workshop-Day2

---

## Code of Conduct

Participants are expected to follow these guidelines:

* Use welcoming and inclusive language.
* Be respectful of different viewpoints and experiences.
* Gracefully accept constructive criticism.
* Focus on what is best for the community.
* Show courtesy and respect towards other community members.

## License

All content is publicly available under the Creative Commons Attribution License: [creativecommons.org/licenses/by/4.0/](https://creativecommons.org/licenses/by/4.0/).

## Getting help

Contact nearby *helper* or put on *red* sticker note on your laptop if you need assistance.

---

## Setup

### Data
You can download all of the data used in this workshop by clicking this download [link](https://ndownloader.figshare.com/articles/2009586/versions/10). The file is 218.2 MB.

Clicking the download link will automatically download all of the files to your default download directory as a single compressed (.zip) file. To expand this file, double click the folder icon in your file navigator application (for Macs, this is the Finder application).

### For Software Installation:

Follow this [link](https://datacarpentry.org/geospatial-workshop/#option-a-local-installation)

### After R and Rstudio are installed
##### Follow below steps for installing packages

1. Open RStudio by double-clicking the RStudio application icon
2. Type the following into the console and hit enter.
```python=
install.packages(c("dplyr", "ggplot2", "raster", "rasterVis", "RColorBrewer", "remotes", "reshape", "scales", "sf", "terra", "tidyr"))
```
3. When the installation is complete, you will see a status message


---

## Instructors

* Ignacio Urria Yáñez, i.a.urriayanez@tudelft.nl
* Jay Gohil, j.h.gohil@utwente.nl

## Helpers

* Anna Machens, a.k.machens@utwente.nl
* Adhitya Bhawiyuga, a.bhawiyuga@utwente.nl
* Jay Pandya, j.k.pandya@student.utwente.nl

## Roll Call
Name / Job, role / Social media (twitter, github, ...) / Background or interests (optional)






## Agenda

**Day One**

| Time          | Topic                                    |
| ------------- | ---------------------------------------- |
| 09:00 - 09:15 | Welcome and icebreaker                   |
| 09:15 - 10:00 | Open and Plot Raster Data                |
| 10:00 - 10:30 | Raster Calculations                      |
| 10:30 - 10:45 | Coffee Break                             |
| 10:45 - 12:00 | Open and Plot Vector Data                |
| 11:30 - 12:00 | Explore Vector Data Attributes           |
| 12:00 - 13:00 | Lunch                                    |
| 13:15 - 14:00 | Plot Multiple Vector and Raster Layers   |
| 14:00 - 14:30 | Handling and Changing Spatial Projection |
| 14:30 - 14:45 | Coffee Break                             |
| 14:45 - 15:45 | Creating and Manipulating Vector Data    |
| 15:30 - 16:15 | Manipulate Raster Data                   | 
| 16:15 - 16:30 | Wrap-Up                                  |
| 16:00         | END of Day 1                             |

**Day Two**
| Time          | Topic                                |
| ------------- | ------------------------------------ |
| 09:00 - 09:15 | Recap of Day 1                       |
| 09:15 - 10:30 | Analysis and Plot Raster Time Series |
| 10:30 - 10:45 | Coffee Break                         |
| 10:45 - 12:00 | Create Publication-quality Graphics  |
| 11:45 - 12:00 | Wrap-Up                              | 
| 12:00 - 13:00 | END                                  |

---
## Challenge

---

## Collaborative Notes

```python=
install.packages("dplyr")
library(terra)
setwd("~/GeospatialR") # Enter your system path to downloaded data folder

#===========For Raster Part===============
#
# Load Library
library(terra)
library(ggplot2)
library(dplyr)

# Describe .tif dataset metadata
describe("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif") # Enter your system path here to .tif file

DSM_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
DSM_HARV

summary("DSM_HARV")
summary(DSM_HARV)
summary(values(DSM_HARV))

DSM_HARV_df <- as.data.frame(DSM_HARV, xy=TRUE)

str(DSM_HARV_df)

ggplot() + geom_raster(data=DSM_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop)) + scale_fill_viridis_c() + coord_quickmap()

plot(DSM_HARV)

crs(DSM_HARV, proj=TRUE)

minmax(DSM_HARV)

nlyr(DSM_HARV)

ggplot() + geom_histogram(data=DSM_HARV_df, aes(HARV_dsmCrop))

DSM_HARV_df <- DSM_HARV_df %>%
                mutate(fct_elevation = cut(HARV_dsmCrop, breaks = 3))
    
ggplot() + geom_bar(data=DSM_HARV_df, aes(fct_elevation))

DSM_hill_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif")

DSM_hill_HARV

DSM_hill_HARV_df <- as.data.frame(DSM_hill_HARV, xy=TRUE)

str(DSM_hill_HARV_df)


ggplot() + geom_raster(data=DSM_hill_HARV_df, aes(x=x,y=y, alpha=HARV_DSMhill)) + scale_alpha(range = c(0.15, 0.65), guide="none") + coord_quickmap()

ggplot() + geom_raster(data=DSM_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop)) + geom_raster(data=DSM_hill_HARV_df, aes(x=x,y=y, alpha=HARV_DSMhill)) + scale_alpha(range = c(0.15, 0.65), guide="none") + scale_fill_viridis_c() + ggtitle("Elevation with Hillshade") + coord_quickmap()

DTM_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif")

DTM_hill_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_DTMhill_WGS84.tif")

DTM_HARV_df <- as.data.frame(DTM_HARV, xy=TRUE)
DTM_hill_HARV_df <- as.data.frame(DTM_hill_HARV, xy=TRUE)

DTM_hill_HARV_df <- as.data.frame(DTM_hill_HARV, xy=TRUE, res=res(DTM_HARV))

crs(DTM_HARV, parse=TRUE)
crs(DTM_hill_HARV, parse=TRUE)

DTM_hill_UTMZ18N_HARV <- project(DTM_hill_HARV, crs(DTM_HARV))

crs(DTM_hill_UTMZ18N_HARV, parse=TRUE)

crs(DTM_hill_HARV, parse=TRUE)

ext(DTM_hill_UTMZ18N_HARV)

ext(DTM_hill_HARV)

res(DTM_HARV)

res(DTM_hill_UTMZ18N_HARV)

CHM_HARV <- DSM_HARV - DTM_HARV

CHM_HARV_df <- as.data.frame(CHM_HARV, xy=TRUE)

ggplot() + geom_raster(data=CHM_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop)) + scale_fill_gradientn(name="Canopy Height", colors = terrain.colors(10)) + coord_quickmap()

CHM_ov_HARV <- lapp(sds(list(DSM_HARV, DTM_HARV)), fun = function(r1, r2) {return(r1 - r2)})

CHM_ov_HARV_df <- as.data.frame(CHM_ov_HARV, xy=TRUE)

ggplot() + geom_raster(data=CHM_ov_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop)) + scale_fill_gradientn(name="Canopy Height", colors = terrain.colors(10)) + coord_quickmap()

writeRaster(CHM_ov_HARV,"CHM_HARV.tiff",filetype='GTiff', overwrite=TRUE, NAflag=-9999)

#===========For Vector Part===============

library(sf)

aoi_boundary_HARV <- st_read("data/NEON-DS-Site-Layout-Files/HARV/AOPClip_UTMz18N.shp")

st_geometry_type(aoi_boundary_HARV)

st_crs(aoi_boundary_HARV)

st_bbox(aoi_boundary_HARV)

ggplot() + geom_sf(data=aoi_boundary_HARV, size=3, color="black", fill="cyan1") + ggtitle("AOI_Boundary_Plot") + coord_sf()

lines_HARV <- st_read("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")

point_HARV <- st_read("data/NEON-DS-Site-Layout-Files/HARV/HARVtower_UTM18N.shp")

point_HARV

ncol(lines_HARV)

names(lines_HARV)

unique(lines_HARV$TYPE)

footpath_HARV <- lines_HARV %>%
                    filter(TYPE=="footpath")
nrow(footpath_HARV)

ggplot() + geom_sf(data=footpath_HARV)+ ggtitle("NEON Harvard Forest", subtitle = "Footpaths") + coord_sf()

ggplot() + geom_sf(data=footpath_HARV, aes(color = factor(OBJECTID)), size = 1.5) + labs(color = 'Footpath ID') + ggtitle('NEON Harvard Forest', subtitle = "Footpaths") + coord_sf()

unique(lines_HARV$TYPE)

road_colors <- c("blue","green","navy","purple")

ggplot()+ geom_sf(data=lines_HARV, aes(color=TYPE)) +  scale_color_manual(values=road_colors) + ggtitle("NEON Harvard Forest", subtitle = "Roads and Trails") + coord_sf()

new_colors <- c("springgreen","blue","magenta","orange")

ggplot() + geom_sf(data=lines_HARV, aes(color=TYPE), linewidth=1.5) + scale_color_manual(values=new_colors) +labs(color='Road Type') + theme(legend.text = element_text(size=20), legend.box.background = element_rect(size=1)) + ggtitle("NEON Harvard Forest", subtitle = "Roads and Trails - Pretty colors") + coord_sf()

#===========For Multi Raster & Vector Layers Part===============

library(terra)
library(sf)
library(dplyr)
library(ggplot2)

#aoi_boundary_HARV

ggplot() + 
geom_sf(data = aoi_boundary_HARV, fill ="grey", color ="grey") + 
geom_sf(data = lines_HARV, aes(color=TYPE), size=1) +
geom_sf(data = point_HARV) +
ggtitle("NEON Harvard Forest Field Site") +
coord_sf()

crs(aoi_boundary_HARV)
st_bbox(aoi_boundary_HARV)

# Add legend 
road_colors <- c("blue","green","navy","purple")

ggplot() + 
    geom_sf(data=aoi_boundary_HARV, fill = "grey", color = "grey") +
    geom_sf(data = lines_HARV, aes(color=TYPE), show.legend = "line", size = 1) +
    geom_sf(data=point_HARV, aes(fill=Sub_Type), color ="black") + 
    scale_color_manual(values = road_colors) + 
    scale_fill_manual(values = "black") + 
    ggtitle("NEON Harvard Forest Field Site") +
    coord_sf()

# Chnage symbol for point    

ggplot()+
    geom_sf(data = aoi_boundary_HARV, fill="grey", color="grey")+
    geom_sf(data=lines_HARV, aes(color=TYPE), show.legend = "line", size = 1) +
    geom_sf(data=point_HARV, aes(fill = Sub_Type), shape = 15) +
    scale_color_manual(values = road_colors, name ="Line Type") +
    scale_fill_manual(values = "black", name = "Tower Location") +
    ggtitle("NEON Harvard Forest")+
    coord_sf()


# Multiple raster bands

RGB_band1_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif", lyrs = 1)

RGB_band1_HARV_df <- as.data.frame(RGB_band1_HARV, xy = TRUE)

ggplot() + 
    geom_raster(data = RGB_band1_HARV_df, aes(x=x,y=y, alpha=HARV_RGB_Ortho_1)) +
    coord_quickmap()

RGB_band2_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif", lyrs = 2)

RGB_band2_HARV_df <- as.data.frame(RGB_band2_HARV, xy = TRUE)

ggplot() +
    geom_raster(data=RGB_band2_HARV_df, aes(x=x, y=y, alpha = HARV_RGB_Ortho_2)) +
    coord_quickmap()


RGB_stack_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif")

RGB_stack_HARV
RGB_stack_HARV[[2]]
plotRGB(RGB_stack_HARV, r = 1, g = 2, b = 3)

plotRGB(RGB_stack_HARV, r = 1, g = 2, b = 3, scale = 800, stretch = "lin")

# Working with data with different CRS

state_boundary_US <- st_read("data/NEON-DS-Site-Layout-Files/US-Boundary-Layers/US-State-Boundaries-Census-2014.shp") %>%
st_zm()

country_boundary_US <- st_read("data/NEON-DS-Site-Layout-Files/US-Boundary-Layers/US-Boundary-Dissolved-States.shp") %>%
st_zm()

ggplot() +
    geom_sf(data=state_boundary_US, color = "gray60") +
    geom_sf(data=country_boundary_US, color = "black", alpha = 0.25, linewidth = 0.9) +
    ggtitle("US State Boundaries") +
    coord_sf()

# Compare CRS

st_crs(point_HARV)$proj4string
st_crs(state_boundary_US)$proj4string

point_HARV_trans <- st_transform(point_HARV, st_crs(state_boundary_US))
st_crs(point_HARV_trans)$proj4string
st_crs(RGB_band1_HARV)$proj4string

ggplot() + 
    geom_sf(data = state_boundary_US, color = "gray60") +
    geom_sf(data = point_HARV, shape = 15, color = "purple") +
    ggtitle("US States and Tower HARV") +
    coord_sf()

# Import csv file to spatial objects and export them as shapefiles

 # 1. Import the data
    
plot_locations_HARV <- 
    read.csv("data/NEON-DS-Site-Layout-Files/HARV/HARV_PlotLocations.csv")
str(plot_locations_HARV)

head(plot_locations_HARV$easting)
head(plot_locations_HARV$northing)

head(plot_locations_HARV$geodeticDa)

utm18nCRS <- st_crs(point_HARV)
utm18nCRS

plot_locations_sp_HARV <- st_as_sf(plot_locations_HARV, 
                                   coords = c("easting","northing"), 
                                   crs = utm18nCRS)

st_crs(plot_locations_sp_HARV)

ggplot() +
    geom_sf(data = plot_locations_sp_HARV) +
    ggtitle("Map of Plot Locations") +
    coord_sf(datum = st_crs(plot_locations_sp_HARV))

st_write(plot_locations_sp_HARV, 
         "data/PlotLocations_HARV.shp", driver = "ESRI Shapefile")

# Crop raster with vector layers

aoi_boundary_HARV <- st_read("data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")

CHM_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")
CHM_HARV_df <- as.data.frame(CHM_HARV, xy = TRUE)

ggplot() +
    geom_raster(data=CHM_HARV_df, aes(x=x,y=y, fill=HARV_chmCrop)) +
    scale_fill_gradientn(name = "Canopy Height", colors = terrain.colors(10)) +
    geom_sf(data=aoi_boundary_HARV, color="blue", fill =NA) +
    coord_sf()

CHM_HARV_Cropped <- crop(x = CHM_HARV, y = aoi_boundary_HARV)
CHM_HARV_Cropped_df <- as.data.frame(CHM_HARV_Cropped, xy = TRUE)

ggplot() +
    geom_sf(data=st_as_sfc(st_bbox(CHM_HARV)), fill = "green", color = "green", alpha =0.2) +
    geom_raster(data = CHM_HARV_Cropped_df, aes(x = x, y = y, fill = HARV_chmCrop)) +
    scale_fill_gradientn(name="Canopy Height", colors=terrain.colors(10)) +
    coord_sf()

new_extent <- ext(732161.2, 732238.7, 4713249, 4713333)
class(new_extent)
CHM_HARV_manual_Cropped <- crop(x = CHM_HARV, y = new_extent)
CHM_HARV_manual_Cropped_df <- as.data.frame(CHM_HARV_manual_Cropped, xy = TRUE)

ggplot() +
    geom_sf(data = aoi_boundary_HARV,  color = "blue", fill = NA) +
    geom_raster(data = CHM_HARV_manual_Cropped_df, aes(x=x,y=y, fill = HARV_chmCrop)) +
    scale_fill_gradientn(name="Canopy Height", colors = terrain.colors(10)) +
    coord_sf()

tree_height <- extract(x = CHM_HARV, y = aoi_boundary_HARV, raw = FALSE)
str(tree_height)

summary(tree_height$HARV_chmCrop)

mean_tree_height_AOI <- extract(x = CHM_HARV, y = aoi_boundary_HARV, fun = mean)
mean_tree_height_AOI

mean_RGB_stack_HARV_AOI <- extract(x = RGB_stack_HARV, y = aoi_boundary_HARV, fun = mean)
mean_RGB_stack_HARV_AOI

mean_tree_height_tower <- extract(x=CHM_HARV, y=st_buffer(point_HARV, dist=20), fun=mean)
mean_tree_height_tower
st_crs(CHM_HARV)$proj4string
st_crs(point_HARV)$proj4string





```



## Additional Links
Post-Workshop Survey : [LINK](https://carpentries.typeform.com/to/UgVdRQ?slug=2024-08-21-GeospatialR)
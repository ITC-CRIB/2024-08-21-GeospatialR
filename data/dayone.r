# loading the library

library(terra)
library(ggplot2)
library(dplyr)

# describe the raster
describe("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")

# load the raster
DSM_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
DSM_HARV

# Statistics with random 100,000 points
summary(DSM_HARV)

# Statistics with all values
summary(values(DSM_HARV))

# converting SpatRaster dataset into DataFrame
DSM_HARV_df <- as.data.frame(DSM_HARV, xy=TRUE)

# describe structure of raster
str(DSM_HARV_df)

# plot the raster with ggplot
ggplot() + geom_raster(data=DSM_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop))+ scale_fill_viridis_c()+coord_quickmap()

# plot the raster with R Base function
plot(DSM_HARV)

# check the CRS
crs(DSM_HARV, proj=TRUE)

# Minimum and Maximum values of the raster
minmax(DSM_HARV)

# number of layers of the raster
nlyr(DSM_HARV)

# plot the raster histogram
ggplot()+geom_histogram(data=DSM_HARV_df, aes(HARV_dsmCrop))

# Dividing the distribution into 3 breaks
DSM_HARV_df <- DSM_HARV_df %>%
                mutate(fct_elevation = cut(HARV_dsmCrop, breaks = 3))

# plot the new histogram
ggplot() + geom_bar(data=DSM_HARV_df, aes(fct_elevation))

# load the hillshade raster
DSM_hill_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif")

# read the hillshade raster
DSM_hill_HARV

# converting the hillshade raster into DataFrame
DSM_hill_HARV_df <- as.data.frame(DSM_hill_HARV, xy=TRUE)

# structure of DataFrame
str(DSM_hill_HARV_df)

# Plot the hillshade and DSM raster together
ggplot() +geom_raster(data=DSM_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop)) +geom_raster(data=DSM_hill_HARV_df, aes(x=x,y=y, alpha=HARV_DSMhill)) + scale_alpha(range = c(0.15, 0.65), guide="none")+scale_fill_viridis_c()+ggtitle("Elevation with Hillshade")+coord_quickmap()

# load the DTM raster
DTM_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_dtmCrop.tif")

# load DTM hillshade
DTM_hill_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/DTM/HARV_DTMhill_WGS84.tif")

# Converting DTM and hillshade raster to DataFrame
DTM_HARV_df <- as.data.frame(DTM_HARV, xy=TRUE)
DTM_hill_HARV_df <- as.data.frame(DTM_hill_HARV, xy=TRUE)

# CRS
crs(DTM_HARV, parse=TRUE)
crs(DTM_hill_HARV, parse=TRUE)

# Reprojection of raster
DTM_hill_UTMZ18N_HARV <- project(DTM_hill_HARV, crs(DTM_HARV), res=res(DTM_HARV))

# CRS of new projected raster
crs(DTM_hill_UTMZ18N_HARV, parse=TRUE)

# crs
crs(DTM_hill_HARV, parse=TRUE)

#extent of the raster
ext(DTM_hill_UTMZ18N_HARV)
ext(DTM_hill_HARV)

# resolution of the rasters
res(DTM_HARV)
res(DTM_hill_UTMZ18N_HARV)

#-------- Raster Math-----------

# method 1 for band math
# Canopy Height Model(CHM)
CHM_HARV <- DSM_HARV - DTM_HARV

# conversion to DataFrame
CHM_HARV_df <- as.data.frame(CHM_HARV, xy=TRUE)

# plot the CHM
ggplot()+geom_raster(data=CHM_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop))+scale_fill_gradientn(name="Canopy Height", colors = terrain.colors(10))+coord_quickmap()

# Method 2 using lapp() function
# The lapp() function takes two or more rasters and applies a function to them using efficient processing methods. The syntax is => outputRaster <- lapp(x, fun=functionName)
# A custom function consists of a defined set of commands performed on a input object. Custom functions are particularly useful for tasks that need to be repeated over and over in the code. A simplified syntax for writing a custom function in R is: function_name <- function(variable1, variable2) { WhatYouWantDone, WhatToReturn}
# To create a SpatRasterDataset, we call the function sds which can take a list of raster objects (each one created by calling rast).

CHM_ov_HARV <- lapp(sds(list(DSM_HARV, DTM_HARV)), fun = function(r1, r2) {return(r1 - r2)})

# conversion to DataFrame
CHM_ov_HARV_df <- as.data.frame(CHM_ov_HARV, xy=TRUE)

# plot the raster
ggplot() + geom_raster(data=CHM_ov_HARV_df, aes(x=x,y=y, fill=HARV_dsmCrop))+scale_fill_gradientn(name="Canopy Height", colors = terrain.colors(10))+coord_quickmap()

# export the raster as GeoTiff
writeRaster(CHM_ov_HARV,"CHM_HARV.tiff",filetype='GTiff', overwrite=TRUE, NAflag=-9999)

# loading the simple features (sf) library
library(sf)

# load the vector dataset, IMPORTANT no need to convert into DataFrame as it already DataFrame

aoi_boundary_HARV <- st_read("data/NEON-DS-Site-Layout-Files/HARV/AOPClip_UTMz18N.shp")

# output geometry type
st_geometry_type(aoi_boundary_HARV)

# output CRS
st_crs(aoi_boundary_HARV)

# output bounding box
st_bbox(aoi_boundary_HARV)

# plot the vector
ggplot()+geom_sf(data=aoi_boundary_HARV, size=3, color="black", fill="cyan1")+ggtitle("AOI_Boundary_Plot")+coord_sf()

# load lines features
lines_HARV<-st_read("data/NEON-DS-Site-Layout-Files/HARV/HARV_roads.shp")

# load point features
point_HARV<-st_read("data/NEON-DS-Site-Layout-Files/HARV/HARVtower_UTM18N.shp")

# output preview point data
point_HARV

# output number of attributes/columns
ncol(lines_HARV)

# output
names(lines_HARV)

# output distinct values from TYPE column
unique(lines_HARV$TYPE)

# filter data with TYPE value which is Footpath only
footpath_HARV <- lines_HARV %>%
                  filter(TYPE=="footpath")
# output the number for features/values
nrow(footpath_HARV)

# plot the filtered vector
ggplot()+geom_sf(data=footpath_HARV)+ggtitle("NEON Harvard Forest", subtitle = "Footpaths")+coord_sf()

# plot distinctly the filtered vector with OBJECTID
ggplot()+geom_sf(data=footpath_HARV, aes(color = factor(OBJECTID)), size=1.5)+labs(color = 'Footpath ID')+ggtitle('NEON Harvard Forest',subtitle = "Footpaths")+coord_sf()

# output distinct values by TYPE attribute
unique(lines_HARV$TYPE)

# declare variable with colors
road_colors<-c("blue","green","navy","purple")

# plot the lines vector with different colors
ggplot()+geom_sf(data=lines_HARV, aes(color=TYPE))+scale_color_manual(values=road_colors)+ggtitle("NEON Harvard Forest",subtitle = "Roads and Trails")+coord_sf()

# declare variable with colors
new_colors<-c("springgreen","blue","magenta","orange")

# plot vector with changed legend
ggplot()+geom_sf(data=lines_HARV, aes(color=TYPE), linewidth=1.5)+scale_color_manual(values = new_colors) + labs(color='Road Type')+theme(legend.text = element_text(size=20), legend.box.background = element_rect(size=1))+ggtitle("NEON Harvard Forest", subtitle = "Roads and Trails - Pretty colors")+coord_sf()


# Load libraries
library(terra)
library(sf)
library(dplyr)
library(ggplot2)

# Plot multiple layers (polygon, lines and points)

ggplot()+
  geom_sf(data = aoi_boundary_HARV, fill = "grey", color = "grey")+
  geom_sf(data = lines_HARV, aes(color=TYPE), size = 1) +
  geom_sf(data = point_HARV) +
  ggtitle("NEON Harvard Forest Field Site") +
  coord_sf()

# Check CRS and extent
crs(aoi_boundary_HARV)
st_bbox(aoi_boundary_HARV)


# Add legend
road_colors <- c("blue", "green", "navy", "purple")
ggplot()+
  geom_sf(data=aoi_boundary_HARV, fill = "grey", color = "grey")+
  geom_sf(data = lines_HARV, aes(color = TYPE),
          show.legend = "line", size = 1) +
  geom_sf(data=point_HARV, aes(fill = Sub_Type), color = "black") +
  scale_color_manual(values = road_colors) +
  scale_fill_manual(values = "black") +
  ggtitle("NEON Harvard Forest Field Site")+
  coord_sf()

# Change symbol for point
ggplot()+
  geom_sf(data = aoi_boundary_HARV, fill="grey", color="grey")+
  geom_sf(data=lines_HARV, aes(color = TYPE),
          show.legend = "line", size = 1)+
  geom_sf(data=point_HARV, aes(fill = Sub_Type), shape = 15) +
  scale_color_manual(values = road_colors, name = "Line Type") +
  scale_fill_manual(values = "black", name = "Tower Location")+
  ggtitle("NEON Harvard Forest") +
  coord_sf()

# Multiple raster bands

# Import 1 layer
RGB_band1_HARV <- rast(
  "data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif",
  lyrs = 1)
RGB_band1_HARV_df <- as.data.frame(RGB_band1_HARV, xy = TRUE)

# Plot layer
ggplot()+
  geom_raster(data = RGB_band1_HARV_df,
              aes(x=x, y=y, alpha=HARV_RGB_Ortho_1)) +
  coord_quickmap()

# Import second layer
RGB_band2_HARV <- rast(
  "data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif",
  lyrs =2
)
RGB_band2_HARV_df <- as.data.frame(RGB_band2_HARV, xy = TRUE)

# Plot layer 2
ggplot()+
  geom_raster(data=RGB_band2_HARV_df,
              aes(x=x, y=y, alpha = HARV_RGB_Ortho_2))+
  coord_quickmap()

# Import stack
RGB_stack_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif")

# Explore stack
RGB_stack_HARV
RGB_stack_HARV[[2]]

# Plot all layers together
plotRGB(RGB_stack_HARV,
        r = 1, g = 2, b = 3)

# Change scale to modify the contrast of the image
plotRGB(RGB_stack_HARV,
        r = 1, g = 2, b = 3,
        scale = 800,
        stretch = "lin")


#---------------------------------------------------#
# Working with data with different CRS

# Import layers
state_boundary_US <- st_read("data/NEON-DS-Site-Layout-Files/US-Boundary-Layers/US-State-Boundaries-Census-2014.shp") %>% 
  st_zm()

country_boundary_US <- st_read("data/NEON-DS-Site-Layout-Files/US-Boundary-Layers/US-Boundary-Dissolved-States.shp") %>% 
  st_zm()

#Plot layers
ggplot()+
  geom_sf(data=state_boundary_US, color ="gray60")+
  geom_sf(data=country_boundary_US, color = "black", alpha = 0.25, linewidth = 0.9) +
  ggtitle("US State Boundaries")+
  coord_sf()


# Compare CRS
st_crs(point_HARV)$proj4string
st_crs(state_boundary_US)$proj4string

# Transform CRS
point_HARV_trans <- st_transform(point_HARV, st_crs(state_boundary_US))
st_crs(point_HARV_trans)$proj4string
st_crs(RGB_band1_HARV)$proj4string

# Plot layers in different CRS (ggplot doesnt require to standardise the CRS)
ggplot()+
  geom_sf(data = state_boundary_US, color = "gray60")+
  geom_sf(data=point_HARV, shape = 15, color = "purple") +
  ggtitle("US States and Tower HARV")+
  coord_sf()

#--------------------
# Import csv file to spatial objects and export them as shapefiles

# 1. Import the data 
plot_locations_HARV <- 
  read.csv("data/NEON-DS-Site-Layout-Files/HARV/HARV_PlotLocations.csv")

#Check data
str(plot_locations_HARV)

# Check coordinates variables
head(plot_locations_HARV$easting)
head(plot_locations_HARV$northing)

# Check Datum
head(plot_locations_HARV$geodeticDa)

# Create object with CRS
utm18nCRS <- st_crs(point_HARV)
utm18nCRS

# Transform dataframe to spatial object
plot_locations_sp_HARV <- st_as_sf(plot_locations_HARV,
                                   coords = c("easting", "northing"),
                                   crs = utm18nCRS)

#Check crs and plot
st_crs(plot_locations_sp_HARV)

ggplot()+
  geom_sf(data = plot_locations_sp_HARV)+
  ggtitle("Map of Plot Locations")+
  coord_sf(datum = st_crs(plot_locations_sp_HARV))

# Export as shp
st_write(plot_locations_sp_HARV,
         "data/PlotLocations_HARV.shp", driver = "ESRI Shapefile")

#----------------------------
# Crop raster with vector layers

# Import vector and raster
aoi_boundary_HARV <- st_read(
  "data/NEON-DS-Site-Layout-Files/HARV/HarClip_UTMZ18.shp")

CHM_HARV <- rast("data/NEON-DS-Airborne-Remote-Sensing/HARV/CHM/HARV_chmCrop.tif")
CHM_HARV_df <- as.data.frame(CHM_HARV, xy= TRUE)

# Plot
ggplot()+
  geom_raster(data=CHM_HARV_df, aes(x = x, y = y, fill=HARV_chmCrop))+
  scale_fill_gradientn(name = "Canopy Height", colors= terrain.colors(10))+
  geom_sf(data=aoi_boundary_HARV, color ="blue", fill = NA)+
  coord_sf()

# Crop based on extent of vector polygon
CHM_HARV_Cropped <- crop(x = CHM_HARV, y = aoi_boundary_HARV)
CHM_HARV_Cropped_df <- as.data.frame(CHM_HARV_Cropped, xy = TRUE)

# Plot to compare extents 
ggplot()+
  geom_sf(data=st_as_sfc(st_bbox(CHM_HARV)), fill = "green", color = "green", alpha = 0.2) +
  geom_raster(data = CHM_HARV_Cropped_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  scale_fill_gradientn(name="Canopy Height", colors= terrain.colors(10))+
  coord_sf()

# Crop based on manual extent
new_extent <- ext(732161.2,732238.7,4713249,4713333)
class(new_extent)
CHM_HARV_manual_Cropped <- crop(x = CHM_HARV, y = new_extent)
CHM_HARV_manual_Cropped_df <- as.data.frame(CHM_HARV_manual_Cropped, xy = TRUE)

# Plot
ggplot()+
  geom_sf(data = aoi_boundary_HARV, color = "blue", fill = NA)+
  geom_raster(data= CHM_HARV_manual_Cropped_df,
              aes(x = x, y = y, fill = HARV_chmCrop)) +
  scale_fill_gradientn(name="Canopy Height", colors = terrain.colors(10)) +
  coord_sf()

# Extract information of raster based on extent of polygon
tree_height <- extract(x = CHM_HARV, y = aoi_boundary_HARV, raw = FALSE)
str(tree_height)

# Summarise info
summary(tree_height$HARV_chmCrop)

# Extract the mean (or any other function)
mean_tree_height_AOI <- extract(x = CHM_HARV, y = aoi_boundary_HARV,
                                fun = mean)
mean_tree_height_AOI

# Test with multiple raster layers
mean_RGB_stack_HARV_AOI <- extract(x = RGB_stack_HARV, y = aoi_boundary_HARV, fun = mean)
mean_RGB_stack_HARV_AOI

# Extract information based on buffer around point
mean_tree_height_tower <- extract(x=CHM_HARV,
                                  y = st_buffer(point_HARV, dist = 20),
                                  fun = mean)
mean_tree_height_tower

# Check CRS
st_crs(CHM_HARV)$proj4string
st_crs(point_HARV)$proj4string


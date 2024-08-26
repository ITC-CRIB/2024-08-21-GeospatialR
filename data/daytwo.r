# Geospatial R workshop

# loading the library
library(terra)
library(scales)
library(tidyr)
library(ggplot2)

#Plot and Analyze Raster Time Series

# declare the path to Raster file
NDVI_HARV_path<-"data/NEON-DS-Landsat-NDVI/HARV/2011/NDVI/"

# list the files
all_NDVI_HARV<-list.files(NDVI_HARV_path, full.names = TRUE, pattern = ".tif$")
all_NDVI_HARV

# create raster dataset
NDVI_HARV_stack<-rast(all_NDVI_HARV)

# output crs
crs(NDVI_HARV_stack, proj=TRUE)

# X axis resolution
xres(NDVI_HARV_stack)

# Y axis resolution
yres(NDVI_HARV_stack)

# Conversion to DataFrame without pivot longer
NDVI_HARV_stack_2_df<-as.data.frame(NDVI_HARV_stack, xy=TRUE)

# Conversion to DataFrame without pivot longer
# First we need to create a data frame object. Because there are multiple columns in our data that are not variables, we will tidy (or “pivot”) the data so that we have a single column with the NDVI observations. 

NDVI_HARV_stack_df<-as.data.frame(NDVI_HARV_stack, xy=TRUE) %>%
  pivot_longer(-(x:y), names_to="variable", values_to = "value")

# output Structure of DataFrame
str(NDVI_HARV_stack_df)

# plot the time series
# the facet_wrap() function to create a multi-paneled plot
ggplot()+geom_raster(data=NDVI_HARV_stack_df, aes(x=x,y=y, fill=value))+facet_wrap(~variable)

# Rescaling the NDVI values
NDVI_HARV_stack <- NDVI_HARV_stack/10000

# conversion to DataFrame
NDVI_HARV_stack_df<-as.data.frame(NDVI_HARV_stack, xy=TRUE) %>%
  pivot_longer(-(x:y),names_to = "variable", values_to="value")

# Plot the time series with rescaled values
ggplot()+geom_raster(data=NDVI_HARV_stack_df, aes(x=x,y=y,fill=value))+facet_wrap(~variable)

# Plot the histogram
ggplot(NDVI_HARV_stack_df)+geom_histogram(aes(value))+facet_wrap(~variable)

# load the Daily Meterological Data
har_met_daily<-read.csv("data/NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m.csv")

# changing Character type to Date
har_met_daily$date<-as.Date(har_met_daily$date, format = "%Y-%m-%d")

# output sructure of the Daily Met Data
str(har_met_daily)

# load dplyr library for between() function
library(dplyr)

# filter data for only year 2011
yr_11_daily_avg <- har_met_daily %>%
  filter(between(date, as.Date('2011-01-01'), as.Date('2011-12-31')))

# plot the Daily Met data
ggplot()+geom_point(data=yr_11_daily_avg, aes(jd, airt))+ggtitle("Daily Mean Air Temperature")+xlab("Julian Days")+ylab("Mean Air Temperature (C)")

# applying mean function over the raster time series, output is DataFrame
avg_NDVI_HARV <- global(NDVI_HARV_stack, mean)

# output preview metadata raster
avg_NDVI_HARV

# declare and assign values to new attributes
avg_NDVI_HARV$year<-"2011"
avg_NDVI_HARV$site <- "HARV"
# load first six values of the DataFrame
head(avg_NDVI_HARV)

# adding Juliandays attribute to DataFrame
julianDays<-gsub("_HARV_ndvi_crop","",row.names(avg_NDVI_HARV))
julianDays
avg_NDVI_HARV$julianDay<-julianDays

# check value type
class(avg_NDVI_HARV$julianDay)

# assigning origin value
origin<- as.Date("2011-01-01")

# adding Date attribute to DataFrame
# we convert from the integer 05 julianDay value (indicating 5th of January), we cannot simply add origin + julianDay because 01 + 05 = 06 or 06 January 2011. To correct, this error we then subtract 1 to get the correct day, January 05 2011.
avg_NDVI_HARV$julianDay<-as.integer(avg_NDVI_HARV$julianDay)
avg_NDVI_HARV$Date<- origin+ (avg_NDVI_HARV$julianDay - 1)
head(avg_NDVI_HARV$Date)

# repeated steps for San Jaoquin Experimental Region
NDVI_path_SJER<-"data/NEON-DS-Landsat-NDVI/SJER/2011/NDVI/"
all_NDVI_SJER<- list.files(NDVI_path_SJER, 
                           full.names=TRUE, pattern = ".tif$")
NDVI_stack_SJER<-rast(all_NDVI_SJER)
NDVI_stack_SJER<-NDVI_stack_SJER/10000
avg_NDVI_SJER<-as.data.frame(global(NDVI_stack_SJER, mean))
names(avg_NDVI_SJER)<-"mean"
avg_NDVI_SJER$year<-"2011"
avg_NDVI_SJER$site<-"SJER"
avg_NDVI_SJER
julianDays_SJER<-gsub("_SJER_ndvi_crop","",row.names(avg_NDVI_SJER))
avg_NDVI_SJER$julianDay<-as.integer(julianDays_SJER)
avg_NDVI_SJER$Date<-origin+(avg_NDVI_SJER$julianDay - 1)
head(avg_NDVI_SJER)
head(avg_NDVI_HARV)

# Compare NDVI from Two Different Sites in One Plot
NDVI_HARV_SJER<-rbind(avg_NDVI_HARV,avg_NDVI_SJER)

# Plot both HARV and SJER dataset
ggplot(NDVI_HARV_SJER, aes(x=julianDay, y=mean, color=site))+
  geom_point(aes(group=site))+
  geom_line(aes(group=site))+
  ggtitle("Landsat Derived NDVI - 2011",subtitle="Harvard Forest vs San Joaquin")+
  xlab("Julian Days")+ylab("Mean NDVI")

# Creating more detailed graphics

# load R color brewer library
library(RColorBrewer)
brewer.pal(9,"YlGn")

# declare variable for color palette
greencolors<- brewer.pal(9,"YlGn") %>%
  colorRampPalette()

# plot with adjusted legend and new color palette
ggplot()+
  geom_raster(data=NDVI_HARV_stack_df, aes(x=x,y=y, fill=value))+
  facet_wrap(~variable)+
  ggtitle("Landsat NDVI",subtitle = "NEON Harvard Forest")+
  theme_void()+
  theme(plot.title = element_text(hjust=0.5, face="bold"),
        plot.subtitle = element_text(hjust = 0.5))+
  scale_fill_gradientn(name="NDVI",colors = greencolors(20))

# refine plot and tile labels

# names attribute for NDVI stack
names(NDVI_HARV_stack)

# changing the rowname to Julian Days
raster_names <- names(NDVI_HARV_stack)
raster_names <-gsub("_HARV_ndvi_crop","",raster_names)
raster_names
labels_names <- setNames(raster_names, unique(NDVI_HARV_stack_df$variable))

# plot the time series
# render our plot with the new labels using a labeller
# adjust the columns of our plot by setting the number of columns ncol and the number of rows nrow in facet_wrap. In this case width of five panels
ggplot()+
  geom_raster(data=NDVI_HARV_stack_df, aes(x=x,y=y,fill=value))+
  facet_wrap(~variable, ncol=5,
             labeller = labeller(variable=labels_names))+
  ggtitle("Landsat NDVI", subtitle = "NEON Harvard Forest")+
  theme_void()+
  theme(plot.title = element_text(hjust=0.5, face="bold"),
        plot.subtitle = element_text(hjust=0.5))+
  scale_fill_gradientn(name="NDVI",colors = greencolors(20))

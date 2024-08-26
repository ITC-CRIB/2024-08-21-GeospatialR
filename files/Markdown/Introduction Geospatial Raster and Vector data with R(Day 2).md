![ITC-CRIB Logo](/uploads/8f24674fa3405411f0ed7e800.png)

# Introduction Geospatial Raster and Vector data with R

06/06/2024, ITC, Enschede

**Welcome to The Workshop Collaborative Document!**

This document is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly.

---

This document is available at https://notes.crib.utwente.nl/2024-08-21-Geospatial-R-Workshop-Day2


Day One: https://notes.crib.utwente.nl/2024-08-21-Geospatial-R-Workshop-Day1

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

##### Install both R and RStudio depending on your machine
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
* Karel Kroeze, k.a.kroeze@utwente.nl

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


---

## Challenge

CHALLENGE: NDVI FOR THE SAN JOAQUIN EXPERIMENTAL RANGE
We often want to compare two different sites. The National Ecological Observatory Network (NEON) also has a field site in Southern California at the San Joaquin Experimental Range (SJER).

For this challenge, create a dataframe containing the mean NDVI values and the Julian days the data was collected (in date format) for the NEON San Joaquin Experimental Range field site. NDVI data for SJER are located in the NEON-DS-Landsat-NDVI/SJER/2011/NDVI directory.


## Collaborative Notes
```python=
# =============== Timeseries Part ====================

library(terra)
library(scales)
library(tidyr)
library(ggplot2)

NDVI_HARV_path <- "data/NEON-DS-Landsat-NDVI/HARV/2011/NDVI/"

all_NDVI_HARV <- list.files(NDVI_HARV_path, full.names = TRUE, pattern = ".tif$")

all_NDVI_HARV

NDVI_HARV_stack <- rast(all_NDVI_HARV)

crs(NDVI_HARV_stack, proj=TRUE)

xres(NDVI_HARV_stack)
yres(NDVI_HARV_stack)

NDVI_HARV_stack_2_df <- as.data.frame(NDVI_HARV_stack, xy=TRUE)

NDVI_HARV_stack_df <- as.data.frame(NDVI_HARV_stack, xy=TRUE) %>%
    pivot_longer(-(x:y), names_to="variable", values_to = "value")

str(NDVI_HARV_stack_df)

ggplot() + geom_raster(data = NDVI_HARV_stack_df, aes(x=x,y=y, fill=value)) + facet_wrap(~variable)

NDVI_HARV_stack <- NDVI_HARV_stack/10000

NDVI_HARV_stack_df <- as.data.frame(NDVI_HARV_stack, xy=TRUE) %>%
    pivot_longer(-(x:y), names_to = "variable", values_to ="value")
    
ggplot() + geom_raster(data = NDVI_HARV_stack_df, aes(x=x,y=y, fill=value)) + facet_wrap(~variable)

ggplot(NDVI_HARV_stack_df) + geom_histogram(aes(value)) + facet_wrap(~variable)

har_met_daily <- read.csv("data/NEON-DS-Met-Time-Series/HARV/FisherTower-Met/hf001-06-daily-m.csv")

str(har_met_daily)

har_met_daily$date <- as.Date(har_met_daily$date, format = "%Y-%m-%d")

str(har_met_daily)

library(dplyr)

yr_11_daily_avg <- har_met_daily %>%
    filter(between(date, as.Date('2011-01-01'), as.Date('2011-12-31')))

ggplot() + geom_point(data = yr_11_daily_avg, aes(jd, airt)) + ggtitle("Daily Mean Air Temperature") + xlab("Julian Days") + ylab("Mean Air Temperature (C)")

avg_NDVI_HARV <- global(NDVI_HARV_stack, mean)

avg_NDVI_HARV

avg_NDVI_HARV$year <- "2011"
avg_NDVI_HARV$site <- "HARV"
head(avg_NDVI_HARV)

julianDays <- gsub("_HARV_ndvi_crop","",row.names(avg_NDVI_HARV))

julianDays

avg_NDVI_HARV$julianDay <- julianDays

class(avg_NDVI_HARV$julianDay)

origin <- as.Date("2011-01-01")

avg_NDVI_HARV$julianDay <- as.integer(avg_NDVI_HARV$julianDay)

avg_NDVI_HARV$Date <- origin + (avg_NDVI_HARV$julianDay - 1)
head(avg_NDVI_HARV$Date)

# ====== Challenge: NDVI for the San Joaquin Experimental Range =======

# read in the NDVI data for the SJER field site


NDVI_path_SJER <- "data/NEON-DS-Landsat-NDVI/SJER/2011/NDVI"

all_NDVI_SJER <- list.files(NDVI_path_SJER,
                            full.names = TRUE,
                            pattern = ".tif$")

NDVI_stack_SJER <- rast(all_NDVI_SJER)

NDVI_stack_SJER <- NDVI_stack_SJER/10000

# calculate the mean values for each day and put that in a dataframe

avg_NDVI_SJER <- as.data.frame(global(NDVI_stack_SJER, mean))

# rename the NDVI column, and add site and year columns to our data

names(avg_NDVI_SJER) <- "NDVI"
avg_NDVI_SJER$year <- "2011"
avg_NDVI_SJER$site <- "SJER"
avg_NDVI_SJER

# we will create our Julian day column

julianDays_SJER <- gsub("_SJER_ndvi_crop", "", row.names(avg_NDVI_SJER))
avg_NDVI_SJER$julianDay <- as.integer(julianDays_SJER)

avg_NDVI_SJER$Date <- origin + (avg_NDVI_SJER$julianDay - 1)

head(avg_NDVI_SJER)
head(avg_NDVI_HARV)

NDVI_HARV_SJER <- rbind(avg_NDVI_HARV, avg_NDVI_SJER)

ggplot(NDVI_HARV_SJER, aes(x=julianDay, y=mean, color=site)) + geom_point(aes(group=site)) + geom_line(aes(group=site)) + ggtitle("Landsat Derived NDVI - 2011", subtitle="Hravard Forest vs San Joaquin") + xlab("Julian Days") + ylab("Mean NDVI")

library(RColorBrewer)
brewer.pal(9,"YlGn")

greencolors <- brewer.pal(9,"YlGn") %>%
    colorRampPalette()

ggplot() + geom_raster(data = NDVI_HARV_stack_df, aes(x=x,y=y,fill=value)) + facet_wrap(~variable) + ggtitle("Landsat NDVI", subtitle = "NEON Harvard Forest") + theme_void() + theme(plot.title = element_text(hjust=0.5, face="bold"), plot.subtitle = element_text(hjust = 0.5)) + scale_fill_gradientn(name="NDVI", colors = greencolors(20))

names(NDVI_HARV_stack)
raster_names <- names(NDVI_HARV_stack)

raster_names <- gsub("_HARV_ndvi_crop","",raster_names)
raster_names

labels_names <- setNames(raster_names, unique(NDVI_HARV_stack_df$variable))

ggplot() + 
    geom_raster(data = NDVI_HARV_stack_df, aes(x=x,y=y,fill=value)) +
    facet_wrap(~variable, ncol=5, labeller = labeller(variable = labels_names)) + 
    ggtitle("Landsat NDVI", subtitle = "NEON Harvard Forest") +
    theme_void() +
    theme(plot.title = element_text(hjust=0.5, face="bold"), plot.subtitle = element_text(hjust=0.5)) +
    scale_fill_gradientn(name="NDVI", colors = greencolors(20))




```


## Additional Links
Post-Workshop Survey : [LINK](https://carpentries.typeform.com/to/UgVdRQ?slug=2024-08-21-GeospatialR)
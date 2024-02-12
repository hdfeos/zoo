# Copyright (C) 2020 by The HDF Group.
#  All rights reserved.
#
# This example code illustrates how to access and visualize LaRC ASDC MOPITT
# L2 Swath in R.
#
# If you have any questions, suggestions, comments  on this example, please 
# use the HDF-EOS Forum (http://hdfeos.org/forums). 
#
# If you would like to see an  example of any other NASA HDF/HDF-EOS data 
# product that is not listed in the HDF-EOS Comprehensive Examples page 
# (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or
#  post it at the HDF-EOS Forum (http://hdfeos.org/forums).
#
# Usage:save this script and run 
#
# $Rscript MOP02J-20131129-L2V17.8.3.he5.r
#
# Tested under: R 3.6.3
# Last updated: 2020-03-03

library(ncdf4)
library(maptools)
library(RColorBrewer)
library(classInt)
library(fields)
data(wrld_simpl)

fname <- 'MOP02J-20131129-L2V17.8.3.he5'
nc <- nc_open(fname)

# Print available datasets.
# nc

lat <- ncvar_get(nc, 'Geolocation Fields/Latitude')
lon <- ncvar_get(nc, 'Geolocation Fields/Longitude')
rst <- ncvar_get(nc, 'Data Fields/RetrievedSurfaceTemperature')

# Subset
rst <- rst[1,]

# subtitle
long_name <- 'RetrievedSurfaceTemperature'
v <- nc$var[['Data Fields/RetrievedSurfaceTemperature']]
units <- ncatt_get(nc, v, "units")
unit_str <- paste("(", units$value, ")", sep="")
subtitle = paste(long_name, unit_str, sep=" ")

# Symbol plot -- equal-interval class intervals
plotvar <- rst
nclr <- 11
plotclr <- brewer.pal(nclr,"RdYlBu")
plotclr <- plotclr[nclr:1] # reorder colors
class <- classIntervals(plotvar, nclr, style="equal")
colcode <- findColours(class, plotclr)
png(paste(fname, ".r.png", sep=""), width=640, height=480)
plot(wrld_simpl)
# 16 means circle. cex=1.0 means size is 1.0
points(lon, lat, pch=16, col=colcode, cex=0.1)

title(fname, sub=subtitle)
legend(-180, -90, legend=names(attr(colcode, "table")), 
        fill=attr(colcode, "palette"), cex=0.6, bty="n", ncol=6)
dev.off()
nc_close(nc)

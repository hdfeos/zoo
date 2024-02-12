# Copyright (C) 2016 by The HDF Group.
#  All rights reserved.
#
# This example code illustrates how to access and visualize GESDISC OCO-2
# Swath in R.
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
# $Rscript oco2_L2StdND_03945a_150330_B6000_150331024816.h5.r
#
# Tested under: R 3.3.1
# Last updated: 2016-11-18

library(ncdf4)
library(maptools)
library(RColorBrewer)
library(classInt)
data(wrld_simpl)

fname <- 'oco2_L2StdND_03945a_150330_B6000_150331024816.h5'
nc <- nc_open(fname)
lat <- ncvar_get(nc, 'RetrievalGeometry/retrieval_latitude')
lon <- ncvar_get(nc, 'RetrievalGeometry/retrieval_longitude')
co2 <- ncvar_get(nc, 'RetrievalResults/xco2')

long_name <- ncatt_get(nc, 'RetrievalResults/xco2', "Description")

# Symbol plot -- equal-interval class intervals
plotvar <- co2
nclr <- 8
plotclr <- brewer.pal(nclr,"PuOr")
plotclr <- plotclr[nclr:1] # reorder colors
class <- classIntervals(plotvar, nclr, style="equal")
colcode <- findColours(class, plotclr)

png(paste(fname, ".r.png", sep=""), width=640, height=480)
plot(wrld_simpl)
points(lon, lat, pch=16, col=colcode, cex=1.0)
title(fname, sub=long_name$value)
legend(-180, 0, legend=names(attr(colcode, "table")), 
    fill=attr(colcode, "palette"), cex=0.6, bty="n")
dev.off()
nc_close(nc)

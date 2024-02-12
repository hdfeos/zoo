# Copyright (C) 2016 by The HDF Group.
#  All rights reserved.
#
# This example code illustrates how to access and visualize GESDISC AIRS Grid
# in R.
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
# $Rscript AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.hdf.r
#
# Tested under: R 3.3.1
# Last updated: 2016-11-18
library(fields)
library(maptools)
library(ncdf4)
data(wrld_simpl)

# Open file.
fname = 'AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.hdf'
nc <- nc_open(fname)

# Select dataset to plot.
v1 <- nc$var[['RelHumid_A']]
z_all <- ncvar_get(nc, 'RelHumid_A')

# Change endianness.
zv <- as.vector(as.single(z_all))
zz <- file("tmpbin", "wb")
writeBin(zv, zz)
close(zz)
zz2 <- file("tmpbin", "rb")
zs <- readBin(zz2, numeric(), size=4, length(zv), endian="little")
close(zz2)
dim(zs) <- dim(z_all)

# Get fill value.
fillvalue <- ncatt_get(nc, v1, "_FillValue")

# Subset.
z <- zs[,,11]

# Flip upside down to geo-locate data properly.
z <- z[,ncol(z):1]

# Skip fill values in plot.
z[z == fillvalue$value] <- NA

# Generate lon / lat values. 
x0 = -179.5
Longitude = seq(x0, 179.5, 1.0)
y0 = -89.5
Latitude = seq(y0, 89.5, 1.0)

# Define min/max values.
zmin=0
zmax=150

# Set color palette.
clevs<-c(0,15,30,45,60,75,90,105,120,135,140,150)
ccols<-c("#5D00FF", "#002EFF","#00B9FF","#00FFB9" ,"#00FF2E","#5DFF00","#E8FF00", "#FF8B00","red", "#FF008B","#E800FF")
palette(ccols)

# Save it as PNG.
png(paste(fname, ".r.png", sep=""), width=640, height=480)

# Plot image.
image.plot(Longitude, Latitude, z, zlim=c(zmin,zmax), breaks=clevs, col=palette(ccols))
plot(wrld_simpl,add=TRUE)
title(fname, sub='RelHumid_A at H2OPrsLvls=11')
dev.off()
nc_close(nc)
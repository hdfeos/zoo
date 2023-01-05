# This example code illustrates how to access and visualize GES DISC AIRS Swath
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
# $Rscript AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf.r
#
# Tested under: R 4.2.2
# Last updated: 2023-01-04

library(fields)
library(maps)
library(sp)
library(RNetCDF)
library(raster)
library(ggmap)
library(akima)
library(reshape)

# Download file.
options(timeout=120)
download.file("https://gamma.hdfgroup.org/ftp/pub/outgoing/NASAHDF/AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf", "AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf")

# Open file.
fname <- 'AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf'
nc <- open.nc(fname)
print.nc(nc)
nc_data <- read.nc(nc)
z_all <- nc_data$topog
zv <- as.vector(as.single(z_all))
zz <- file("tmpbin", "wb")
writeBin(zv, zz)
close(zz)
zz2 <- file("tmpbin", "rb")
zs <- readBin(zz2, numeric(), size=4, length(zv), endian="little")
close(zz2)
dim(zs) <- dim(z_all)
b <- zs[,]
b[b == -9999.0] <- NA
lat <- nc_data$Latitude
lon <- nc_data$Longitude
remap.tbl <- data.frame(coordinates(lon),
                        lon=as.vector(lon),lat=as.vector(lat))
df <- data.frame(lon=as.vector(lon), lat=as.vector(lat), rad=as.vector(b))
png(paste(fname, ".r.png", sep=""), width=640, height=480)
mapWorld <- borders("world") 
wd <- map_data("world")
ggplot() +
mapWorld +
scale_colour_gradient2(name = "topog", low="blue", mid="green", high="red", na.value="white", midpoint=60) +
geom_point(data = df, aes(x = lon, y = lat, colour=rad), na.rm=TRUE) +
ggtitle(fname) +
ylab("Latitude") +
xlab("Longitude") +
theme_linedraw() +
theme(plot.title = element_text(size = 15, face = "bold"),
legend.title = element_text(size = 15),
axis.text = element_text(size = 15),
axis.text.x = element_blank(),
axis.title.x = element_blank(),
axis.title.y = element_text(size = 20, vjust = 0.2),
legend.text = element_text(size = 10)) +
coord_map("stereographic", orientation=c(90, 0,0), ylim=c(90, 60))
dev.off()
close.nc(nc)
getwd()
list.files('.')

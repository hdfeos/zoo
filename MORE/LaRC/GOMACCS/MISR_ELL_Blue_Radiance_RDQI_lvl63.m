%This example code illustrates how to access and visualize LaRC_GOMACCS Grid file in Matlab. 
%If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='MISR_ELLIPSOID_GM_P017_O036105_DF_F03_0024_GOM_b64-72.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='BlueBand';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Blue Radiance/RDQI';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=squeeze(data1(:,:,64));

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

% This file contains coordinate variables that will not properly plot. 
% To properly display the data, the latitude/longitude must be remapped.

%Since it is not YDimMajor, the xdimsize and ydimsize should change.
[ydimsize, xdimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

% The file contains SOM projection. We need to use eosdump to generate 1D lat and lon
% and then convert them to 2D lat and lon accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load('lat_MISR_ELLIPSOID_GM_P017_O036105_DF_F03_0024_GOM_b64-72.output');
lon1D = load('lon_MISR_ELLIPSOID_GM_P017_O036105_DF_F03_0024_GOM_b64-72.output');

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

%Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Blue Radiance/RDQI';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


figure('Name','MISR_ELLIPSOID_GM_P017_O036105_DF_F03_0024_GOM_b64-72_Blue_Radiance/RDQI_SOMBlockDim63')

axesm('MapProjection','mercator','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on','MLabelLocation',lonlim,'PLabelLocation',latlim)
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:1000:max_data);

plotm(coast.lat,coast.long,'k')

title({'MISR\_ELLIPSOID\_GM\_P017\_O036105\_DF\_F03\_0024\_GOM\_b64-72\_Blue\_Radiance/RDQI' ; 'at SOMBlockDim=63'},'FontSize',16,'FontWeight','bold');

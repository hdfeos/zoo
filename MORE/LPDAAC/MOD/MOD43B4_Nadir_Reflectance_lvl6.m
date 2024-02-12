%This example code illustrates how to access and visualize LP_DAAC_MOD Grid file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='MOD43B4.A2006353.h15v15.004.2007006030047.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='MOD_Grid_BRDF';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Nadir_Reflectance';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=squeeze(data1(7,:,:));

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

% This file contains coordinate variables that will not properly plot. 
% To properly display the data, the latitude/longitude must be remapped.

[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

% The file contains SINSOID projection. We need to use eosdump to generate 1D lat and lon
% and then convert them to 2D lat and lon accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load('lat_MOD43B4.A2006353.h15v15.004.2007006030047.output');
lon1D = load('lon_MOD43B4.A2006353.h15v15.004.2007006030047.output');

% lat = zeros(ydimsize, xdimsize);
% lon = zeros(ydimsize, xdimsize);

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

%Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Nadir_Reflectance';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

%Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale * (data - offset);

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


figure('Name','MOD43B4.A2006353.h15v15.004.2007006030047_Nadir_Reflectance_Num_Land_Bands6')

axesm('MapProjection','sinusoid','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on','MLabelLocation',lonlim,'PLabelLocation',latlim)
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:0.1:max_data);

plotm(coast.lat,coast.long,'k')

title({'MOD43B4.A2006353.h15v15.004.2007006030047\_Nadir\_Reflectance' ; ['at Num\_Land\_Bands=6, units: ',units]},'FontSize',16,'FontWeight','bold');

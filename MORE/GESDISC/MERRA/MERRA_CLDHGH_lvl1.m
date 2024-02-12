%This example code illustrates how to access and visualize GESDISC_MERRA Grid in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='MERRA300.prod.assim.tavgU_2d_chm_Fx.200201.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='EOSGRID';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='CLDHGH';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=squeeze(data1(:,:,2));

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

%Reading Lat Data
DATAFIELD_NAME='XDim';
[lon, status] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
lon=double(lon);

%Reading Lon Data
DATAFIELD_NAME='YDim';
[lat, status] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
lat=double(lat);

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

%Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='CLDHGH';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading fillvalue and missing value from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

missingvalue_index = hdfsd('findattr', sds_id, 'missing_value');
[missingvalue, status] = hdfsd('readattr',sds_id, missingvalue_index);

%Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Reading scale_factor from a Data Field
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
%Convert to double type for plot
scale = double(scale);

%Reading add_offset from a Data Field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
%Convert to double type for plot
offset = double(offset);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Replacing the missing value with NaN
data(data==missingvalue) = NaN;

%Multiplying scale and adding offset
data = data*scale + offset ;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


figure('Name','MERRA300.prod.assim.tavgU_2d_chm_Fx.200201_CLDHGH_TIME1')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:0.1:max_data);

plotm(coast.lat,coast.long,'k')

title({'MERRA300.prod.assim.tavgU\_2d\_chm\_Fx.200201\_CLDHGH.hdf';['at TIME=1, units: ',units]},'FontSize',16,'FontWeight','bold');


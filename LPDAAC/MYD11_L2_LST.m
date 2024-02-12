%This example code illustrates how to access and visualize LP_DAAC_MYD Swath file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Swath File
FILE_NAME='MYD11_L2.A2007093.0735.005.2007101061952.hdf';
file_id = hdfsw('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
SWATH_NAME='MOD_Swath_LST';
swath_id = hdfsw('attach', file_id, SWATH_NAME);

DATAFIELD_NAME='LST';

[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

%Detaching from the Swath Object
hdfsw('detach', swath_id);
%Closing the File
hdfsw('close', file_id);

%Read lat and lon data
FILE_NAME='MYD03.A2007093.0735.005.2009281140106.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

%Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
%Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

%Reading lat and lon data
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

%Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

%Convert M-D data to 2-D data
data=data1;

%Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

%Reading attributes from the data field
FILE_NAME='MYD11_L2.A2007093.0735.005.2007101061952.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='LST';

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
scale = double(scale);

%Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

% Reading long_name from the data field
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f=figure('Name','MYD11_L2.A2007093.0735.005.2007101061952_LST','visible','off')

axesm('MapProjection','eqdcylin', 'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:5:max_data);

plotm(coast.lat,coast.long,'k')

% title(['MYD11\_L2.A2007093.0735.005.2007101061952\_LST, units: ',units],'FontSize',16,'FontWeight','bold');
title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
    'FontSize',12,'FontWeight','bold');

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);

set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'MYD11_L2.A2007093.0735.005.2007101061952_LST.m.jpg');
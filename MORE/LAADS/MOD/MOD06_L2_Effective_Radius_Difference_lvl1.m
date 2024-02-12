%This example code illustrates how to access and visualize LAADS_MOD swath file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

%Read data field
FILE_NAME='MOD06_L2.A2010001.0000.005.2010005213214.hdf';
SWATH_NAME='mod06';

%Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
%Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

%Reading Data from a Data Field
DATAFIELD_NAME='Effective_Radius_Difference';

[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

%Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

%Read lat and lon data
FILE_NAME='MOD03.A2010001.0000.005.2010003235220.hdf';
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
data=squeeze(data1(:,:,2));

%Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

%Reading attributes from the data field
FILE_NAME='MOD06_L2.A2010001.0000.005.2010005213214.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Effective_Radius_Difference';

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

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

%Plot the data using contourfm and axesm
pole=[-90 0 0];
latlim=[-90,ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','MOD06_L2.A2010001.0000.005.2010005213214_Effective_Radius_Difference_Radius_Difference1')

axesm('MapProjection','stereo','MapLatLimit', latlim, 'MapLonLimit',lonlim, 'Origin',pole,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');


contourfm(lat, lon, data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:10:max_data);

plotm(coast.lat,coast.long,'k')

title({'MOD06\_L2.A2010001.0000.005.2010005213214\_Effective\_Radius\_Difference';['at Radius\_Difference=1, units: ',units]}, 'FontSize',16,'FontWeight','bold');
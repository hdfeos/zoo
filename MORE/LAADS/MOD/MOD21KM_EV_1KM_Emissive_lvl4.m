%This example code illustrates how to access and visualize LAADS_MOD swath file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

%Read data field
FILE_NAME='MOD021KM.A2000055.0000.005.2010041143816.hdf';
SWATH_NAME='MODIS_SWATH_Type_L1B';

%Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
%Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

%Reading Data from a Data Field
DATAFIELD_NAME='EV_1KM_Emissive';

[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

%Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

%Read lat and lon data
FILE_NAME='MOD03.A2000055.0000.005.2010029175839.hdf';
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
data=squeeze(data1(:,:,5));

%Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

%Reading attributes from the data field
FILE_NAME='MOD021KM.A2000055.0000.005.2010041143816.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='EV_1KM_Emissive';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'radiance_units');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'radiance_scales');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
%The scale is an array. We need to find the corresponding one.
scale = scale(5);
scale = double(scale);

%Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'radiance_offsets');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = offset(5);
offset = double(offset);

%Reading valid_range from the data field
range_index = hdfsd('findattr', sds_id, 'valid_range');
[range, status] = hdfsd('readattr',sds_id, range_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;
data(data>range(2)) = NaN;

%Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

%Plot the data using contourfm and axesm
pole=[90 0 0];
latlim=[floor(min(min(lat))),90];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','MOD021KM.A2000055.0000.005.2010041143816_EV_1KM_Emissive_Band_1KM_Emissive4')

axesm('MapProjection','stereo','MapLatLimit', latlim, 'MapLonLimit',lonlim, 'Origin',pole,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');


contourfm(lat, lon, data);
colormap('Jet');
caxis([min(min(data)) max(max(data))]); 
colorbar('YTick', min(min(data)):0.01:max(max(data)));

plotm(coast.lat,coast.long,'k')

title({'MOD021KM.A2000055.0000.005.2010041143816\_EV\_1KM\_Emissive' ; ['at Band\_1KM\_Emissive=4, units: ',units]}, 'FontSize',16,'FontWeight','bold');
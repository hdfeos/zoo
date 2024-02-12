clear
%Opening the HDF4 File
FILE_NAME='2B31_CSI.990911.10296.KORA.6.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

%Reading Data from a Data Field
DATAFIELD_NAME='rHat';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Convert M-D data to 2-D data
data=squeeze(data1(21,:,:));

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

%Reading GEO information from a Data Field
DATAFIELD_NAME='geolocation';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[geo, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

lat=squeeze(geo(1,:,:));
lon=squeeze(geo(2,:,:));

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

%Replacing the filled value -9999 with NaN
data(data == -9999) = NaN;

%Multiplying scale and adding offset
data = data*scale + offset ;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','2B31_CSI.990911.10296.KORA.6_rHat_height20')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');


contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:20:max_data);

plotm(coast.lat,coast.long,'k')

title({'2B31\_CSI.990911.10296.KORA.6\_rHat.hdf';'at height=20'},'FontSize',16,'FontWeight','bold');

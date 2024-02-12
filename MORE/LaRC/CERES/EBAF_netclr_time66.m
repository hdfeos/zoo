%This example code illustrates how to access and visualize LaRC_CERES HDF4 file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF4 File
FILE_NAME='CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

%Reading Data from a Data Field
DATAFIELD_NAME='netclr';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Convert M-D data to 2-D data
data=squeeze(data1(:,:,67));

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

%Reading Units
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);

%Reading lat information from a Data Field
DATAFIELD_NAME='lat';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Convert the data to double type for plot
lat=double(lat);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);


%Reading lon information from a Data Field
DATAFIELD_NAME='lon';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Convert the data to double type for plot
lon=double(lon);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);

%Closing the File
hdfsd('end', SD_id);

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc_netclr_time66')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');


contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:20:max_data);

plotm(coast.lat,coast.long,'k')

title({'CERES\_EBAF\_TOA\_Terra\_Edition1A\_200003-200510.nc\_netclr';['at time=66, units: ',units]},'FontSize',16,'FontWeight','bold');

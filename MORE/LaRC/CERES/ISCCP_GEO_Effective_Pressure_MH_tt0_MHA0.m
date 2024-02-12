%This example code illustrates how to access and visualize LaRC_CERES HDF4 file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF4 File
FILE_NAME='CER_ISCCP-D2like-GEO_Composite_Beta1_023031.200510.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

%Reading Data from a Data Field
DATAFIELD_NAME='Effective Pressure - MH';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Convert M-D data to 2-D data
data=squeeze(data1(:,:,1,1));

%Convert the data to double type for plot
data=double(data);

data = data';

%Reading fillvalue
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Reading Units
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);

%Reading lat information from a Data Field
DATAFIELD_NAME='Colatitude - MH';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[colat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Convert M-D lat to 1-D lat
colat=squeeze(colat(:,:,1));
colat=squeeze(colat(1,:));

%Convert the data to double type for plot
colat=double(colat);

%Reading fillvalue
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Replacing the filled value with NaN
colat(colat==fillvalue) = NaN;

%Convert colat to lat
lat = 90 - colat;

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);


%Reading lon information from a Data Field
DATAFIELD_NAME='Longitude - MH';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Convert M-D lon to 1-D lon
lon=squeeze(lon(:,:,1));
lon=squeeze(lon(:,1));

%Convert the data to double type for plot
lon=double(lon);

%Reading fillvalue
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Replacing the filled value with NaN
lon(lon==fillvalue) = NaN;

%If lon>180, then lon = lon - 360 to make the plot shown continuously.
lon(lon>180)=lon(lon>180)-360;

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);

%Closing the File
hdfsd('end', SD_id);

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','CER_ISCCP-D2like-GEO_Composite_Beta1_023031.200510_Effective_Pressure-MH_thin_thick0_Monthly_Hourly_Avgs0')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');


contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:20:max_data);

plotm(coast.lat,coast.long,'k')

title({'CER\_ISCCP-D2like-GEO\_Composite\_Beta1\_023031.200510\_Effectiv\_Pressure-MH'; ... 
    ['at thin\_thick=0 and Monthly\_Hourly\_Avgs=0, units: ',units]},'FontSize',16,'FontWeight','bold');

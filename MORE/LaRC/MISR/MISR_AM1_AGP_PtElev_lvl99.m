%This example code illustrates how to access and visualize LaRC_MISR Grid file in Matlab. 
%If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='MISR_AM1_AGP_P001_F01_24.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='Standard';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='PtElev';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
%Read lat and lon. It provides GeoLatitude and GeoLongitude in the
%datafield of group1.
[lat1, fail] = hdfgd('readfield', grid_id, 'GeoLatitude', [], [], []);
[lon1, fail] = hdfgd('readfield', grid_id, 'GeoLongitude', [], [], []);

%Convert M-D data to 2-D data
data=squeeze(data1(:,:,100));
lat=squeeze(lat1(:,:,100));
lon=squeeze(lon1(:,:,100));

%Convert the data to double type for plot
data=double(data);
lat=double(lat);
lon=double(lon);

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


figure('Name','MISR_AM1_AGP_P001_F01_24_PtElev_SOMBlockDim99')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on','MLabelLocation',lonlim,'PLabelLocation',latlim)
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:20:max_data);

plotm(coast.lat,coast.long,'k')

title({'MISR\_AM1\_AGP\_P001\_F01\_24\_PtElev' ; 'at SOMBlockDim=99'},'FontSize',16,'FontWeight','bold');

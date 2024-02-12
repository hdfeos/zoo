%This example code illustrates how to access and visualize GESDISC_AIRS Grid in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Swath File
FILE_NAME='AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0.G06100185050.hdf';
SWATH_NAME='L2_Standard_cloud-cleared_radiance_product';

file_id = hdfsw('open', FILE_NAME, 'rdonly');
swath_id = hdfsw('attach', file_id, SWATH_NAME);

%Reading Data from a Data Field
DATAFIELD_NAME='CldClearParam';
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

%Convert M-D data to 2-D data
data=squeeze(data1(1,1,:,:));

%Replacing the filled value with NaN
data(data==-9999) = NaN;

%Detaching from the Swath Object and closing the File
hdfsw('detach', swath_id);
hdfsw('close', file_id);

%Plot the data using contourfm and axesm
pole=[-90 0 0];
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0.G06100185050_CldClearParam_AT0_AXT0')
axesm('MapProjection','stereo','MapLatLimit',latlim,'MapLonLimit',lonlim,'Origin',pole,'Frame','on','Grid','on', ...
   'MeridianLabel','on','ParallelLabel','on')

coast = load('coast.mat');

contourfm(double(lat),double(lon),double(data))

colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:max_data);

plotm(coast.lat,coast.long,'k')

title({'AIRS.2002.12.31.001.L2.CC\_H.v4.0.21.0.G06100185050\_CldClearParam';'at AIRSTrack=0 and AIRSXTrack=0'} ,'FontSize',16,'FontWeight','bold');
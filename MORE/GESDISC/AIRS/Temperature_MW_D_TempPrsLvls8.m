%This example code illustrates how to access and visualize GESDISC_AIRS Grid in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='descending_MW_only';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Temperature_MW_D';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=squeeze(data1(:,:,9));

%Convert the data to double type for plot
data=double(data);

%Reading filledValue from a Data Field
[fillvalue,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Detaching from the Grid Object
hdfgd('detach', grid_id);

%Reading Lat and Lon Data 
GRID_NAME='location';
grid_id = hdfgd('attach', file_id, GRID_NAME);

%Reading Lat Data
DATAFIELD_NAME='Latitude';
[lat, status] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
lat=double(lat);
[fillvalue,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);
lat(lat==fillvalue) = NaN;

%Reading Lon Data
DATAFIELD_NAME='Longitude';
[lon, status] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
lon=double(lon);
[fillvalue,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);
lon(lon==fillvalue) = NaN;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


figure('Name','AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732_Temperature_MW_D_TempPrsLvls8')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:5:max_data);

plotm(coast.lat,coast.long,'k')

title({'AIRS.2002.08.01.L3.RetStd\_H031.v4.0.21.0.G06104133732\_Temperature\_MW\_D.hdf';'at TempPrsLvls=8'},'FontSize',16,'FontWeight','bold');

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

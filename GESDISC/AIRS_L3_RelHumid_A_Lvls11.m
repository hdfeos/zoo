% This example code illustrates how to access and visualize GESDISC_AIRS Grid in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum 
% (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed 
% in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Open the HDF-EOS2 Grid File.
FILE_NAME='AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='ascending';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='RelHumid_A';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Convert 3D data to 2D data.
data=squeeze(data1(:,:,12));

% Convert the data to double type for plot.
data=double(data);

% Read filledValue from a data field.
[fillvalue,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Attach to geo-location grid. 
GRID_NAME='location';
grid_id = hdfgd('attach', file_id, GRID_NAME);

% Read lat data.
LAT_NAME='Latitude';
[lat, status] = hdfgd('readfield', grid_id, LAT_NAME, [], [], []);
lat=double(lat);

% Read lon data.
LON_NAME='Longitude';
[lon, status] = hdfgd('readfield', grid_id, LON_NAME, [], [], []);
lon=double(lon);


% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f=figure('Name','AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732_RelHumid_A_H2OPrsLvls11','visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','FontSize',10)
coast = load('coast.mat');

surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
h=colorbar('YTick', min_data:10:max_data, 'FontSize',20);

plotm(coast.lat,coast.long,'k');

% See "AIRS Version 5.0 Released Files Description" document [1]
% for unit specification.
units = '%';

title({FILE_NAME; [DATAFIELD_NAME ' at H2OPrsLvls=11']}, 'Interpreter', 'None', 'FontSize',26,'FontWeight','bold');


set (get(h, 'title'), 'string', units, 'FontSize',26,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732_RelHumid_A_H2OPrsLvls11.m.jpg');

% References
%
% [1] http://disc.sci.gsfc.nasa.gov/AIRS/documentation/v5_docs/AIRS_V5_Release_User_Docs/V5_Released_ProcFileDesc.pdf
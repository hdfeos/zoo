%
%   This example code illustrates how to access and visualize LAADS
% NPP VIIRS Swath file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this
% example, please use the HDF-EOS Forum  (http://hdfeos.org/forums). 

%   If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the 
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2012a
% Last updated: 2012-10-11


clear

% Open the HDF-EOS2 Swath File.
FILE_NAME='NPP_VSTIP_L2.A2012002.2340.P1_03001.2012022162425.hdf';
SWATH_NAME='IceQuality_SurfaceTemp ';

file_id = hdfsw('open', FILE_NAME, 'rdonly');
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Read data from a data field.
DATAFIELD_NAME='SurfaceTemperature';
[data, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);
lon=double(lon);
lat=double(lat);
data=double(data);

% Replace the filled value with NaN.
data(data < 0) = NaN;

% We could not get the data product specification that explains units, etc.
units = 'Unknown';
long_name = DATAFIELD_NAME;

% Detach from the Swath object and close the file.
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Plot the data using surfacem() and axesm().
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% Create the figure.
f=figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on');
coast = load('coast.mat');

surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);

set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');

plotm(coast.lat,coast.long,'k')

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
    'FontSize',16,'FontWeight','bold');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large. (cf. scrsz = get(0,'ScreenSize');)
scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;

%   This example code illustrates how to access and visualize LaRC MOPITT
%   Grid HDF-EOS2 file in MATLAB.
%
%   If you have any questions, suggestions, comments  on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2011-11-03

clear

% Open the HDF-EOS2 Grid file.
FILE_NAME='MOP03-20000303-L3V1.0.1.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='MOP03';
grid_id = hdfgd('attach', file_id, GRID_NAME);
DATAFIELD_NAME='CO Profiles Day';
[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], ...
                      []);

% Read lat, lon, and pressure. It provides GeoLatitude and GeoLongitude in the
% datafield of group1.
[pressure, fail] = hdfgd('readfield', grid_id, 'Pressure Grid', [], [], []);
[lat, fail] = hdfgd('readfield', grid_id, 'Latitude', [], [], []);
[lon, fail] = hdfgd('readfield', grid_id, 'Longitude', [], [], []);

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Set subset index.
zdim = 2;

% Convert 3-D data to 2-D data
data=squeeze(data1(zdim,:,:));

% Transpose the data to match the map projection.
data=data';

% Convert the data to double type for plot.
data=double(data);
lat=double(lat);
lon=double(lon);

% Replace the fill value with NaN.
data(data==-9999) = NaN;

% Create a figure.
f=figure('Name',FILE_NAME,'visible','off');

% Plot the data using axesm, surfm, and plotm if mapping toolbox exists.
if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
	pcolor(lon,lat,double(data)); shading flat
else
    coast = load('coast.mat');
    latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
    lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
    axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
          'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
          'MeridianLabel','on','ParallelLabel','on')
    % You can use contourfm here but surfm is much faster.
    surfm(lat,lon,data);
    plotm(coast.lat,coast.long,'k')
end


% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=min(min(data));
max_data=max(max(data));
granule = (max_data - min_data) / ntickmarks;

% Put colorbar.
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);

% Set title.
tstring = {FILE_NAME; [DATAFIELD_NAME ' at Pressure=' ...
                    sprintf('%d', pressure(zdim)) ' hPa']};
title(tstring,'FontSize',16,'FontWeight','bold');

% Unit is "ppbv" according to specification [1]. It's not in the file.
units = 'ppbv';
set (get(h, 'title'), 'string', units, ...
                   'FontSize', 16, 'FontWeight', 'bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,'MOP03-20000303-L3V1.0.1_CO_Profiles_Day_level1.m.jpg');

exit;

% References
%
% [1] http://www.acd.ucar.edu/mopitt/file-spec.shtml#L3
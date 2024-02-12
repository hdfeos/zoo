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

% Read lat, lon, and pressure.
[pressure, fail] = hdfgd('readfield', grid_id, 'Pressure Grid', [], ...
                         [], []);
[lon, fail] = hdfgd('readfield', grid_id, 'Longitude', [], [], []);
[lat, fail] = hdfgd('readfield', grid_id, 'Latitude', [], [], []);


% Detach from the grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Set subset index.
xdim = 179;

% Convert 3-D data to 2-D data.
data=squeeze(data1(:,xdim,:));

% Convert the data to double type for plot.
data=double(data);
pressure=double(pressure);
lat=double(lat);
lon = double(lon);

% Replace the fill value with NaN.
data(data==-9999) = NaN;

% Plot the data using contourf.
f=figure('Name', FILE_NAME, 'visible','off');
contourf(lat, pressure, data);

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=min(min(data));
max_data=max(max(data));
granule = (max_data - min_data) / ntickmarks;

% Put the colorbar.
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);

% Unit is "ppbv" according to specification [1]. It's not in file.
units = 'ppbv';
set (get(h, 'title'), 'string', units, 'FontSize', 16, ...
                   'FontWeight','bold');

% Set axis labels according to specification [1].
xlabel('Latitude (degrees)'); 
ylabel('Pressure Level (hPa)');

% Set title.
tstring = {FILE_NAME; [DATAFIELD_NAME ' at Longitude=' sprintf('%3.1f', ...
                                                  lon(xdim)) ' degrees east']};
title(tstring, 'FontSize', 16, 'FontWeight', 'bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 640 480];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,['MOP03-20000303-' ...
          'L3V1.0.1_CO_Profiles_Day_vertical_level178.m.jpg']);
exit;

% References
%
% [1] http://www.acd.ucar.edu/mopitt/file-spec.shtml#L3
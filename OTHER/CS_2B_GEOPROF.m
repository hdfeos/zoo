%  This example code illustrates how to access and visualize CDPC CloudSAT
% Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2011-11-16

clear

% Open the HDF-EOS2 Swath File.
FILE_NAME = '2010128055614_21420_CS_2B-GEOPROF_GRANULE_P_R04_E03.hdf';
file_id = hdfsw('open', FILE_NAME, 'rdonly');

% Read data.
SWATH_NAME = '2B-GEOPROF';
swath_id = hdfsw('attach', file_id, SWATH_NAME);
DATAFIELD_NAME = 'Radar_Reflectivity';
[data, status] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [],[],[]);

% Read lat/lon/height/time data.
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);
[height, status] = hdfsw('readfield', swath_id, 'Height', [], [], []);
[time, status] = hdfsw('readfield', swath_id, 'Profile_time', [], [], []);

% Make type double for plotting.
lat=double(lat);
lon=double(lon);
time=double(time);
data=double(data);

% Read attributes.
[long_name, status] = hdfsw('readattr', swath_id, ...
                       'Radar_Reflectivity.long_name');
[units, status] = hdfsw('readattr', swath_id, ...
                       'Radar_Reflectivity.units');
[scale_factor, status] = hdfsw('readattr', swath_id, ...
                               'Radar_Reflectivity.factor');
scale_factor = double(scale_factor);

[valid_range, status] = hdfsw('readattr', swath_id, ...
                              'Radar_Reflectivity.valid_range');

[units_h, status] = hdfsw('readattr', swath_id, ...
                       'Height.units');

[units_t, status] = hdfsw('readattr', swath_id, ...
                       'Profile_time.units');
[long_name_t, status] = hdfsw('readattr', swath_id, ...
                       'Profile_time.long_name');

hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Process valid_range. Fill value and missing value will be handled by this
% since they are outside of range values.
data((data < valid_range(1)) | (data > valid_range(2))) = NaN;

% Apply scale factor according to [1].
data = data / scale_factor;

f=figure('Name', FILE_NAME, 'visible', 'off');
subplot(2,1,1);
% Subset if you want.
% x = data(:,1:700);
% t = time(1:700);
% pcolor(t, height(:,1), x);

% Plot all. contourf is too slow. 
% Although 2D height values are all slightly different at each profile 
% time, the difference is not significant. Pick the first one only since
% we don't know how to align data along 2-D height axis.
pcolor(time, height(:,1), data);

% Without the following trick, you'll see black image because there
% are too many data points and their black borders will dominate
% the image.
shading flat;

% Put Y-axis label.
unitsh = sprintf('%s', units_h);
ylabel(['Height (' unitsh ')']);

% Put X-axis label.
unitst = sprintf('%s', units_t);
namet = sprintf('%s', long_name_t);
xlabel([namet ' (' unitst ')']);

% Draw colorbar.
h = colorbar();

% Draw unit.
unit = sprintf('%s', units);
set(get(h, 'title'), 'string', unit, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
name = sprintf('%s', long_name);
tstring = {FILE_NAME;name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');

subplot(2,1,2);
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% Plot the satellite path in blue.
plotm(lat, lon, 'b')

% Plot world map coast line.
plotm(coast.lat, coast.long, 'k');

% Annotate the starting point of the path.
textm(lat(1), lon(1), '+', 'FontSize', 16, 'FontWeight','bold', ...
      'Color', 'red');

% Put title.
title('Trajectory of Satellite Path (+:starting point)',...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 1200];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;

%  References
%
% [1] http://www.cloudsat.cira.colostate.edu/dataSpecs.php
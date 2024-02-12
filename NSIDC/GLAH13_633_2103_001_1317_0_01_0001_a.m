%
%  This example code illustrates how to access and visualize ICESat/GLAS
% L2 HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2012a
% Last updated: 2013-1-14

clear

% Open the HDF5 File.
FILE_NAME = 'GLAH13_633_2103_001_1317_0_01_0001.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='Data_1HZ/Geolocation/d_lat';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='Data_1HZ/Geolocation/d_lon';
lon_id=H5D.open(file_id, LONFIELD_NAME);

LEVFIELD_NAME='Data_1HZ/Atmosphere/d_Surface_temp';
temp_id=H5D.open(file_id, LEVFIELD_NAME);

TIMEFIELD_NAME='Data_1HZ/Time/d_UTCTime_1';
time_id=H5D.open(file_id, TIMEFIELD_NAME);

% Read the datasets.
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
temp=H5D.read(temp_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time_utc=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time = (time_utc - time_utc(1));

% We used HDFView to check lat/lon's fill  values.
fillvalue = latitude(2);
latitude(latitude == fillvalue) = NaN;
fillvalue_lon = lon(2);
lon(lon == fillvalue_lon) = NaN;


% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (temp_id, ATTRIBUTE);
units_temp = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (temp_id, ATTRIBUTE);
long_name_temp = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (temp_id);
H5D.close (time_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);


% Create the graphics figure.
f=figure('Name', FILE_NAME, 'visible', 'off');

% Put title.
tstring = {FILE_NAME};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% Plot elapsed time vs surface temperature.
subplot(3,1,1);
plot(time, temp, '-*b');
grid on;
axis square;

% Put labes on line X-Y plot.
long_name = sprintf('%s', char(long_name_temp));
units = sprintf('%s', char(units_temp));
xlabel('Elapsed Time (seconds)'); 
ylabel(strcat(long_name, ' (', units, ')'));


% Put title.
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% Plot the starting location of flight path.
subplot(3,1,2);
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% Plot world map coast line.
plotm(coast.lat, coast.long, 'k');

% Annotate the starting point of the path.
textm(latitude(1), lon(1), '+', 'FontSize', 16, 'FontWeight','bold', ...
      'Color', 'red');

% Put title.
title('Starting Location of Flight Path',...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');



% Plot the trajectory of flight path.
subplot(3,1,3);


% Draw axis. 
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...      
      'MLabelParallel','south')

% Plot the flight path in blue.
plotm(latitude, lon, 'b')

% Plot world map coast line.
coast = load('coast.mat');
plotm(coast.lat, coast.long, 'k');

% Annotate the starting point of the path.
textm(latitude(1), lon(1), '+', 'FontSize', 16, 'FontWeight','bold', ...
      'Color', 'red');

% Put title.
title('Trajectory of Flight Path',...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 3*600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.a.m.jpg']);
exit;


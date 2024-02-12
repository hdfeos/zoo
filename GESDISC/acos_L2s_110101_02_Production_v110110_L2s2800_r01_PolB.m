%  This example code illustrates how to access and visualize GES DISC GOSAT 
% ACOS L2 Swath HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2011-11-18

clear

% Open the HDF5 File.
FILE_NAME = 'acos_L2s_110101_02_Production_v110110_L2s2800_r01_PolB_110124184213.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = 'RetrievalResults/xco2';
data_id = H5D.open(file_id, DATAFIELD_NAME);

LATFIELD_NAME='SoundingGeometry/sounding_latitude_geoid';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='SoundingGeometry/sounding_longitude_geoid';
lon_id=H5D.open(file_id, LONFIELD_NAME);

LEVFIELD_NAME='SoundingGeometry/sounding_altitude';
lev_id=H5D.open(file_id, LEVFIELD_NAME);

TIMEFIELD_NAME='SoundingHeader/sounding_time_tai93';
time_id=H5D.open(file_id, TIMEFIELD_NAME);

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
lev=H5D.read(lev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time_tai=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time = (time_tai - time_tai(1));
  
% Read the attributes.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lev_id, ATTRIBUTE);
units_lev = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Create the graphics figure.
f=figure('Name', FILE_NAME, 'visible', 'off');

% Time vs CO2.
subplot(3,1,1);
plot(time, data, '-*b');
grid on;
axis square;

xlabel('Elapsed Time (seconds)'); 

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction. This unit has '{}' so we need to cast
% the string according to [1].
units_data = sprintf('%s', char(units));

%  You can get the meaningful description of data from the
% "README Document for ACOS Level 2 Standard Product" [2] or the XML
% description file that is provided by GES-DISC.
ylabel(['CO2 column averaged dry air mole fraction (' units_data ')']);

% Put title.
timelvl=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time_tai(1)/86400));
tstring = {FILE_NAME; ['Start Time = ' timelvl]};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% Time vs Altitude.
subplot(3,1,2);
plot(time, lev, '-*b');
grid on;
axis square;

units_height = sprintf('%s', char(units_lev));
xlabel('Elapsed Time (seconds)'); 
ylabel(['Altitude (' units_height  ')']);

% Put title.
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% Trajectory.
subplot(3,1,3);
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% Plot the satellite path in blue.
plotm(latitude, lon, 'b')

% Plot world map coast line.
plotm(coast.lat, coast.long, 'k');

% Annotate the starting point of the path.
textm(latitude(1), lon(1), '+', 'FontSize', 16, 'FontWeight','bold', ...
      'Color', 'red');

% Put title.
title('Trajectory (+:starting point)',...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 3*600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;

% References
%
% [1] http://desk.stinkpot.org:8080/tricks/index.php/2006/02/cast-a-cell-as-a-string/
% [2] ftp://aurapar1u.ecs.nasa.gov/ftp/data/s4pa/GOSAT_TANSO_Level2/ACOS_L2S.002/doc/README.ACOS_L2S_v2.8.pdf

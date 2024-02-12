%
%  This example code illustrates how to access and visualize ICESAT-2 MABEL
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
% Last updated: 2013-01-14

clear

% Open the HDF5 File.
FILE_NAME = 'mabel_l2a_20110405T183000_005_1.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='photon/channel001/latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='photon/channel001/longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

LEVFIELD_NAME='photon/channel001/elev';
lev_id=H5D.open(file_id, LEVFIELD_NAME);

TIMEFIELD_NAME='photon/channel001/delta_time';
time_id=H5D.open(file_id, TIMEFIELD_NAME);

% Read the datasets.
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
ATTRIBUTE = 'units';

attr_id = H5A.open_name (lev_id, ATTRIBUTE);
units_lev = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (lev_id);
H5D.close (time_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);


% Create the graphics figure.
f=figure('Name', FILE_NAME, 'visible', 'off');

% Put title.
tstring = {FILE_NAME; ['100 sample points of channel001']};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% Sample only 100 data because the dataset is big.
s = size(time);
step = ceil(s / 100);

% Plot elapsed time vs elevation.
subplot(3,1,1);
plot(time(1:step:s), lev(1:step:s), '-*b');
grid on;
axis square;

units_height = sprintf('%s', char(units_lev));
xlabel('Elapsed Time (seconds)'); 
ylabel(['Altitude (' units_height  ')']);

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
latlim=[min(min(latitude)),max(max(latitude))];
lonlim=[min(min(lon)),max(max(lon))];

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLineLocation', 0.01, 'PLineLocation', 0.01, ...
      'LabelUnits', 'dms', ... 
      'MLabelParallel','south')
coast = load('coast.mat');

% Plot the flight path in blue.
plotm(latitude(1:step:s), lon(1:step:s), 'b')

% Plot world map coast line.
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
saveas(f, [FILE_NAME '.m.jpg']);
exit;


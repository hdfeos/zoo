%
%   This example code illustrates how to access and visualize LaRC MOPITT Swath
%  HDF-EOS2 file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MOP02_20000303_L2V5_7_1_val_hdf
%
% Tested under: MATLAB R2012a
% Last updated: 2013-12-09

clear

% Open the HDF4 file.
FILE_NAME='MOP02-20000303-L2V5.7.1.val.hdf';
SWATH_NAME='MOP02';

file_id = hdfsw('open', FILE_NAME, 'rdonly');
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Read data from a data field.
DATAFIELD_NAME='Retrieval Bottom Pressure';
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Detach from the Swath object and close the file.
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Convert 2D data to 1D data.
data=data1(1,:)';

lat = double(lat);
lon = double(lon);
data = double(data);

% Get min/max value of lat and lon for zoomed image.
latlim=[min(min(lat)),max(max(lat))];
lonlim=[min(min(lon)),max(max(lon))];

% Compute data min/max for colorbar.
min_data=min(min(data));
max_data=max(max(data));

% Create the graphics figure.
f=figure('Name', FILE_NAME, 'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin', ...
        'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
        'Frame','on','Grid','on', ...
        'MeridianLabel','on','ParallelLabel','on')


% Plot the dataset value along the flight path.
cm = colormap('Jet');
caxis([min_data max_data]); 
k = size(data);
[count, n] = size(cm);
hold on
for i=1:k
    c = floor(((data(i) - min_data) / (max_data - min_data)) * ...
              (count-1));
    plotm(lat(i), lon(i), 'color', cm(c+1, :));
end
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

h = colorbar('YTick', floor(min_data):40:ceil(max_data));

set (get(h, 'title'), 'string', 'hPa', 'FontSize', 12, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');
  
% Put title.
tstring = {FILE_NAME;DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in PNG if
% your screen is too large.
hold off
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.png']);

exit;

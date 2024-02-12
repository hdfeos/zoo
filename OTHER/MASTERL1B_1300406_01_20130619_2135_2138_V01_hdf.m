%
%   This example code illustrates how to access and visualize MASTER L1B
%  HDF4 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MASTERL1B_1300406_01_20130619_2135_2138_V01_hdf
%
% Tested under: MATLAB R2012a
% Last updated: 2013-12-04

clear

% Open the HDF4 file.
FILE_NAME='MASTERL1B_1300406_01_20130619_2135_2138_V01.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read latitude.
DATAFIELD_NAME='AircraftLatitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate the access to the corresponding data field.
hdfsd('endaccess', sds_id);


% Read longitude.
DATAFIELD_NAME='AircraftLongitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate the access to the corresponding data field.
hdfsd('endaccess', sds_id);


% Read data from a data field.
DATAFIELD_NAME='BlackBody1Temperature';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), ...
                       dimsizes);

% Read units attribute.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read fill value attribute.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Read scale_factor attribute.
scale_factor_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale_factor, status] = hdfsd('readattr',sds_id, scale_factor_index);


% Terminate the access to the corresponding data field.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);


lat = double(lat);
lon = double(lon);
data = double(data);

% Replace the fill value with NaN
data(data==fillvalue) = NaN;

% Apply scale.
data = scale_factor*data;

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
        'MeridianLabel','on','ParallelLabel','on', ...
        'LabelUnits', 'dms', ...
        'MLineLocation', 0.1, 'PLineLocation', 0.1, ...
        'MLabelLocation',lonlim,'PLabelLocation',latlim);

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

h = colorbar('YTick', min_data:0.01:max_data);

set (get(h, 'title'), 'string', units, 'FontSize', 12, ...
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

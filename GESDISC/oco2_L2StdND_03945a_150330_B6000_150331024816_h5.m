%
%   This example code illustrates how to access and visualize GES DISC OCO-2
% Swath HDF5 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r oco2_L2StdND_03945a_150330_B6000_150331024816_h5
%
% Tested under: MATLAB R2014a
% Last updated: 2015-04-01

clear

% Open the HDF5 file.
FILE_NAME='oco2_L2StdND_03945a_150330_B6000_150331024816.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'RetrievalResults/xco2';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='RetrievalGeometry/retrieval_latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='RetrievalGeometry/retrieval_longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

% Get dataspace.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title.
ATTRIBUTE = 'Description';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5S.close (data_space)
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);


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
        'Frame','on','Grid','on', ...
        'MeridianLabel','on','ParallelLabel','on')


% Plot the dataset value along the flight path.
cm = colormap('Jet');
caxis([min_data max_data]); 
k = size(data);
[count, n] = size(cm);
hold on
for i=1:k
    if isnan(data(i))
    else        
        c = floor(((data(i) - min_data) / (max_data - min_data)) * ...
              (count-1));
        plotm(lat(i), lon(i), 'color', cm(c+1, :), 'Marker', 's', ...
              'MarkerSize', 1, 'LineWidth', 2.0);
    end
end
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');
step = (max_data - min_data)  / 10.0;
h = colorbar('YTick', floor(min_data):step:ceil(max_data))
units_str = sprintf('%s', char(units));

% Unit string is quite long. Use ylabel to avoid clutter at the top
% of colorbar.
ylabel(h, units_str)
  
% Put title. 
var_name = sprintf('%s', char(long_name));
tstring = {FILE_NAME;var_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in PNG if
% your screen is too large.
hold off
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.png']);

exit;

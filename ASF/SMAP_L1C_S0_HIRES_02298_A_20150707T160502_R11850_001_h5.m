%
%  This example code illustrates how to access and visualize SMAP
%  L1C S0 HiRes file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%                                   
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r SMAP_L1C_S0_HIRES_02298_A_20150707T160502_R11850_001_h5
%
% Tested under: MATLAB R2015a
% Last updated: 2016-03-09

clear

% Open the HDF5 File.
FILE_NAME = 'SMAP_L1C_S0_HIRES_02298_A_20150707T160502_R11850_001.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Sigma0_Data/cell_sigma0_hh_fore';
data_id = H5D.open(file_id, DATAFIELD_NAME);

Lat_NAME='Sigma0_Data/cell_lat';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='Sigma0_Data/cell_lon';
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the valid_max.
ATTRIBUTE = 'valid_max';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_max = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the valid_min.
ATTRIBUTE = 'valid_min';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_min = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read title attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name=H5A.read (attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Replace the invalid range values with NaN.
data(data < double(valid_min)) = NaN;
data(data > double(valid_max)) = NaN;


% Create a set of level ranges to be used in converting the data to a
% geolocated image that has a color assigned to each range.
levels = linspace(valid_min, valid_max, 10);

% Create a color map.
cmap = jet(length(levels) + 1);

% Set the first entry of colormap as white, which will be used for
% fill value.
cmap(1, :,:) = [1 1 1];

% Convert the data to an geolcated image by setting a color for each level
% range.
Z = data;

% Clamp the min and max values to the level index.
Z(Z < levels(1)) = 1;
Z(Z > levels(end)) = length(levels);

% Assign Z as an indexed image with the index value corresponding to the
% level range.
for k = 1:length(levels) - 1
    Z(data >= levels(k) & data < levels(k+1)) = double(k) ;
end


% Plot the data.
min_data=min(min(data));
max_data=max(max(data));

f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto', ...
    'Colormap', jet(2048));


latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
tightmap
colormap(cmap)
% Note: surfm won't work for SMAP grid.
% surfm(lat, lon, data)
geoshow(lat,lon, uint8(Z), cmap, 'd', 'image');

landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];
geoshow(coast.lat, coast.long, 'Color', 'k')

caxis auto
clevels =  cellstr(num2str(levels'));
clevels = ['missing'; clevels]';

h = lcolorbar(clevels, 'Location', 'horizontal');
unit = 'None';
set(get(h, 'title'), 'string', unit, ...
    'Interpreter', 'none', ...
    'FontSize', 16, 'FontWeight','bold');


% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
name = sprintf('%s', long_name);
plotm(coast.lat,coast.long,'k');

title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

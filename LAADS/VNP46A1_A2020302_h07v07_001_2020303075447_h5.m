%
%  This example code illustrates how to access and visualize LAADS
%  VNP46A1 L3 HDF-EOS5 Grid file in MATLAB.
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r VNP46A1_A2020302_h07v07_001_2020303075447_h5
%
% Tested under: MATLAB R2020a
% Last updated: 2020-11-03

import matlab.io.hdf5.*

% Open the HDF-EOS5 Grid File.
FILE_NAME = 'VNP46A1.A2020302.h07v07.001.2020303075447.h5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read the dataset.
DATAFIELD_NAME = '/HDFEOS/GRIDS/VNP_Grid_DNB/Data Fields/BrightnessTemperature_M12';
data_id = H5D.open(file_id, DATAFIELD_NAME);

data1=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');

% Get dimension sizes.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
% data_dims=fliplr(data_dims');

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read long_name attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read (attr_id, 'H5ML_DEFAULT');

% Read scale_factor attribute.
ATTRIBUTE = 'scale_factor';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
scale = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read add_offset attribute.
ATTRIBUTE = 'add_offset';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
offset = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');


H5D.close (data_id);
H5F.close (file_id);

% Convert the data to double type for plot
data = double(data1);

% Handle fill value.
data(data==fillvalue) = NaN;

% Apply scale factor.
data = data*scale+offset;

% Read 4 grid bounding coordinate values.
x0 = h5readatt(FILE_NAME, '/HDFEOS/GRIDS/VNP_Grid_DNB', 'WestBoundingCoord');
x1 = h5readatt(FILE_NAME, '/HDFEOS/GRIDS/VNP_Grid_DNB', 'EastBoundingCoord');
y0 = h5readatt(FILE_NAME, '/HDFEOS/GRIDS/VNP_Grid_DNB', 'NorthBoundingCoord');
y1 = h5readatt(FILE_NAME, '/HDFEOS/GRIDS/VNP_Grid_DNB', 'SouthBoundingCoord');
xinc = (x1 - x0 ) / data_dims(2);
yinc = (y1 - y0 ) / data_dims(1);

for i = 0:(data_dims(2)-1)
  x_value(i+1) = (i)*(xinc) + x0;
end
for j = 0:(data_dims(1)-1)
  y_value(j+1) = (j)*(yinc) + y0;
end

lon = x_value;
lat = y_value;

% Transpose data to match the lat/lon shape.
data = data';

% Plot the data using surfm and axesm.
f=figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...
         'visible', 'off');

% Create the plot.
cm = colormap('Jet');
min_data=min(min(data));
max_data=max(max(data));
caxis([min_data max_data]);
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')
surfm(lat,lon,data);
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');
tightmap;
% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units1 = sprintf('%s', char(units));
h = colorbar();
% lunits is pretty long so use a small font.
set (get(h, 'title'), 'string', units1, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');
  
name = sprintf('%s', long_name);

% long_name is also long so we use a small font.
title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
   
% References   
% [1] http://www.spatialreference.org/ref/epsg/nsidc-sea-ice-polar-stereographic-north/prettywkt/

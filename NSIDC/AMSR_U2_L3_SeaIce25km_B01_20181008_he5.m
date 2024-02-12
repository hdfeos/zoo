%
%  This example code illustrates how to access and visualize NSIDC
%  AMSR_U2 L3 HDF-EOS5 Grid file in MATLAB.
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
%  $matlab -nosplash -nodesktop -r AMSR_U2_L3_SeaIce25km_B01_20181008_he5
%
% Tested under: MATLAB R2018b
% Last updated: 2019-01-22

import matlab.io.hdf5.*

% Open the HDF-EOS5 Grid File.
FILE_NAME = 'AMSR_U2_L3_SeaIce25km_B01_20181008.he5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read the dataset.
DATAFIELD_NAME = '/HDFEOS/GRIDS/NpPolarGrid25km/Data Fields/SI_25km_NH_89V_DAY';
data_id = H5D.open (file_id, DATAFIELD_NAME);

data1=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
    'H5P_DEFAULT');

% Get dimension sizes.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

H5D.close (data_id);
H5F.close (file_id);

% Convert the data to double type for plot
data = double(data1);

% Handle fill value.
data(data==0) = NaN;

scale = 0.1;

% Apply scale factor.
data = data*scale;

% Units are in meters.
x0 = -3850000;
x1 = 3750000;                  
y0 = 5850000;                   
y1 = -5350000;
xinc = (x1 - x0 ) / data_dims(2);
yinc = (y1 - y0 ) / data_dims(1);

for i = 0:(data_dims(2)-1)
  x_value(i+1) = (i)*(xinc) + x0;
end
for j = 0:(data_dims(1)-1)
  y_value(j+1) = (j)*(yinc) + y0;
end

[x_m, y_m] = meshgrid(x_value, y_value);
mstruct = defaultm('stereo');
clon = -45000000.0 / 1000000.0;
% clat = 70000000.0 / 1000000.0
clat = 90.0;
mstruct.origin = [clat, clon];

   
% See [1] for geoid parameters.
mstruct.geoid = [6378273.0, flat2ecc(1/298.279411123064)];

% Calculate lat/lon using projection parameters.
[lat,lon] = projinv(mstruct, x_m, y_m);
   
% Transpose data to match the lat/lon shape.
data = data';

latlim = [floor(min(min(lat))),ceil(max(max(lat)))];
   
f = figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], 'visible', 'off');
pole=[90 0 0];
axesm('MapProjection','stereo', ...
      'MapLatLimit', latlim, ...
      'Origin', pole ,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
surfm(lat, lon, data);
colormap('Jet');
h = colorbar();
coast = load('coast.mat');         
plotm(coast.lat,coast.long,'k')
title({FILE_NAME; DATAFIELD_NAME}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');
units = 'K';
set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');
saveas(f,[FILE_NAME '.m.png']);
exit;
   
% References   
% [1] http://www.spatialreference.org/ref/epsg/nsidc-sea-ice-polar-stereographic-north/prettywkt/

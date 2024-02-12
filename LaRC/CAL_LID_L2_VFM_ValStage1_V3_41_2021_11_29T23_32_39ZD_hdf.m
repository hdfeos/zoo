%
%  This example code illustrates how to access and visualize LaRC CALIPSO Lidar
% Level 2 Vertical Feature Mask Version 3 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r CAL_LID_L2_VFM_ValStage1_V3_41_2021_11_29T23_32_39ZD_hdf
%
% Tested under: MATLAB R2021a
% Last updated: 2021-12-06

import matlab.io.hdf4.*
  
% Open the HDF4 File.
FILE_NAME = 'CAL_LID_L2_VFM-ValStage1-V3-41.2021-11-29T23-32-39ZD.hdf';
SD_id = sd.start(FILE_NAME, 'rdonly');

% Read data.
datafield_name='Feature_Classification_Flags';
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
% data = sd.readData(sds_id, zeros(1,n), ones(1,n), dimsizes)
data = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lat.
lat_name='Latitude';
sds_index = sd.nameToIndex(SD_id, lat_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lon.
lon_name='Longitude';
sds_index = sd.nameToIndex(SD_id, lon_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% To plot data, you need to fully understand the layout of the 
% Feature_Classification_Flag dataset.
%
% The Feature_Classification_Flag values are stored as a sequence of 5515
%  element arrays (i.e., as an N x 5515 matrix, where N is the number of 
% separate records in the file). In this file, N is 4224.
%
%  Each array represents a 5 km "chunk" of data, 
% and each array element contains the feature classification information for a
%  single range resolution element in the Level 0 lidar data downlinked from 
% the satellite. As shown in the summary below, the vertical and horizontal 
% resolution of the CALIPSO data varies as a function of altitude above mean 
% sea level (see Hunt et al., 2009). 
%
% Here's the summary of number of profiles per 5 km.
% 
% 3 profiles for 20.2km (base) to 30.1km (top) @ 180m
% (index 1-165 / 55 samples per profile)
% 5 profiles for 8.2km (base) to 20.2km (top) @ 60m
% (index 166 - 1165 / 200 samples per profile)
% 15 profiles for -0.5km (base) to 8.2km (top) @ 30m 
% (index 1166 - 5515 / 290 samples per profile)
%
% 3 profiles mean horizontal resolution is 1667m because 3 * 1667m = 5km.
% 55 samples mean vertical resolution is 180m because 55 * 180m = 9.9km  = 
% 30.1km - 20.2km.
%
% 1.1132km equals to 0.01 degree difference.
% 111.32m equals to 0.001 degree difference.
% 
% Thus, we can ignore horizontal resolution for this global plot example.
%
% In summary, profile size determines horizontal resolution and sample size
% determines the vertical resolution.
%
% Each vertical feature mask record is a 16 bit integer.  See [1] for details.
% Bits | Description
% ----------------
% 1-3  | Feature Type
% 4-5  | Feature Type QA
% ...   |...
% 14-16 | Horizontal averaging
%
% In this example, we'll focus only on "Featrue type."
% 
% However, the resolution of the height will be different.
%
% Altitude Lidar data is in "metadta" [2] stored as HDF4 Vdata. 
% Lidar_Data_Altitudes has 583 records it does not match dataset size
% 565(=55+200+290).
% There are 5 below -0.5km and 30 above 30.1km.
%
% Therefore, we cannot not rely on the Vdata for altitude. NCL cannot read
% Vdata either, anyway.
%
% Instead, we should calculate altitude from the data specification.
%
% For each 5515 at a specific lat/lon, we can construct cloud bit vector over 
% altitude.
%
% For example, Feature_Classification_Flags[loc][55] means, 
% Longitude[loc] and altitude = 30.1km.
%
% For another example, Feature_Classification_Flags[loc][56] means, 
% Longitude[loc] + 1667m and altitude = 20.2km.
% 
% There are many possibilites to plot this data.
% Here, we'll pick a specific altitude and plot Feature Type on
% 2-D map.
%
% Subset data at 2500m (= -0.5km + 30m * 100) altitude. 

alt_index = 1266;
data = squeeze(data(alt_index,:));
data = data';
data = bitand(data, 7);
lat = lat';
lon = lon';


% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');


% Create a custom color map for 8 different Feature Type key value.
cmap=[                       %  Key            R   G   B
      [0.00 0.00 0.00];  ... %  0=invalid     [000,000,000]    
      [0.00 0.00 1.00];  ... %  1=clear air   [000,000,255]
      [1.00 1.00 0.00];  ... %  2=cloud       [255,255,000]
      [0.00 1.00 0.00];  ... %  3=aerosol     [000,255,000]
      [1.00 0.00 0.00];  ... %  4=strato. feat[255,000,000]
      [0.78 0.39 1.00];  ... %  5=surface     [200,100,255]                    
      [0.39 0.20 1.00];  ... %  6=subsurface  [100,50,255]
      [0.50 0.50 0.50];  ... %  7=no signal   [100,50,255]                    
     ];     

colormap(cmap);
caxis([0 7]); 

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')


[count, n] = size(cmap);
hold on
k = size(data);
for i=1:k
     plotm(lat(i), lon(i), 'color', cmap(data(i)+1, :), ...
           'Marker', 's', 'MarkerSize', 2.0); % s means square
end

geoshow(coast.lat, coast.long, 'Color', 'k');
tightmap;

% Put colorbar.
y = [0, 1, 2, 3, 4, 5, 6, 7];
h = colorbar('YTickLabel', {'invalid', 'clear', 'cloud', 'aerosol', ...
                    'strato', 'surface', 'subsurf', 'no signal'}, 'YTick', y);

tstring = {FILE_NAME;'Feature Type at Altitude = 2500m'};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


hold off;
saveas(f, [FILE_NAME '.m.png']);
exit;

% References
%
% [1] http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php
% [2] http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php#heading03


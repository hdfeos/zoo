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
%  #matlab -nosplash -nodesktop -r CAL_LID_L2_VFM_ValStage1_V3_02_2011_12_31T23_18_11ZD_hdf_v
%
% Tested under: MATLAB R2012a
% Last updated: 2014-2-14
clear

% Open the HDF4 File.
FILE_NAME = 'CAL_LID_L2_VFM-ValStage1-V3-02.2011-12-31T23-18-11ZD.hdf';
SD_id = hdfsd('start', FILE_NAME, 'rdonly');

% Read data.
datafield_name='Feature_Classification_Flags';
sds_index = hdfsd('nametoindex', SD_id, datafield_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes, data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Read lat.
lat_name='Latitude';
sds_index = hdfsd('nametoindex', SD_id, lat_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Read lon.
lon_name='Longitude';
sds_index = hdfsd('nametoindex', SD_id, lon_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

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
% Therefore, we cannot not rely on the Vdata for altitude.
%   
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
%
% In this example, we'll focus only on "Cloud" from "Featrue type."
%
% There are many possibilites to plot this data.
%
% Here, we'll subset -05km to 8.2km (e.g., 1166:5515) 
% over latitude approx. 40N to 62N (e.g., 3501:4000)
% and plot altitude vs. latitude.
data = data';
lat = lat';
lon = lon';

% Select the 1-3 bits for Feature Type data. 
data = bitand(data, 7);

% Subset latitude values for the region of interest (40N to 62N).
lat = lat(3501:4000);
dim = size(lat, 1);

% You can visualize other blocks by changing subset parameters.
%  data2d = squeeze(data(3501:4000, 1:165))    % 20.2km to 30.1km
%  data2d = squeeze(data(3501:4000, 166:1165)) %  8.2km to 20.2km
data2d = squeeze(data(3501:4000, 1166:5515));   % -0.5km to 8.2km
data3d = reshape(data2d, dim, 290, 15);
data = squeeze(data3d(:,:,1));

% Focus on cloud (=2) data only.
data(data > 2) = 1;
data(data < 2) = 1;

% Generate altitude data according to file specification [1].
% You can visualize other blocks by changing subset parameters.
% 20.2km to 30.1km
%for i=0:54
% altitude(i+1) = 20.2 + i*0.18;
%end 

%  8.2km to 20.2km
%for i=0:199
% altitude(i+1) = 8.2 + i*0.06;
%end 

% -0.5km to 8.2km
for i=0:289
 altitude(i+1) = -0.5 + i*0.03;
end 

% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');


% Create a custom color map for 2 different Feature Type key values.
cmap=[                       %  Key            R   G   B
      [0.00 0.00 1.00];  ... %  1=not cloud   [000,000,255]
      [1.00 1.00 1.00];  ... %  2=cloud       [255,255,255]
     ];     

colormap(cmap);
caxis([1 2]); 

contourf(lat, altitude, rot90(data, 1));


% Set axis labels.
xlabel('Latitude (degrees north)'); 
ylabel('Altitude (km)');


% Put colorbar.
y = [1, 2];
h = colorbar('YTickLabel', {'Others', 'Cloud'}, 'YTick', y);

tstring = {FILE_NAME;['Feature Type  (Bits 1-3) in' ...
                    ' Feature Classification Flag']};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

hold off;
saveas(f, [FILE_NAME '.v.m.png']);
exit;

% References
%
% [1] http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php
% [2] http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php#heading03


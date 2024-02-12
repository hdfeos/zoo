%
% This example code illustrates how to access and visualize LAADS
% VNP09_NRT v1 HDF-EOS2 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r VNP09_NRT_A2018064_0524_001_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-03-07


clear

import matlab.io.hdfeos.*
import matlab.io.hdf4.*
import matlab.io.hdf5.*

% Read data field
FILE_NAME='VNP09_NRT.A2018064.0524.001.hdf';

file_id = sw.open(FILE_NAME, 'rdonly');

% Open swath.
SWATH_NAME='SurfReflect_VNP';
swath_id = sw.attach(file_id, SWATH_NAME);

% Read the dataset.
DATAFIELD_NAME='375m Surface Reflectance Band I1';
% data_raw = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Detach Swath object.
sw.detach(swath_id);

% Close file.
sw.close(file_id);


% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read _FillValue from data field.
fillvalue_index = sd.findAttr(sds_id, 'FILL_VALUES');
fillvalue = sd.readAttr(sds_id, fillvalue_index)

% Read scale_factor from the data field.
scale_index = sd.findAttr(sds_id, 'Scale');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale(1));

% Read add_offset from the data field.
offset_index = sd.findAttr(sds_id, 'Offset');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset(1));

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Open geo-location file from [1].
GEO_FILE_NAME = 'VNP03IMG_NRT.A2018064.0524.001.nc';
file_id = H5F.open(GEO_FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
Lat_NAME='geolocation_data/latitude';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='geolocation_data/longitude';
lon_id=H5D.open(file_id, Lon_NAME);

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

H5D.close(lat_id);
H5D.close(lon_id);
H5F.close(file_id);

% Replace the filled value with NaN.
dataf = double(data);
dataf(data==-28672) = NaN;
dataf(data==-994) = NaN;
dataf(data==-993) = NaN;
dataf(data==-992) = NaN;
dataf(data==-990) = NaN;
dataf(data==-100) = NaN;

% Multiply scale and add offset, the equation is scale *(data-offset).
dataf = scale*(dataf-offset);

% Set the map parameters.
[xdimsize, ydimsize] = size(data);
lon_c = lon(xdimsize/2, ydimsize/2);
lat_c = lat(xdimsize/2, ydimsize/2);
latlim=ceil(max(max(lat))) - floor(min(min(lat)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% Use colormap.
colormap('Jet');

% FlatLimit will give us a zoom-in effect in Ortho projection.
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'FLatLimit', [-Inf, latlim], ...       
       'origin', [lat_c, lon_c])
mlabel('equator')
plabel(0); 
plabel('fontweight','bold')

% Plot data. 
lat = lat(:)';
lon = lon(:)';
dataf = dataf(:)';

% Subset points to avoid system crashing due to memory.
% scatterm(lat, lon, 1, data);
step = 10;
scatterm(lat(1:step:end), lon(1:step:end), 1.0, dataf(1:step:end));


% Load the coastlines data file.
coast = load('coast.mat');

% Plot coastlines in color black ('k').
plotm(coast.lat,coast.long,'k')

h=colorbar();
% See [2].
units = 'Reflection';
set (get(h, 'title'), 'string', units);

% Set the title using long_name.
title({FILE_NAME; DATAFIELD_NAME}, ...
      'interpreter', 'none', 'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

% References
%
% [1] ftp://nrt3.modaps.eosdis.nasa.gov/allData/5001/VNP03IMG_NRT/
% [2] https://viirsland.gsfc.nasa.gov/PDF/VIIRS_Surf_Refl_UserGuide_v1.3.pdf

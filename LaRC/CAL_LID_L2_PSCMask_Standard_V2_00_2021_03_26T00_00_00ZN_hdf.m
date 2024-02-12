%  This example code illustrates how to access and visualize LaRC CALIPSO LIDAR
% Level 2 PCSMask HDF4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r CAL_LID_L2_PSCMask_Standard_V2_00_2021_03_26T00_00_00ZN_hdf
%
% Tested under: MATLAB R2021a
% Last updated: 2022-10-04

import matlab.io.hdf4.*

% Open the HDF4 File.
FILE_NAME = 'CAL_LID_L2_PSCMask-Standard-V2-00.2021-03-26T00-00-00ZN.hdf';
SD_id = sd.start(FILE_NAME, 'rdonly');

% Read data.
datafield_name='PSC_Feature_Mask';
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);
data = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read _FillValue from data field.
fillvalue_index = sd.findAttr(sds_id, 'fillvalue ');
fillvalue = str2double(sd.readAttr(sds_id, fillvalue_index));

% Read units attribute from data field.
units_index = sd.findAttr(sds_id, 'units ');
units = sd.readAttr(sds_id, units_index);

% Read lat.
lat_name='Latitude';
sds_index = sd.nameToIndex(SD_id, lat_name);
sds_id = sd.select(SD_id, sds_index);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lon.
lon_name='Longitude';
sds_index = sd.nameToIndex(SD_id, lon_name);
sds_id = sd.select(SD_id, sds_index);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read altitude.
alt_name='Altitude';
sds_index = sd.nameToIndex(SD_id, alt_name);
sds_id = sd.select(SD_id, sds_index);
alt = sd.readData(sds_id);

units_index = sd.findAttr(sds_id, 'units ');
units_alt = sd.readAttr(sds_id, units_index);

sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert data to double type for plot.
data=double(data);
alt=double(alt);
lat=double(lat);
lon=double(lon);

% Subset data at a certain altitude.
data = data(121, :);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Create a figure to plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');
axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on');
scatterm(lat, lon, 1, data(:));
colormap('Jet');
h = colorbar();

coast = load('coastlines.mat');
plotm(coast.coastlat,coast.coastlon,'k')

tstring = {FILE_NAME;[datafield_name, ' at Altitude = ', num2str(alt(121)), ...
                    ' (', units_alt, ')']};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
set(get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


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
%  $matlab -nosplash -nodesktop -r CAL_LID_L2_PSCMask_Standard_V2_00_2021_03_26T00_00_00ZN_hdf_v
%
% Tested under: MATLAB R2021a
% Last updated: 2022-09-26

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

% Read altitude.
alt_name='Altitude';
sds_index = sd.nameToIndex(SD_id, alt_name);
sds_id = sd.select(SD_id, sds_index);
alt = sd.readData(sds_id);
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert data to double type for plot.
data=double(data);
alt=double(alt);
lat=double(lat);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Subset latitude values that decrease monotonically.
s = 1;
e = 567;
lat = lat(s:e);
data = data(:,s:e);

% Plot over altitude = Y-axis / latitude = X-axis.
% data = data';


% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');
colormap('Jet');

% contourf(lat, alt, rot90(data, 1));
contourf(lat, alt, data);

% Set axis labels.
xlabel('Latitude (degrees north)'); 
ylabel('Altitude (km)');

% Put colorbar.
h = colorbar();

tstring = {FILE_NAME;[datafield_name, ' (', units, ')']};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

hold off;
saveas(f, [FILE_NAME '.v.m.png']);
exit;


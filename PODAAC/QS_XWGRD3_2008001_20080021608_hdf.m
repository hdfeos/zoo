%
%  This example code illustrates how to access and visualize PO.DAAC
%  QuikSCAT Grid HDF4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r QS_XWGRD3_2008001_20080021608_hdf
%
% Tested under: MATLAB R2019b
% Last updated: 2019-10-18

import matlab.io.hdf4.*

% Open the HDF4 file.
FILE_NAME='QS_XWGRD3_2008001.20080021608.hdf';
SD_id = sd.start(FILE_NAME, 'rdonly');

% Read data from the data field.
DATAFIELD_NAME='des_avg_wind_speed';
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);
data = sd.readData(sds_id);

% Read long name attribute from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read units attribute from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale factor from the data field.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale);

% Read offset from the data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Transpose the data to match the map projection.
data=data';

% Calculate lat and lon.
[latdim, londim] = size(data);
for i=1:latdim
    lat(i)=(180./latdim)*(i-1+0.5)-90;
end
for j=1:londim
    lon(j)=(360./londim)*(j-1+0.5);
end

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the fill value with NaN.
data(data == 0) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Plot the data using surfm(or contourfm) and axesm.
f=figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...
         'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south')
coast = load('coast.mat');

% surfm is faster than contourfm.
%contourfm(lat,lon,data);
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')
tightmap;

% Put colorbar.
colormap('Jet');
h = colorbar();

% Set unit's title.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;



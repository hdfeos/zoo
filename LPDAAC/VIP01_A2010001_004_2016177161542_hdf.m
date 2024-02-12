%
%  This example code illustrates how to access and visualize 
%  LP DAAC MEaSUREs VIP01 version 4 HDF-EOS2 Grid file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r VIP01_A2010001_004_2016177161542_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-05-07

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Open the HDF-EOS2 Grid File.
FILE_NAME='VIP01.A2010001.004.2016177161542.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='VIP_CMG_GRID';
grid_id = gd.attach(file_id, GRID_NAME);

% Read the dataset.
DATAFIELD_NAME='CMG 0.05 Deg Daily NDVI';
data = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
data=data';

% Read grid information.
[xdimsize, ydimsize, upleft,lowright] = gd.gridInfo(grid_id);

% We need to re-adjust the limits of latitude and longitude. HDF-EOS
% is using DMS(DDDMMMSSS.SS) format to represent degrees.
% So to calculate the lat and lon in degree, one needs to convert
% minutes and seconds into degrees. 

% The following is the detailed description on how to calculate the
% latitude and longitude range based on lowright and upleft.
% One should observe the fact that 1 minute is 60 seconds and 1
% degree is 60 minutes. 

% First, calculate the difference of .SS between lowright and upleft:
lowright_ss= lowright*100-floor(lowright)*100;
upleft_ss = upleft*100-floor(upleft)*100;
dss = lowright_ss - upleft_ss;

% Second, calculate the difference of SSS between lowright and upleft:
lowright_s = mod(floor(lowright),1000);
upleft_s = mod(floor(upleft),1000);

ds =lowright_s - upleft_s +dss/100;

% Third, calculate the difference of MMM between lowright and upleft:
lowright_m = mod(floor(lowright/1000),1000);
upleft_m = mod(floor(upleft/1000),1000);

dm = lowright_m-upleft_m +ds/60;

% Fourth, calculate the difference of DDD between lowright and upleft:
lowright_d = floor(lowright/1000000);
upleft_d = floor(upleft/1000000);
dd = lowright_d-upleft_d+dm/60;

lat_limit = dd(2);
lon_limit = dd(1);

% Fifth, calculate the grid space interval between two adjacent points.
scaleX = lon_limit/xdimsize;
scaleY = lat_limit/ydimsize;

% By default, HDFE_CENTER is assumed for the offset value, which
% assigns 0.5 to both offsetX and offsetY.
offsetX = 0.5;
offsetY = 0.5;

% Finally, since this grid is using geographic projection, the latitude and
% longitude value will be calculated based on the formula:
% (i+offsetX)*scaleX+leftX  for longitude and 
% (i+offsetY)*scaleY+leftY for latitude.
for i = 0:(xdimsize-1)
  lon_value(i+1) = (i+offsetX)*(scaleX) + upleft_d(1);
end

for j = 0:(ydimsize-1)
  lat_value(j+1) = (j+offsetY)*(scaleY) + upleft_d(2);
end

% Convert the data to double type for plot.
lon=double(lon_value);
lat=double(lat_value);

% Detach Grid object.
gd.detach(grid_id);

% Close file.
gd.close(file_id);

% Reading attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read _FillValue from data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read valid_range from the data field.
range_index = sd.findAttr(sds_id, 'valid_range');
valid_range = sd.readAttr(sds_id, range_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor from the data field.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale);

% Read the long name attribute.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Replace the fill value with NaN
data(data==fillvalue) = NaN;

% Parse the valid_range string attribute.
[min_str, max_str] = strtok(valid_range, ',');
max_str = strtok(max_str, ',');

valid_min = double(str2num(min_str));
valid_max = double(str2num(max_str));

% Replace invalid range values with NaN.
data(data > valid_max) = NaN;
data(data < valid_min) = NaN;

% Divide it with  scale.
data = data / double(scale);

% Plot the data using surfm and axesm.
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize', 8)

surfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');

h = colorbar();
set (get(h, 'title'), 'string', units)
tightmap;

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');


saveas(f, [FILE_NAME  '.m.png']);
exit;

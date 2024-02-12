%
%  This example code illustrates how to access and visualize MEaSUREs VIP
% HDF-EOS2 Grid file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2012a
% Last updated: 2013-1-15

clear

%Open the HDF-EOS2 Grid File.
FILE_NAME='VIP01P4.A2010001.002.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
grid_NAME='VIP_CMG_GRID';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='CMG 0.05 Deg NDVI';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data=data1;
data=double(data);

% Transpose the data to match the map projection.
data=data';

% Get information about the spatial extents of the grid..
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

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

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Reading attributes from the data field.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='CMG 0.05 Deg NDVI';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);

% Read fill value.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Read valid_range.
valid_range_index = hdfsd('findattr', sds_id, 'valid_range');
[valid_range, status] = hdfsd('readattr',sds_id, valid_range_index);

% Read units.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale_factor.
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Read long_name.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

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

f=figure('Name', FILE_NAME, 'visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on')

surfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);

set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');

scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f, [FILE_NAME  '.m.jpg']);
exit

%
%   This example code illustrates how to access and visualize LaRC MISR
%   AM1 CGAL Grid HDF-EOS2 file in MATLAB.
%
%   If you have any questions, suggestions, comments  on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r MISR_AM1_CGAL_2017_F06_0024_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-08-13

import matlab.io.hdfeos.*

% Open the HDF-EOS2 grid file.
FILE_NAME='MISR_AM1_CGAL_2017_F06_0024.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='AlbedoAverage_1_degree';
grid_id = gd.attach(file_id, GRID_NAME);
DATAFIELD_NAME='Local albedo average - 1 deg';
[data1, fail] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);


% Get information about the spatial extents of the grid.
[xdimsize, ydimsize, upleft, lowright] = gd.gridInfo(grid_id);

% Read fillvalue from the data.
[fillvalue] = gd.getFillValue(grid_id, DATAFIELD_NAME);

% Detach from the grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

% We need to readjust the limits of latitude and longitude. 
% HDF-EOS is using DMS(DDDMMMSSS.SS) format to represent degrees.
% So to calculate the lat and lon in degree, one needs to convert
% minutes and seconds into degrees. 

% The following is the detailed description on how to calculate the
% latitude and longitude range based on lowright and upleft.
% One should observe the fact that 1 minute is 60 seconds and
% 1 degree is 60 minutes. 

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

% Finally, calculate the difference of DDD between lowright and upleft:
lowright_d = floor(lowright/1000000);
upleft_d = floor(upleft/1000000);
dd = lowright_d-upleft_d+dm/60;

lat_limit = dd(2);
lon_limit = dd(1);

% We need to calculate the grid space interval between two adjacent points.
scaleX = lon_limit/xdimsize;
scaleY = lat_limit/ydimsize;

% By default, HDFE_CENTER is assumed for the offset value, which
% assigns 0.5 to both offsetX and offsetY.
offsetX = 0.5;
offsetY = 0.5;

% Since this grid is using geographic projection, the latitude and
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

% Convert 3-D data to 2-D data.
data=squeeze(data1(4,:,:));

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
data=data';

% Replace the fill value with NaN
data(data == fillvalue) = NaN;

% The Local albedo average - 1 deg should be less than 1.
data(data > 1) = NaN;

% Create figure.
f = figure('Name',FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');

% Plot the data using axesm, surfm and plotm if mapping toolbox exists.
coast = load('coast.mat');
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];


axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south')    
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')
tightmap;

h = colorbar();

% Albedo doesn't have a unit according to the specification [1].
units = 'No Unit';
set(get(h, 'title'), 'string', units);

tstring = {FILE_NAME; [DATAFIELD_NAME ' at Band=3'] };
title(tstring, ...
      'interpreter', 'none', 'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
% References
%
% [1] https://asdc.larc.nasa.gov/documents/misr/DPS_v50_RevS.pdf
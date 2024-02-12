%  This example code illustrates how to access and visualize
% NSIDC MODIS Grid file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
%  HDF/HDF-EOS data product that is not listed in the HDF-EOS
%  Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the 
% HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Define file name, grid name, and data field.
FILE_NAME='MOD10C1.A2005018.005.2007349093349.hdf';
GRID_NAME='MOD_CMG_Snow_5km';
DATAFIELD_NAME='Day_CMG_Snow_Cover';

% Open the HDF-EOS2 Grid file.
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = hdfgd('attach', file_id, GRID_NAME);
[data, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Get information about the spatial extents of the grid.
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Convert the data to double type for plot.
data=double(data);

% We need to readjust the limits of latitude and longitude. 
% HDF-EOS is using DMS(DDDMMMSSS.SS) format to represent degrees.
% So to calculate the lat and lon in degree, 
% one needs to convert minutes and seconds into degrees. 

% The following is the detailed description on how to calculate
% the latitude and longitude range based on lowright and upleft.
% One should observe the fact that 1 minute is 60 seconds and 1
% degree is 60 minutes. 

% First, calculate the difference of .SS between lowright and upleft.
lowright_ss= lowright*100-floor(lowright)*100;
upleft_ss = upleft*100-floor(upleft)*100;
dss = lowright_ss - upleft_ss;

% Then, calculate the difference of SSS between lowright and upleft.
lowright_s = mod(floor(lowright),1000);
upleft_s = mod(floor(upleft),1000);

ds =lowright_s - upleft_s +dss/100;

% Then, calculate the difference of MMM between lowright and upleft.
lowright_m = mod(floor(lowright/1000),1000);
upleft_m = mod(floor(upleft/1000),1000);

dm = lowright_m-upleft_m +ds/60;

% Then, calculate the difference of DDD between lowright and upleft.
lowright_d = floor(lowright/1000000);
upleft_d = floor(upleft/1000000);
dd = lowright_d-upleft_d+dm/60;

lat_limit = dd(2);
lon_limit = dd(1);


% We need to calculate the grid space interval between two adjacent points.
scaleX = lon_limit/xdimsize;
scaleY = lat_limit/ydimsize;

% By default HDFE_CENTER is assumed for the offset value, 
% which assigns 0.5 to both offsetX and offsetY.
offsetX = 0.5;
offsetY = 0.5;

% Since this grid is using geographic projection, 
% the latitude and longitude value will be calculated based on the formula:
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


% To ensure that the contour overlays with the world map correctly, 
% the fast changing dimension of the plotted data field(rrland) 
% must be the same size as the geo-location dimension specified by
% the first argument of the contour function. 
% In our case, the first argument represents longitude. 
% the data field needs to be transposed.
data=transpose(data);


% Read fill value from a data field.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Day_CMG_Snow_Cover';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% The following will return unique key values used in the dataset.
z = unique(data);

% To get a similar image to NSIDC browse image [1], 
% construct a color table based on the following assignment:
%
% Key      R  G   B    Name
% ==========================
%  0%     0   100 0    dark green
%  1-99%  127 127 127  grey
%  100%   255 255 255  white
%  107    255 176 255  pink  
%  111    0   0   0    black
%  250    100 200 255
%  253    255 0   255  magenta
%  254    0   0   205  medium blue
%  255    138 42  226  blue violet
%
%  Please note that 253 is not used in this data set as you can verify it
%  by evaluating z in MATLAB Command Window.
%
%  We added two more (0% and 1-99%) entries for ice coverage to get better
%  image.


% Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

f = figure('Name', ...
           'MOD10C1.A2005018.005.2007349093349_Day_CMG_Snow_Cover',...
           'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');


% Here is the color map 
cmap=[[0.00 1.00 0.00];  ... %   0% dark green
      [0.50 0.50 0.50];  ... %   1-99% grey
      [1.00 1.00 1.00];  ... %   100% white
      [1.00 0.69 1.00];  ... %   107 pink 
      [0.00 0.00 0.00];  ... %   111 black
      [0.39 0.78 1.00];  ... %   250
      [0.00 0.00 0.80];  ... %   254
      [0.54 0.16 0.87]]; ... %   255
colormap(cmap);

% Put 1%-99% data under one grey label.
data((data > 0) & (data < 100)) = 99;

% Construct a discrete data for plot.
z = unique(data);
k = size(z);

% Create an array for tick label.
y = zeros(k, 'double');

% There are k different boxes in the colorbar 
% and the value starts from 1 to m.
% Thus, we should increment by (k-1)/k to position
% labels properly starting form ((k-1)/k)/2.
x = 1 + ((k-1)/k)/2;

for m = 1:k
    y(m) = x; 
    data(data == z(m)) = double(m);
    x = x+(k-1)/k;    
end

surfacem(lat,lon,data);

caxis([1 m]); 
cb = colorbar('YTickLabel',...
         {'0% snow', '1-99% snow', '100% snow', 'lake ice', 'night', ...
          'cloud obscured water', 'water mask', 'fill'}, 'YTick', y);

plotm(coast.lat,coast.long,'k')

title({FILE_NAME;...
       DATAFIELD_NAME}, ...
      'FontSize',16,'FontWeight','bold', 'Interpreter', 'none');

% For off-screen rendering, make the figure the same size as the X display.
scrsz = get(0,'ScreenSize');
if ishghandle(f)
    set(f,'position',scrsz,'PaperPositionMode','auto');

    saveas(f, ...
           'MOD10C1.A2005018.005.2007349093349_Day_CMG_Snow_Cover.m.jpg');
end

% Reference
%
% [1] http://nsidc.org/data/modis/images/cmg_browse/2001/Oct/MOD10C1.A2001274.004.2003155025155.png

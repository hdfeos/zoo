% This example code illustrates how to access and visualize NSIDC AMSR Grid
% file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% File source:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
%	AMSR_E_L3_DailyLand_V06_20050118.hdf
% Data Description:
% http://nsidc.org/data/docs/daac/ae_land3_l3_soil_moisture/data.html

clear
% Identify the HDF-EOS2 Grid File
FILE_NAME='AMSR_E_L3_DailyLand_V06_20050118.hdf';
% open the file using the HDF_GD interface
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Identify the Data Grid
GRID_NAME='Descending_Land_Grid';
% Attech to the Data Grid via the HDF_GD interface
grid_id = hdfgd('attach', file_id, GRID_NAME);

% Identify the data field
DATAFIELD_NAME='D_TB06.9V (Res 1)';

%===================================%
% Read the Data from the Data Field %
%===================================%
[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
% DataFieldName="D_TB06.9V (Res 1)"; DataType=DFNT_INT16

% Convert M-D data to 2-D data
data=data1;

% Convert the INT16 (short) data to double type for plot
data=double(data);

% Transpose the data to match the map projection
data=data';

% Get dimensional paramaters for the grid from the HDF_GD interface
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid Object
hdfgd('detach', grid_id);
% Close the HDF_GD interface to the File
hdfgd('close', file_id);

% The file contains CEA projection
% We compute lat and lon geolocation coordinates externally using
% the EOS2 Dumper -- See: http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load('lat_AMSR_E_L3_DL_TB06_9V_Res_1.output');
lon1D = load('lon_AMSR_E_L3_DL_TB06_9V_Res_1.output');

% Since it's CEA projection, the output lat and lon are all 1D data.

lat = lat1D;
lon = lon1D;

clear lat1D lon1D;

% transpose row matrix to column matrix
lat = lat';
lon = lon';

% initialize the HDF_SD interface to the data file
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='D_TB06.9V (Res 1)';

% Read attributes from the data field
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Read the filledValue attribute value from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'units');
% Attribute 'units' is not found -- returns -1
[units, status] = hdfsd('readattr',sds_id, units_index);
% string units is empty and no error is thrown

% from data document:
% http://nsidc.org/data/docs/daac/ae_land3_l3_soil_moisture/data.html
% Level-2A 6.9 GHz data were resampled to Degrees Kelvin
units='K';
% There is no scale factor in the HDF file -- from the data document
% "Multiply data values by 0.1 to obtain units in K."
scale=0.1;

% Terminate access to the Scientific Data Set (SDS)
hdfsd('endaccess', sds_id);
% Close the HDF_SD interface to the File
hdfsd('end', SD_id);

% Replace the filled value with IEEE NaN
data(data==fillvalue) = NaN;

% apply the scale factor to obtain units in K.
data = scale*data;

% Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle=figure('Name', ...
                     'AMSR_E_L3_DailyLand_V06_20050118_D_TB06.9V_Res_1', ...
                     'visible','on');
% if 'visible'->'on', figure_handle may be undefined,
% depending on user interaction

whitebg('w');
% set the map parameters
axesm('MapProjection','eqacylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south');

% load the global coastlines graphics from a matlab file
coast = load('coast.mat');

% Surfacem() is faster than Contourfm()
surfacem(lat,lon,data);
% Contourfm('LineStyle','none') produces an equivalent plot
% contourfm(lat,lon,data, 'LineStyle','none');

% load the Matlab default CFD rainbow color map
colormap('Jet');

% set the Y color axis for the colorbar
caxis([min_data max_data]); 
% draw the colorbar
cbar_handle=colorbar('YTick', min_data:20:max_data);
set (get(cbar_handle, 'title'), 'string', strcat('UNITS: ',units));

% draw the coastlines in color black ('k')
plotm(coast.lat,coast.long,'k');

% draw the plot title
title('AMSR\_E\_L3\_DailyLand\_V06\_20050118\_D\_TB06.9V\_Res\_1', ...
      'FontSize',16,'FontWeight','bold');

% if off-screen rendering, make the figure the same size as the X display
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

  saveas(figure_handle, ...
  'AMSR_E_L3_DailyLand_V06_20050118_D_TB06.9V_Res_1_matlab.jpg');
end


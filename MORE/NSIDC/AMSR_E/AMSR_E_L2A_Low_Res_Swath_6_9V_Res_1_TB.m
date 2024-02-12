% This example code illustrates how to access and visualize NSIDC_AMSR Swath
% file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% File Source:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
%	AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D.hdf
% Data Description Document:
% http://nsidc.org/data/docs/daac/ae_l2a_tbs/data.html

clear
% Identify the HDF-EOS2 Swath Data File
FILE_NAME='AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D.hdf';
% Identify the HDF-EOS2 Data Swath
SWATH_NAME='Low_Res_Swath';

% Open the HDF_SW interface to the HDF-EOS2 File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Attach to the swath via the HDF_SW interface 
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Identify the Data Field
DATAFIELD_NAME='6.9V_Res.1_TB';

% Read Data from the Data Field via the HDF_SW interface
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
% Type: Int16 (short)
% read the swath geolocation coordinates for the swath
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);


% Detach from the Swath Object
hdfsw('detach', swath_id);
% close the HDF_SW interface to the file
hdfsw('close', file_id);

% open the HDF_SD interface to the file
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='6.9V_Res.1_TB';

% Read attributes from the data field via the HDF_SD interface
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
% select the data field
sds_id = hdfsd('select',SD_id, sds_index);

% Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'UNIT');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'SCALE FACTOR');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'OFFSET');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

% assert the scale and offset have type double
offset = double(offset);
scale = double(scale);

% Terminate access to the Scientific Data Set
hdfsd('endaccess', sds_id);
% Closing the HDF_SD interface to the File
hdfsd('end', SD_id);

% Convert M-D data to 2-D data
data=data1;

% Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

% Replacing the filled value with NaN
data(data==-32768) = NaN;

% From the data description document
% Tb (kelvin) = (stored data value * 0.01) + 327.68 
data = data*scale + offset ;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle=figure('Name', ...
      'AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D_6.9V_Res.1_TB', ...
      'visible','on');
% if 'visible'->'on', figure_handle may be undefined,
% depending on user interaction

whitebg('w');
% set the map parameters
axesm('MapProjection','eqdcylin','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south');

% load the global coastlines graphics from a matlab file
coast = load('coast.mat');

% Surfacem() is faster than Contourfm()
surfacem(lat,lon,data);
% Contourfm( ..., 'LineStyle','none') produces an equivalent plot
% contourfm(lat, lon, data, 'LineStyle','none');

% load the Matlab default CFD rainbow color map
colormap('Jet');

% set the Y color axis range for the colorbar
caxis([min_data max_data]); 
% draw the colorbar
cbar_handle=colorbar('YTick', min_data:20:max_data);
% set colorbar title to units
set (get(cbar_handle, 'title'), 'string', strcat('UNITS: ',units));

% draw the coastlines in color black ('k')
plotm(coast.lat,coast.long,'k')

title('AMSR\_E\_L2A\_BrightnessTemperatures\_V10\_200501180027\_D\_6.9V\_Res.1\_TB', ...
      'FontSize',16,'FontWeight','bold');

% if off-screen rendering, make the figure the same size as the X display
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
   set(figure_handle,'position',scrsz,'PaperPositionMode','auto');
  saveas(figure_handle, ...
  'AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D_6.9V_Res.1_TB.m.jpg');
end


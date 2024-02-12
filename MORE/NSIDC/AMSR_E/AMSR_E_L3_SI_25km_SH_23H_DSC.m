% This example code illustrates how to access and visualize NSIDC_AMSR Grid
% file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS
% Forum (http://hdfeos.org/forums).

% File Source:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
%	AMSR_E_L3_SeaIce25km_V11_20050118.hdf
% Data description document:
% http://nsidc.org/data/docs/daac/ae_si25_25km_seaice/data.html

clear
% Identify the HDF-EOS2 Grid File
FILE_NAME='AMSR_E_L3_SeaIce25km_V11_20050118.hdf';
% Open the HDF_GD interface to the HDF-EOS2 File
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Identify the Data Grid
GRID_NAME='SpPolarGrid25km';
% Attach to the Data Grid via the HDF_GD interface
grid_id = hdfgd('attach', file_id, GRID_NAME);

% Identify the Data Field
DATAFIELD_NAME='SI_25km_SH_23H_DSC';

%====================================%
% Read the Data from  the Data Field %
%====================================%
[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
% 23.8 GHz horizontal, daily average ascending Tbs
% Valid range: approximately 50 to 300 K; DataType=DFNT_INT16

% Convert M-D data to 2-D data
data=data1;

% Convert the data to double type for plot
data=double(data);

% Transpose the data to match the map projection
data=data';

% get the Grid info from the HDF_GD interface
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid Object
hdfgd('detach', grid_id);
% Closing the HDF_GD interface to the File
hdfgd('close', file_id);

% The file contains Polar Stereographic (GCTP_PS) projection.
% We generate geolocation coordinates externally using the EOS2 Dumper
% For information on how to obtain the lat/lon data,
% check this URL http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load('lat_AMSR_E_L3_SeaIce25km_V11_20050118_SpPolarGrid25km.output');
lon1D = load('lon_AMSR_E_L3_SeaIce25km_V11_20050118_SpPolarGrid25km.output');

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

% initialize the HDF_SD interface to the data file
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
% select the Data Field via the HDF_SD interface 
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);

fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
% fillvalue_index = -1 -- not found

% from data document:
% http://nsidc.org/data/docs/daac/ae_si25_25km_seaice/data.html
% 23.8 GHz horizontal, daily average descending Tbs
% 'Multiply data values by 0.1 to obtain units in K'
units='K';
scale=0.1;

% Terminate access to the Scientific Data Set (SDS)
hdfsd('endaccess', sds_id);
% Close the HDF_SD interface to the File
hdfsd('end', SD_id);

% Replace the filled value with NaN
data(data==0) = NaN;

% scale the data by 0.1 to obtain units in K
data = data * scale;

% Plot the data using contourfm and axesm
pole=[-90 0 0];
latlim=[floor(min(min(lat))),ceil(max(max(lat)))]
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))]
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle=figure('Name', ...
                     'AMSR_E_L3_SeaIce25km_V11_20050118_SI_25km_SH_23H_DSC', ...
                     'visible','on');
% if 'visible'->'on', figure_handle may be undefined,
% depending on user interaction

whitebg('w');
% set the map parameters
axesm('MapProjection','stereo','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'Origin',pole,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on');

% load the global coastlines graphics from a matlab file
coast = load('coast.mat');

% Surfacem() is faster than Contourfm()
surfacem(lat,lon,data);
% Contourfm( ..., 'LineStyle','none') produces an equivalent plot
% contourm(lat,lon,data, 'LineStyle','none');

% load the Matlab default CFD rainbow color map
colormap('Jet');

% set the Y color axis range for the colorbar
caxis([min_data max_data]); 
% draw the colorbar
cbar_handle=colorbar('YTick', min_data:20:max_data);
set (get(cbar_handle, 'title'), 'string', strcat('UNITS: ',units));

% draw the coastlines in color black ('k')
plotm(coast.lat,coast.long,'k');

title('AMSR\_E\_L3\_SeaIce25km\_V11\_20050118\_SI\_25km\_SH\_23H\_DSC', ...
      'FontSize',16,'FontWeight','bold');

% if off-screen rendering, make the figure the same size as the X display
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');
  saveas(figure_handle, ...
  'AMSR_E_L3_SeaIce25km_V11_20050118_SI_25km_SH_23H_DSC_m.jpg');
end


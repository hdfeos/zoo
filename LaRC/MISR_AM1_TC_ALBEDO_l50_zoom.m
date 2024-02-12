%    This example code illustrates how to access and visualize LaRC
%  MISR Grid file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this
%  example, please use the HDF-EOS Forum
%  (http://hdfeos.org/forums). 
%
%    If you would like to see an  example of any other NASA
%  HDF/HDF-EOS data product that is not listed in the HDF-EOS
%  Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org  or
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Define file name, grid name, and data field.
FILE_NAME='MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.hdf';
GRID_NAME='ReflectingLevelParameters_2.2_km';
DATAFIELD_NAME='AlbedoLocal';

% Open the HDF-EOS2 Grid file.
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = hdfgd('attach', file_id, GRID_NAME);
[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], ...
                      []);

% Read dimension size of Grid.
[xdimsize, ydimsize, upleft, lowright, status] = ...
    hdfgd('gridinfo', grid_id);

% Read fill value from the data.
[fill_value,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Convert 4-D data to 2-D data by subsetting.
SOMBlockDim = 50;
NBandDim = 0;

% MATLAB index starts from 1.
data=squeeze(data1(NBandDim+1,:,:,SOMBlockDim+1));


% The file contains SOM projection. We need to use eosdump to generate 1D 
% lat and lon and then convert them to 2D lat and lon accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check [1].
lat1D = load('lat_MISR_TC_ALBEDO_P223_F05_lvl50.output');
lon1D = load('lon_MISR_TC_ALBEDO_P223_F05_lvl50.output');
lat = reshape(lat1D, ydimsize, xdimsize);
lon = reshape(lon1D, ydimsize, xdimsize);

% Convert the data to double type for plot.
data=double(data);
lat=double(lat);
lon=double(lon);

% Replace the fill values with NaN.
data(data==fill_value) = NaN;

% Set the limits for plot.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

colormap('Jet');

f = figure('Name', FILE_NAME, 'visible', 'off');

mloc = ceil((lonlim(2) - lonlim(1))/10);
ploc = ceil((latlim(2) - latlim(1))/10);
% Plot the data using contourfm and axesm.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLineLocation', mloc, ...
      'PLineLocation', ploc, ...      
      'MLabelLocation', mloc, ...
      'PLabelLocation', ploc)

% Load the global coastlines graphics.
coast = load('coast.mat');

surfacem(lat,lon,data);

caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);
set (get(h, 'title'), 'string', 'No Unit');


plotm(coast.lat,coast.long,'k')

title({strrep(FILE_NAME,'_','\_');...
       strrep(DATAFIELD_NAME,'_','\_');'at SOMBlockDim=50 NBandDim=0'}, ...
      'FontSize',16,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
if ishghandle(f)
  set(f,'position',scrsz,'PaperPositionMode','auto');
  saveas(f, ...
  'MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011_AlbedoLocal_lvl50_zoom.m.jpg');
end


% References
% 
% [1] http://hdfeos.org/zoo/note_non_geographic.php

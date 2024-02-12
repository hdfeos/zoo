%   This example code illustrates how to access and visualize NSIDC
% AMSR_E Grid HDF-EOS2 file in MATLAB.
%
%   If you have any questions, suggestions, comments  on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2011-10-31

% Example HDF File source:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
%       AMSR_E_L3_5DaySnow_V09_20050126.hdf
% See the file metadata description at:
% http://nsidc.org/cgi-bin/get_metadata.pl?id=ae_5dsno

clear;

% Open the HDF4 file.
FILE_NAME='AMSR_E_L3_5DaySnow_V09_20050126.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Attach grid.
GRID_NAME='Northern Hemisphere';
grid_id = hdfgd('attach', file_id, GRID_NAME);

% Read data from the data field.
DATAFIELD_NAME='SWE_NorthernPentad';
[data, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% This file contains coordinate variables that will not properly plot.
% To properly display the data, the latitude/longitude must be remapped.
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the grid Object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% The file contains LAMAZ projection. We need to use an external program
% to generate 1D lat and lon and then convert them to 2D lat and lon
% accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL
% http://hdfeos.org/zoo/note_non_geographic.php
lat1D = load('lat_AMSR_E_L3_5DaySnow_V09_20050126.Northern_Hemisphere.output');
lon1D = load('lon_AMSR_E_L3_5DaySnow_V09_20050126.Northern_Hemisphere.output');
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);
clear lat1D lon1D;

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
data=data';
lat = lat';
lon = lon';

% Filter out invalid range values.
% See "Table 2. Pixel Values ofr the SWE Feids" from [1].
data(data > 240) = NaN;

% Multiply by two according to the data spec [1].
data = 2 * data;

% Plot the data using contourfm and axesm.
% axesm EquaAzim Map Origin Argument -- North Pole
pole=[90 0 0];

% floor(min(min(lat))) is not useful, because undefined values extend to
% the opposite pole
latlim=[0.0, ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% Plot the data using surfm(or contourfm) and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','eqaazim', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'Origin',pole,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south');
coast = load('coast.mat');

% Surfacem() is faster than Contourfm()
% contourm(lat,lon,data,'LineStyle','none');
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k');

% Put colorbar.
colormap('Jet');
h = colorbar();

% Set unit's title manually using the data spec [1].
units = 'mm';
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;['Northern Hemisphere 5-day Snow Water Equivalent (' DATAFIELD_NAME ')']};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,'AMSR_E_L3_5DaySnow_V09_20050126_NH_SWE_NorthernPentad_matlab.jpg');
exit;

% References
% [1] http://nsidc.org/data/docs/daac/ae_swe_ease-grids.gd.html
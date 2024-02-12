%
% This example code illustrates how to access and visualize
% GES DISC AIRS Grid in MATLAB. 
%
% If you have any questions, suggestions, comments  on this
% example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r AIRS_2003_02_05_L3_RetStd_H001_v6_0_12_0_G14112124328_hdf
%
% Tested under: MATLAB R2016b
% Last updated: 2017-03-02

clear

import matlab.io.hdfeos.*

% Open the HDF-EOS2 Grid File.
FILE_NAME='AIRS.2003.02.05.L3.RetStd_H001.v6.0.12.0.G14112124328.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read Data from a Data Field.
GRID_NAME='ascending_MW_only';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME='Temperature_MW_A';

[data1, fail] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert 3-D data to 2-D data.
data=squeeze(data1(:,:,1));

% Convert the data to double type for plot.
data=double(data);

% Read filledValue from a Data Field.
fillvalue = gd.getFillValue(grid_id, DATAFIELD_NAME);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Detach from the Grid Object.
gd.detach(grid_id);

% Attach Grid to read Lat and Lon Data.
GRID_NAME='location';
grid_id = gd.attach(file_id, GRID_NAME);

% Read Lat Data.
LAT_NAME='Latitude';
[lat, status] = gd.readField(grid_id, LAT_NAME, [], [], []);
lat=double(lat);
fillvalue = gd.getFillValue(grid_id, LAT_NAME);

% Read Lon Data.
LON_NAME='Longitude';
[lon, status] = gd.readField(grid_id, LON_NAME, [], [], []);
lon=double(lon);
fillvalue = gd.getFillValue(grid_id, LON_NAME);


% Detach from the Grid Object.
gd.detach(grid_id);

% Close the File.
gd.close(file_id);

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f=figure('Name', FILE_NAME, 'visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
h=colorbar('YTick', min_data:5:max_data)

plotm(coast.lat,coast.long,'k')

% See AIRS data user guide [1] for unit specification.
units = 'K';

title({FILE_NAME; [DATAFIELD_NAME ' at TempPrsLvls=0']}, ...
      'Interpreter', 'None');

set (get(h, 'title'), 'string', units);

saveas(f, [FILE_NAME '.m.png']);
exit;
% References
% [1] http://disc.sci.gsfc.nasa.gov/AIRS/documentation/v6_docs/v6releasedocs-1/V6_L3_User_Guide.pdf

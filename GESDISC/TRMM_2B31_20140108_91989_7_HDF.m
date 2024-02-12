% 
% This example code illustrates how to access and visualize GES DISC
% TRMM 2B31 HDF4 Swath in MATLAB. 
%
% If you have any questions, suggestions, comments  on this
% example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed  in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r TRMM_2B31_20140108_91989_7_HDF
%
% Tested under: MATLAB R2017a
% Last updated: 2017-12-07

clear

import matlab.io.hdf4.*

FILE_NAME = '2B31.20140108.91989.7.HDF';
DATAFIELD_NAME='rrSurf';

sdID = sd.start(FILE_NAME,'read');

idx = sd.nameToIndex(sdID,DATAFIELD_NAME);
sdsID = sd.select(sdID,idx);
data = sd.readData(sdsID);
idx = sd.findAttr(sdsID, 'units');
units = sd.readAttr(sdsID, idx);
sd.endAccess(sdsID);

idx = sd.nameToIndex(sdID,'Latitude');
sdsID = sd.select(sdID,idx);
lat = sd.readData(sdsID);
lat = double(lat);
sd.endAccess(sdsID);

idx = sd.nameToIndex(sdID,'Longitude');
sdsID = sd.select(sdID,idx);
lon = sd.readData(sdsID);
lon = double(lon);
sd.endAccess(sdsID);

sd.close(sdID);

% Replace the fill value with NaN.
fv = min(min(data));
data(data==fv) = NaN;

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f=figure('Name', FILE_NAME, 'visible','off');
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'FontSize', 5, ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')
coast = load('coast.mat');
surfm(lat,lon,data);
colormap('Jet');
h=colorbar();
plotm(coast.lat,coast.long,'k');
tightmap;

title({FILE_NAME; DATAFIELD_NAME}, ...
      'Interpreter', 'None');
set (get(h, 'title'), 'string', units);
saveas(f, [FILE_NAME '.m.png']);
exit;

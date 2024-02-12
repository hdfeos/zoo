% 
% This example code illustrates how to access and visualize GES DISC
% TRMM 3B42 HDF4 Grid in MATLAB. 
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
% $matlab -nosplash -nodesktop -r TRMM_3B43_20130901_7_HDF
%
% Tested under: MATLAB R2017a
% Last updated: 2017-12-15

clear

import matlab.io.hdf4.*

FILE_NAME = '3B43.20130901.7.HDF';
DATAFIELD_NAME='precipitation';

sdID = sd.start(FILE_NAME,'read');

idx = sd.nameToIndex(sdID,DATAFIELD_NAME);
sdsID = sd.select(sdID,idx);
data = sd.readData(sdsID);
idx = sd.findAttr(sdsID, 'units');
units = sd.readAttr(sdsID, idx);
sd.endAccess(sdsID);
sd.close(sdID);

% Replace the fill value with NaN.
fv = min(min(data));
data(data==fv) = NaN;

% The lat and lon should be calculated manually [1].
lat = -49.875 : 0.25 : 49.875;
lon = -179.875 : 0.25 : 179.875;

% Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

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

% References
% [1] https://pmm.nasa.gov/sites/default/files/document_files/3B42_3B43_doc_V7.pdf

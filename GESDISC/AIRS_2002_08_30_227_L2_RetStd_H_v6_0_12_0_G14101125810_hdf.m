% 
% This example code illustrates how to access and visualize GES DISC
% AIRS Swath in MATLAB. 
%
% If you have any questions, suggestions, comments  on this
% example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed  in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

clear

import matlab.io.hdfeos.*

% Open the HDF-EOS2 Swath File.
FILE_NAME='AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf';
SWATH_NAME='L2_Standard_atmospheric&surface_product';

file_id = sw.open(FILE_NAME, 'rdonly');
swath_id = sw.attach(file_id, SWATH_NAME);

% Read data from a data field.
DATAFIELD_NAME='topog';
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);


% Replace the filled value with NaN.
data(data==-9999) = NaN;

% Detach from the Swath object and close the file.
sw.detach(swath_id);
sw.close(file_id);

% Plot the data using surfacem() and axesm().
pole=[90 0 0];
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name',FILE_NAME, 'visible','off');

axesm('MapProjection','stereo','Origin',pole, 'MapLatLimit',latlim)
axis off;
framem on;
gridm on;
mlabel on;
plabel on;
setm(gca, 'MLabelParallel', 20)

coast = load('coast.mat');

surfacem(double(lat),double(lon),double(data));

colormap('Jet');
caxis([min_data max_data]); 
h = colorbar();

plotm(coast.lat,coast.long,'k')

% See AIRS user's guide [1] for unit specification.
units = 'm';

title({FILE_NAME; DATAFIELD_NAME}, 'Interpreter', 'None')

set (get(h, 'title'), 'string', units);

saveas(f, [FILE_NAME '.m.png']);
exit;

% References
% [1] http://disc.sci.gsfc.nasa.gov/AIRS/documentation/v6_docs/v6releasedocs-1/V6_L2_Product_User_Guide.pdf

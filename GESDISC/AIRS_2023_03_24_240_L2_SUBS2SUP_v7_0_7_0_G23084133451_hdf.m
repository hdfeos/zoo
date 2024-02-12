%
% This example code illustrates how to access, merge, subset, and
% visualize GES DISC AIRS L2 swath files in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this
%  example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r AIRS_2023_03_24_240_L2_SUBS2SUP_v7_0_7_0_G23084133451_hdf
%
% Tested under: MATLAB R2023a
% Last updated: 2023-05-03

import matlab.io.hdfeos.*
import matlab.io.hdf4.*


FILE_NAME = 'AIRS.2023.03.24.240.L2.SUBS2SUP.v7.0.7.0.G23084133451.hdf';
DATAFIELD_NAME = 'olr';

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);


% Read _FillValue from the data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);


f = figure('Name', FILE_NAME, 'visible', 'off');


SWATH_NAME='L2_Support_atmospheric&surface_product';
    
% Open HDF-EOS2 file.
file_id = sw.open(FILE_NAME, 'rdonly');

% Open swath.
swath_id = sw.attach(file_id, SWATH_NAME);
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);
    
% Read lat and lon data.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Print whether it's asceding or descending.
attr = sw.readAttr(swath_id, 'node_type')

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Detach from the Swath object.
sw.detach(swath_id);
sw.close(file_id);


% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

coast = load('coastlines.mat');

scatterm(lat(:), lon(:), 1, data(:));

colormap('Jet');
h=colorbar();
plotm(coast.coastlat, coast.coastlon, 'k');


% Draw unit.
set(get(h, 'title'), 'string', 'None', ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;

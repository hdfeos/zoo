%
% This example code illustrates how to access and visualize LAADS
% multiple MODIS MOD04 L2 swath files in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MOD04_L2_merge
%
% Tested under: MATLAB R2021a
% Last updated: 2022-05-12

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% We assume all MOD04_L2 files are in the current working directory.
thepath = '.';

% Pick one file from collection to retrieve same attribute information.
FILE_NAME = 'MOD04_L2.A2015014.1220.006.2015034193424.hdf';

% Read data from a data field.
DATAFIELD_NAME='Optical_Depth_Land_And_Ocean';

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);


% Read _FillValue from the data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);


% Read scale_factor from the data field.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);

% Read add_offset from the data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);


f = figure('Name', 'MOD04_L2 Merged', 'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

coast = load('coastlines.mat');



D = dir(fullfile(thepath, 'MOD04_L2.*.hdf'));
for k =1:numel(D)
    FILE_NAME = fullfile(thepath, D(k).name)
    SWATH_NAME='mod04';
    
    % Open HDF-EOS2 file.
    file_id = sw.open(FILE_NAME, 'rdonly');

    % Open swath.
    swath_id = sw.attach(file_id, SWATH_NAME);
    data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);
    
    % Read lat and lon data.
    lon = sw.readField(swath_id, 'Longitude', [], [], []);
    lat = sw.readField(swath_id, 'Latitude', [], [], []);

    % Convert the data to double type for plot.
    data=double(data);
    lon=double(lon);
    lat=double(lat);

    % Replace the filled value with NaN.
    data(data==fillvalue) = NaN;

    % Multiply scale and adding offset, the equation is scale *(data-offset).
    data = scale*(data-offset);

    % surfm is faster than contourfm.
    surfm(lat, lon, data);
    
    if k == 1
        lat_m = [lat];
        lon_m = [lon];
        data_m = [data];
    else
        lat_m = [lat_m, lat];
        lon_m = [lon_m, lon];
        data_m = [data_m, data];        
    end
    
    % Detach from the Swath object.
    sw.detach(swath_id);
    sw.close(file_id);
end

colormap('Jet');
h=colorbar();
plotm(coast.coastlat, coast.coastlon, 'k');

% Draw unit.
set(get(h, 'title'), 'string', 'None', ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {'MOD04_L2 Merged';DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.png']);
writematrix(horzcat(lat_m(:), lon_m(:), data_m(:)), 'out.csv', ...
            'WriteMode','append');
exit;

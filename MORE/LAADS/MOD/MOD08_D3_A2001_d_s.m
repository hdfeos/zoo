%
% This example code illustrates how to access and visualize the
% daily average of multiple LAADS MODIS MOD08_D3 L3 Grid files in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOD08_D3_A2001_d_s
%
% Tested under: MATLAB R2023a
% Last updated: 2023-05-09

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% We assume that all MOD08_D3 L3 files are in the current working directory.
thepath = '.';

% Read data from a data field.
% Change this for a different data set.
DATAFIELD_NAME = 'Aerosol_Optical_Depth_Land_Ocean_Mean';
% DATAFIELD_NAME = 'Cloud_Top_Temperature_Mean';

D = dir(fullfile(thepath, 'MOD08_D3.A2001*hdf'));

for k = 1:numel(D)
    FILE_NAME = fullfile(thepath, D(k).name)
    GRID_NAME='mod08';
    
    if k == 1
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
    end
    
    % Open HDF-EOS2 file.
    file_id = gd.open(FILE_NAME, 'rdonly');
    
    % Open grid.
    grid_id = gd.attach(file_id, GRID_NAME);
    data = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);
    
    % Read lat and lon data.
    lon = gd.readField(grid_id, 'XDim', [], [], []);
    lat = gd.readField(grid_id, 'YDim', [], [], []);

    % Convert the data to double type for plot.
    data=double(data);
    lon=double(lon);
    lat=double(lat);

    % Replace fill value with NaN.
    data(data==fillvalue) = NaN;

    % Multiply scale and adding offset, the equation is scale *(data-offset).
    data = scale*(data-offset);
                                   
    % Detach from the Grid object.
    gd.detach(grid_id);
    gd.close(file_id);

    if k == 1
        data_m = data;
    else
        data_m = data_m + data;
    end
end

% Average data.
data_m = data_m / double(numel(D));
[lat_m, lon_m] = meshgrid(lat, lon);

f_x = (lon > 20.0 & lon < 60.0);
f_y = (lat > 0.0 & lat < 30.0);

data_s = data_m(f_x, f_y);
lon_s = lon_m(f_x, f_y);
lat_s = lat_m(f_x, f_y);

% Create the plot.
f = figure('Name', 'MOD08_D3', 'visible', 'off');
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

coast = load('coastlines.mat');
scatterm(lat_s(:), lon_s(:), 1, data_s(:));

colormap('Jet');
h=colorbar();
plotm(coast.coastlat, coast.coastlon, 'k');

% Draw unit.
set(get(h, 'title'), 'string', 'None', ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {'MOD08_D3 2001-01-01~2001-01-03 Avg. [0~30N] & [20~60E]'; ...
           DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 8, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in PNG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, ['MOD08_D3_A2001_d_s.m.png']);
exit;

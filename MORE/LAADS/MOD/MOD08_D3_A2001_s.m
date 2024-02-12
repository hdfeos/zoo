%
% This example code illustrates how to access and visualize the
% seasonal average of multiple LAADS MODIS MOD08_D3 L3 Grid files in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOD08_D3_A2001_s
%
% Tested under: MATLAB R2023a
% Last updated: 2023-04-17

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% We assume that all MOD08_D3 L3 files are in the current working directory.
thepath = '.';

% Read data from a data field.
% Change this for a different data set.
DATAFIELD_NAME = 'Aerosol_Optical_Depth_Land_Ocean_Mean';
% DATAFIELD_NAME = 'Cloud_Top_Temperature_Mean';

D = dir(fullfile(thepath, 'MOD08_D3.A200*hdf'));

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

    % Filter data based on lat/lon region. (e.g., 20~60E & 0~30N)
    f_x = (lon > 20.0 & lon < 60.0);
    f_y = (lat > 0.0 & lat < 30.0);
    data = data(f_x, f_y);
                                   
    % Multiply scale and adding offset, the equation is scale *(data-offset).
    data = scale*(data-offset);
                                   
    % Detach from the Grid object.
    gd.detach(grid_id);
    gd.close(file_id);

    % Replace time value from file name.
    [filepath, name, ext] = fileparts(FILE_NAME);
    strs = split(name, ".");
    str = strs(2); % Extract day. (e.g., A2021036)

    str_year = extractBetween(str,2,5);
    year = str2double(str_year);

    str_day = extractBetween(str, 6, 8);
    day = str2double(str_day);

    str_mo = datestr(datevec(datenum(year, 1, day)), 'mm');

    s = floor(str2double(str_mo) / 3);
    if s == 4
        s = 0;
    end
    time(:) = s;
    writematrix(horzcat(time, mean(data(:), "omitmissing")), 'outs.csv', ...
                'WriteMode','append');
end

% Read filtered data to calculate average.
A = readtable('outs.csv');
B = varfun(@mean, A, 'InputVariables', 2,...
           'GroupingVariables', 1);
% Draw plot.
f = figure('Name', 'MOD08_D3 Seasonal Average', 'visible', 'off');
plot(B.Var1, B.mean_Var2);
xtickformat('%d');
xticks(B.Var1);
xlabel({'Season in 2001/03~2002/02' ; '0=winter 1=spring 2=summer 3=fall'});

% Put title.
tstring = {'MOD08_D3 Seasonal Average [0~30N] & [20~60E]';DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in PNG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, ['MOD08_D3_A2001_s.m.png']);
exit;

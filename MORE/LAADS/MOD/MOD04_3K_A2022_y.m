%
% This example code illustrates how to access and visualize the
% yearly average of multiple LAADS MODIS MOD04_3K L2 swath files in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOD04_3K_A2022_y
%
% Tested under: MATLAB R2021a
% Last updated: 2022-02-11

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% We assume that all MOD04_3K L2 files are in the current working directory.
thepath = '.';

% Read data from a data field.
DATAFIELD_NAME='Optical_Depth_Land_And_Ocean';

D = dir(fullfile(thepath, 'MOD04_3K.A*.*.hdf'));

for k =1:numel(D)
    FILE_NAME = fullfile(thepath, D(k).name);
    SWATH_NAME='mod04';
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
    file_id = sw.open(FILE_NAME, 'rdonly');
    
    % Open swath.
    swath_id = sw.attach(file_id, SWATH_NAME);
    data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);
    
    % Read lat and lon data.
    lon = sw.readField(swath_id, 'Longitude', [], [], []);
    lat = sw.readField(swath_id, 'Latitude', [], [], []);

    % Read time.
    time = sw.readField(swath_id, 'Scan_Start_Time', [], [], []);

    % Convert the data to double type for plot.
    data=double(data);
    lon=double(lon);
    lat=double(lat);

    % Filter data based on lat/lon region. (e.g., 30~50E & 0~20N)
    filter =  (data~=fillvalue & ...
               lon > 30.0 & lon < 50.0 & ...
               lat > 0.0 & lat < 20.0);

    % Filter data based on lat/lon 1 degree. (e.g., 40.0E & 10.0N)
    filter =  (data~=fillvalue & ...
               lon >= 40.0 & lon < 41.0 & ...
               lat >= 10.0 & lat < 11.0);

    data = data(filter);
    lat = lat(filter);
    lon = lon(filter);
    time = time(filter);
    % Multiply scale and adding offset, the equation is scale *(data-offset).
    data = scale*(data-offset);
    
    % Detach from the Swath object.
    sw.detach(swath_id);
    sw.close(file_id);

    % Replace time value with month value from file name.
    [filepath,name,ext] = fileparts(FILE_NAME);
    strs = split(name, ".");
    str = strs(2); % Extract year and day. (e.g., A2022036)
    str_year = extractBetween(str,2,5);
    year = str2double(str_year);
    time(:) = year;
    writematrix(horzcat(time(:), lat(:), lon(:), data(:)), 'outy.csv', ...
                'WriteMode','append');
end

% Read filtered data to calculate average.
A = readtable('outy.csv');
B = varfun(@mean,A,'InputVariables',4,...
           'GroupingVariables',1);
% Draw plot.
f = figure('Name', 'MOD04_3K Monthly Average', 'visible', 'off');
plot(B.Var1, B.mean_Var4);
xtickformat('%d');
xticks(B.Var1);
xlabel('Year');

% Put title.
tstring = {'MOD04_3K Yearly Average at lon=40E lat=10N';DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in PNG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, ['MOD04_3K_A2022_y.m.png']);
exit;

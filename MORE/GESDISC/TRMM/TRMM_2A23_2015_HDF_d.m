%  This example code illustrates how to access and visualize TRMM version 7
% 2A23 HDF4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r TRMM_2A23_2015_HDF_d
%
% Tested under: MATLAB R2023a
% Last updated: 2023-09-11

import matlab.io.hdf4.*

% We assume that all TRMM files are in the current working directory.
thepath = '.';

% Open the HDF4 files.
FILE_NAMES = '2A23.2015*.7.HDF';
datafield_name = 'freezH';
datafield_name2 = 'HBB';

D = dir(fullfile(thepath, FILE_NAMES));
for k = 1:numel(D)
    file_name = fullfile(thepath, D(k).name)
    sd_id = sd.start(file_name, 'rdonly');

    % Read data.
    sds_index = sd.nameToIndex(sd_id, datafield_name);
    sds_id = sd.select(sd_id, sds_index);
    [name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
    data = sd.readData(sds_id);
    sd.endAccess(sds_id);

    % Read units attribute once.
    if k == 1
        units_index = sd.findAttr(sds_id, 'units');
        units = sd.readAttr(sds_id, units_index);
    end
    sd.endAccess(sds_id);

    % Read another data to compare.
    sds_index = sd.nameToIndex(sd_id, datafield_name2);
    sds_id = sd.select(sd_id, sds_index);
    [name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
    data2 = sd.readData(sds_id);
    sd.endAccess(sds_id);
   
    % Read latitude.
    geo_name='Latitude';
    sds_index = sd.nameToIndex(sd_id, geo_name);
    sds_id = sd.select(sd_id, sds_index);
    [name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
    lat = sd.readData(sds_id);
    sd.endAccess(sds_id);

    % Read longitude.
    geo_name='Longitude';
    sds_index = sd.nameToIndex(sd_id, geo_name);
    sds_id = sd.select(sd_id, sds_index);
    [name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
    lon = sd.readData(sds_id);
    sd.endAccess(sds_id);

    % Close the file.
    sd.close(sd_id);

    % Convert the data to double type for plot.
    data = double(data);
    data2 = double(data2);
    lon = double(lon);
    lat = double(lat);

    % Handle fill value.
    fillvalue2 = -8888.0;

    % Replace fill value with NaN.
    data2(data2==fillvalue2) = NaN;

    % Find indexes for the South Africa region.
    x = (lon > 16.3449768409 & lon < 32.830120477 & ...
         lat > -34.8191663551 & lat < 32.830120477);
    lon_s = lon(x);
    lat_s = lat(x);
    data_s = data(x);
    data_s2 = data2(x);

    % Extract date.
    [filepath, name, ext] = fileparts(file_name);
    strs = split(name, ".");
    str = strs(2); 
    time = str2double(str);
    writematrix(horzcat(time, mean(data_s(:), "omitmissing")), ...
                'out_d.csv', ...
                'WriteMode','append');
    writematrix(horzcat(time, mean(data_s2(:), "omitmissing")), ...
                'out_d2.csv', ...
                'WriteMode','append');    
end

% Read filtered data to calculate average.
A = readtable('out_d.csv');
B = varfun(@mean, A, 'InputVariables', 2,...
           'GroupingVariables', 1);

A2 = readtable('out_d2.csv');
B2 = varfun(@mean, A2, 'InputVariables', 2,...
           'GroupingVariables', 1);

% Draw plot.
f = figure('Name', '2A23 Daily Average', ...
           'visible', 'off');

tiledlayout(2, 1);

subplot(2, 1, 1);
plot(datetime(num2str(B.Var1), 'InputFormat', 'yyyyMMdd'), B.mean_Var2);
% 29 is yyyy-mm-dd format [1].
datetick('x', 29);
ylabel(units)

% Put title.
s = '2A23 2015 Daily Average in South Africa region';
tstring = {s, datafield_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

subplot(2, 1, 2);
plot(datetime(num2str(B2.Var1), 'InputFormat', 'yyyyMMdd'), B2.mean_Var2, ...
     color='r');
title(datafield_name2, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
datetick('x', 29);
% HBB has the same units as freezH.
ylabel(units) 

linkaxes(gca, 'x');

% The following fixed-size screen size will look better in PNG
% if your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, ['2A23_2015.HDF.d.m.png']);
exit;

% Reference
%
% [1] https://www.mathworks.com/help/matlab/ref/datetick.html
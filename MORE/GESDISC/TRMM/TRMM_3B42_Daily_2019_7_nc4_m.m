%  This example code illustrates how to access multiple GES DISC
% 3B42 Grid files and calculate monthly average over some region in MATLAB.
%
%  If you have any questions, suggestions, comments  on this
% example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  Usage:save this script and run (without .m at the end)
%
%    $matlab -nosplash -nodesktop -r TRMM_3B42_Daily_2019_7_nc4_m
%
%  Tested under: MATLAB R2023a
%  Last updated: 2023-06-06

% We assume that all TRMM files are in the current working directory.
thepath = '.';

% Read data from a data field.
DATAFIELD_NAME = 'precipitation';

D = dir(fullfile(thepath, '3B42_Daily.2019*.7.nc4'));

for k = 1:numel(D)
    FILE_NAME = fullfile(thepath, D(k).name)

    % Open netCDF-4 file.
    file_id = netcdf.open(FILE_NAME, 'nowrite');
    data = ncread(FILE_NAME, DATAFIELD_NAME);

    % Convert the data to double type for plot.
    data_m = double(data);

    if k == 1
        % Read units.
        units = ncreadatt(FILE_NAME, DATAFIELD_NAME, "units");

        % Read long_name.
        long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, ...
                              "long_name");

        % Read lat and lon data.
        lon = ncread(FILE_NAME, 'lon');
        lat = ncread(FILE_NAME, 'lat');
        lon=double(lon);
        lat=double(lat);
    end
    % Average data.
    [lon_m, lat_m] = meshgrid(lon, lat);
    f_x = (lon > 20.0 & lon < 60.0);
    f_y = (lat > 0.0 & lat < 30.0);
    data_s = data_m(f_y, f_x);

    % Extract month.
    [filepath, name, ext] = fileparts(FILE_NAME);
    strs = split(name, ".");
    str = strs(2); 
    day = extractBetween(str, 5, 6);
    time = str2double(day)
    writematrix(horzcat(time, mean(data_s(:), "omitmissing")), 'out_m.csv', ...
                'WriteMode','append');    
    netcdf.close(file_id);
end

% Read filtered data to calculate average.
A = readtable('out_m.csv');
B = varfun(@mean, A, 'InputVariables', 2,...
           'GroupingVariables', 1);
% Draw plot.
f = figure('Name', '3B42 2019 Monthly Average from Jan to Feb', ...
           'visible', 'off');
plot(B.Var1, B.mean_Var2);
xtickformat('%d');
xticks(B.Var1);
xlabel('Month in 2019');

% Put title.
ln_strs = split(long_name, 'with');
s = '3B42_2019 Monthly Average [0~30N] & [20~60E]';
tstring = {s, ln_strs(1),  strcat('with ', ln_strs(2))};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in PNG
% if your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, ['3B42_Daily.2019.7.nc4.m.m.png']);
exit;


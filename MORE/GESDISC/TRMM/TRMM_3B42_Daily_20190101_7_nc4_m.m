% This example code illustrates how to access multiple GES DISC
% 3B42 Grid files and calculate monthly average over some region in MATLAB.
%
%  If you have any questions, suggestions, comments  on this
%  example, please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r TRMM_3B42_Daily_20190101_7_nc4_m
%
% Tested under: MATLAB R2023a
% Last updated: 2023-06-01

% We assume that all TRMM files are in the current working directory.
thepath = '.';

% Read data from a data field.
DATAFIELD_NAME = 'precipitation';

D = dir(fullfile(thepath, '3B42_Daily.201901*.7.nc4'));

for k = 1:numel(D)
    FILE_NAME = fullfile(thepath, D(k).name)

    % Open netCDF-4 file.
    file_id = netcdf.open(FILE_NAME, 'nowrite');
    data = ncread(FILE_NAME, DATAFIELD_NAME);

    % Convert the data to double type for plot.
    data=double(data);

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
        data_m = data;
    else
        data_m = data_m + data;
    end
    netcdf.close(file_id);
end

% Average data.
data_m = data_m / double(numel(D));
[lon_m, lat_m] = meshgrid(lon, lat);


f_x = (lon > 20.0 & lon < 60.0);
f_y = (lat > 0.0 & lat < 30.0);

data_s = data_m(f_y, f_x);
lon_s = lon_m(f_y, f_x);
lat_s = lat_m(f_y, f_x);

% Create the plot.
f = figure('Name', '3B42_Daily', 'visible', 'off');

subplot(1,2,1);

axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

coast = load('coastlines.mat');
scatterm(lat_s(:), lon_s(:), 1, data_s(:));

colormap('Jet');
h=colorbar();
plotm(coast.coastlat, coast.coastlon, 'k');

% Draw unit.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {'3B42_Daily 2019 Jan. Avg. [0~30N] & [20~60E]'; ...
           long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 8, ...
      'FontWeight','bold');
tightmap;

% Handle February.
D = dir(fullfile(thepath, '3B42_Daily.201902*.7.nc4'));

for k = 1:numel(D)
    FILE_NAME = fullfile(thepath, D(k).name)

    % Open netCDF-4 file.
    file_id = netcdf.open(FILE_NAME, 'nowrite');
    data = ncread(FILE_NAME, DATAFIELD_NAME);

    % Convert the data to double type for plot.
    data=double(data);

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
        data_m = data;
    else
        data_m = data_m + data;
    end
    netcdf.close(file_id);
end

% Average data.
data_m = data_m / double(numel(D));
[lon_m, lat_m] = meshgrid(lon, lat);


f_x = (lon > 20.0 & lon < 60.0);
f_y = (lat > 0.0 & lat < 30.0);

data_s = data_m(f_y, f_x);
lon_s = lon_m(f_y, f_x);
lat_s = lat_m(f_y, f_x);

subplot(1,2,2);
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

coast = load('coastlines.mat');
scatterm(lat_s(:), lon_s(:), 1, data_s(:));

colormap('Jet');
h=colorbar();
plotm(coast.coastlat, coast.coastlon, 'k');

% Draw unit.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {'3B42_Daily 2019 Feb. Avg. [0~30N] & [20~60E]'; ...
           long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 8, ...
      'FontWeight','bold');
tightmap;

scrsz = [1 1 800*2 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, ['3B42_Daily.20190101.7.nc4.m.m.png']);
exit;

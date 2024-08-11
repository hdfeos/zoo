%
% This example code illustrates how to access and visualize LAADS
% VNP02IMG v2 NetCDF-4/HDF5 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r VNP02IMG_A2020073_0942_002_2021126174430_nc
%
% Tested under: MATLAB R2023b
% Last updated: 2024-08-09

% Open file.
FILE_NAME='VNP02IMG.A2020073.0942.002.2021126174430.nc';
ncid = netcdf.open(FILE_NAME, 'nowrite');

% Read data.
DATAFIELD_NAME='/observation_data/I05';
data = ncread(FILE_NAME, DATAFIELD_NAME);

% ncread() applies scale and offset automatically.
% Verify it using min/max.
% a = min(min(data))
% b = max(max(data))

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, "units");

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, "long_name");

% Read _FillValue.
fill_value = ncreadatt(FILE_NAME, DATAFIELD_NAME, "_FillValue");

% Read add_offset.
add_offset = ncreadatt(FILE_NAME, DATAFIELD_NAME, "add_offset");

% Read scale_factor.
scale_factor = ncreadatt(FILE_NAME, DATAFIELD_NAME, "scale_factor");

% Read valid_min.
valid_min = ncreadatt(FILE_NAME, DATAFIELD_NAME, "valid_min");

% Read valid_max.
valid_max = ncreadatt(FILE_NAME, DATAFIELD_NAME, "valid_max");

netcdf.close(ncid);

% Open geo-location file from [1].
GEO_FILE_NAME = 'VNP03IMG.A2020073.0942.002.2021125004714.nc';
ncid = netcdf.open(GEO_FILE_NAME, 'nowrite');

% Open the dataset.
Lat_NAME='geolocation_data/latitude';
Lon_NAME='geolocation_data/longitude';
lat=ncread(GEO_FILE_NAME, Lat_NAME);
lon=ncread(GEO_FILE_NAME, Lon_NAME);
% Close the file.
netcdf.close(ncid);

% Replace the fill value with NaN
dataf = double(data);
dataf(data == (double(fill_value) * scale_factor + add_offset)) = NaN;

% Handle valid range.
dataf(data < (double(valid_min) * scale_factor + add_offset)) = NaN;
dataf(data > (double(valid_max) * scale_factor + add_offset)) = NaN;

% Verify filtered values using min/max.
% a = min(min(dataf))
% b = max(max(dataf))


% Set the map parameters.
[xdimsize, ydimsize] = size(data);
lon_c = lon(xdimsize/2, ydimsize/2);
lat_c = lat(xdimsize/2, ydimsize/2);
latlim=ceil(max(max(lat))) - floor(min(min(lat)));

% Create the graphics figure -- 'visible'->'off' = off-screen rendering.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% Use colormap.
colormap('Jet');

% Use FlatLimit for zoom-in effect in Ortho projection.
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'FLatLimit', [-Inf, latlim], ...       
       'origin', [lat_c, lon_c])
mlabel('equator')
plabel(0); 
plabel('fontweight','bold')

% Plot data. 
lats = lat(:);
lons = lon(:);
datas = dataf(:);

% Subset points to avoid system crashing due to memory.
% scatterm(lat, lon, 1, data);
% step = 100;
% step = 10;
step = 5;
% step = 2; killed

%scatterm(lat(1:step:end), lon(1:step:end), 1.0, dataf(1:step:end));
scatterm(lats(1:step:end), lons(1:step:end), 1.0, datas(1:step:end));


% Load the coastlines data file.
coast = load('coastlines.mat');

% Plot coastlines in color black ('k').
plotm(coast.coastlat, coast.coastlon, 'k')

h=colorbar();
set (get(h, 'title'), 'string', units);

% Set the title using long_name.
title({FILE_NAME; long_name}, ...
      'interpreter', 'none', 'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

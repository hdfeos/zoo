%  This example code illustrates how to access and visualize OBPG
%  MODIS Aqua HDF4 Grid file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2011-10-20

clear

% Open the HDF4 file.
FILE_NAME='A20021612002192.L3m_R32_NSST_4.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from a data field.
DATAFIELD_NAME='l3m_data';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Transpose the data to match the map projection
data=data';

% Set fill value by reading the data directly.
fillvalue = 65535;

% The lat and lon should be calculated using lat and lon of southwest point.
% Then we need number of lines and columns to calculate the lat and lon
% step. Assume even space between lat and lon points to get all lat and lon
% data.
smlat_index = hdfsd('findattr', SD_id, 'SW Point Latitude');
[smlat, status] = hdfsd('readattr',SD_id, smlat_index);

wmlon_index = hdfsd('findattr', SD_id, 'SW Point Longitude');
[wmlon, status] = hdfsd('readattr',SD_id, wmlon_index);

nlat_index = hdfsd('findattr', SD_id, 'Number of Lines');
[nlat, status] = hdfsd('readattr',SD_id, nlat_index);

nlon_index = hdfsd('findattr', SD_id, 'Number of Columns');
[nlon, status] = hdfsd('readattr',SD_id, nlon_index);

latstep_index = hdfsd('findattr', SD_id, 'Latitude Step');
[latstep, status] = hdfsd('readattr',SD_id, latstep_index);

lonstep_index = hdfsd('findattr', SD_id, 'Longitude Step');
[lonstep, status] = hdfsd('readattr',SD_id, lonstep_index);

smlat = double(smlat); wmlon = double(wmlon); nlat = double(nlat);
nlon = double(nlon); latstep = double(latstep); lonstep = double(lonstep);

nmlat = smlat + (nlat-1)*latstep;
emlon = wmlon + (nlon-1)*lonstep;

lat = nmlat : (-latstep) : smlat;
lon = wmlon : (lonstep) : emlon;

% Read units from the data field.
% The "units"  is stored as the file attribute rather than SDS attribute.
% We have to read the data out from the file attribute.
% Generally, the units should be stored as the SDS attribute.
% To retrieve the SDS attribute, see the following commented code.
% units_index = hdfsd('findattr', sds_id, 'units');
%[units, status] = hdfsd('readattr',sds_id, units_index);
units_index = hdfsd('findattr', SD_id, 'Units');
[units, status] = hdfsd('readattr',SD_id, units_index);

long_name_index = hdfsd('findattr', SD_id, 'Parameter');
[long_name, status] = hdfsd('readattr',SD_id, long_name_index);


% Read scale_factor from the data field attribute.
scale_index = hdfsd('findattr', sds_id, 'Slope');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Read offset from the data field attribute.
offset_index = hdfsd('findattr', sds_id, 'Intercept');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the filled value with NaN.
data(data == fillvalue) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Plot the data using surfm(contourfm) and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

f = figure('Name', FILE_NAME, 'Visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

% surfm is faster than contourfm.
% contourfm(lat,lon,data);
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=min(min(data));
max_data=max(max(data));
granule = (max_data - min_data) / ntickmarks;
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);

set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold');

% Put title.
tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'none', 'FontSize',16,'FontWeight','bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');

saveas(f, 'A20021612002192.L3m_R32_NSST_4_l3m_data.m.jpg');
exit;


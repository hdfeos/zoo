%
%  This example code illustrates how to access and visualize
%  ICESat-2 ATL06 HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
% 
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r ATL06_20190419050509_03200302_001_01_h5
% 
%
% Tested under: MATLAB R2019b
% Last updated: 2019-10-23


% Read data.
FILE_NAME='ATL06_20190419050509_03200302_001_01.h5';
file_id=H5F.open(FILE_NAME,'H5F_ACC_RDONLY','H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='gt1l/land_ice_segments/latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);
LONFIELD_NAME='gt1l/land_ice_segments/longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);
DATAFIELD_NAME='gt1r/land_ice_segments/h_li';
data_id=H5D.open(file_id, DATAFIELD_NAME);
TIME_NAME='/gt1r/land_ice_segments/delta_time';
time_id=H5D.open(file_id, TIME_NAME);


% Read the datasets.
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');


% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units_data = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name_data = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Check min/max lat/lon.
min(min(lat))
max(max(lat))
min(min(lon))
max(max(lon))

% Subset data based on lat/lon.
lat_ind = (lat > 42.9 & lat < 75);
lon_ind = (lon > 20.6 & lon < 30);
ss_ind = lat_ind & lon_ind;
lat = lat(ss_ind);
lon = lon(ss_ind);
data = data(ss_ind);
time = time(ss_ind);
szdim = size(lat, 1);

% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Plot 2D figure.
plot(lat, data)


% Put title.
var_name = sprintf('%s', long_name_data);
% See [1].
time_s=datestr(datevec(datenum(2018,1,1, 0, 0, 0)+time(1)/86400));
time_l=datestr(datevec(datenum(2018,1,1, 0, 0, 0)+time(szdim)/86400));
time_info =['From=' time_s ' To=' time_l];
tstring = {FILE_NAME;var_name;time_info};

% Label x-axis with lat/lon [2].
oneTick = ['lat=' num2str(lat(1)) ' lon=' num2str(lon(1))];
lastTick = ['lat=' num2str(lat(szdim)) ' lon=' num2str(lon(szdim))];
    
xticks([lat(1), lat(szdim)])
xticklabels({oneTick, lastTick})

% Put labels.
xlabel('Location');
units_str = sprintf('%s', char(units_data));
ylabel(units_str);

       
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

saveas(f, [FILE_NAME '.m.png']);
exit;

% References
% [1] https://nsidc.org/sites/nsidc.org/files/technical-references/ATL06-data-dictionary-v001.pdf
% [2] https://www.mathworks.com/matlabcentral/answers/77489-xticks-showing-latitude-and-longitude

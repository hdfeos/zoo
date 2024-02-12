%
%  This example code illustrates how to access and visualize
% LaRC ASDC g3bssp vertical profile HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% You can run this script in batch mode as follows:
%
% $matlab -nosplash -nodesktop -r g3b_ssp_2022062949SSv05_21
%
% Please note that there is no .m in the above command at the end.
%
% Tested Under:
% Tested under: MATLAB R2021a
% Last Update: 2022-09-09

% Open the HDF5 File.
FILE_NAME = 'g3b.ssp.2022062949SSv05.21';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read the O3 dataset.
DATAFIELD_NAME = '/Altitude Based Data/Aerosol Ozone Profiles/Ozone_AO3';
data_id = H5D.open(file_id, DATAFIELD_NAME);
data = H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');

% Read the altitude dataset.
ALTITUDE_NAME = '/Altitude Based Data/Altitude Information/Altitude';
alt_id = H5D.open(file_id, ALTITUDE_NAME);
altitude = H5D.read(alt_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                  'H5P_DEFAULT');

% Read the time dataset. 
TIME_NAME = '/Event Information/Time';
time_id = H5D.open(file_id, TIME_NAME);
time = H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');

% Read the date dataset. 
DATE_NAME = '/Event Information/Date';
date_id = H5D.open(file_id, DATE_NAME);
date = H5D.read(date_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
              'H5P_DEFAULT');

% Read the lat dataset. 
LAT_NAME = '/Event Information/Latitude';
lat_id = H5D.open(file_id, LAT_NAME);
lat = H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
              'H5P_DEFAULT');

% Read the lon dataset. 
LON_NAME = '/Event Information/Longitude';
lon_id = H5D.open(file_id, LON_NAME);
lon = H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
              'H5P_DEFAULT');

% Read the units of data.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');


% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the long_name attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the units of altitude axis.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (alt_id, ATTRIBUTE);
units_alt = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (alt_id, ATTRIBUTE);
long_name_alt = H5A.read(attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (alt_id);
H5D.close (time_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data == fillvalue) = NaN;

f = figure('Name', FILE_NAME, 'visible', 'off');

plot(data, altitude);

ylabel([long_name_alt ' (' units_alt ')']);
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);

date_s = num2str(date);
year = date_s(1:4);
month = date_s(5:6);
day = date_s(7:8);
d = [year, '-', month, '-', day];

time_s = num2str(time, '%06d');
hh = time_s(1:2);
mm = time_s(3:4);
ss = time_s(5:6);
t = [hh, ':', mm, ':', ss, 'Z'];

dt = [d 'T' t];
xtitle = [long_name ' at ' dt];
xlabel([xtitle ' (' units ')']);

ax = gca;

title({FILE_NAME; ['Longitude=', num2str(lon), ...
                   ' Latitude=', num2str(lat)]}, ... 
      'Interpreter', 'None', 'FontSize',16,'FontWeight','bold');

saveas(f, [FILE_NAME, '.m.png']);
exit;

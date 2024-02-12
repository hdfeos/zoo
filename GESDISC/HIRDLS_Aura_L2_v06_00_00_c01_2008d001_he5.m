%  This example code illustrates how to access and visualize GES-DISC HIRDLS
%  HDF-EOS5 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2012a
% Last updated: 2012-04-25

clear;

% Open the HDF-EOS5 file.
FILE_NAME = 'HIRDLS-Aura_L2_v06-00-00-c01_2008d001.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open datasets.
DATAFIELD_NAME = 'HDFEOS/SWATHS/HIRDLS/Data Fields/O3';
data_id = H5D.open (file_id, DATAFIELD_NAME);

PRESSURE_NAME='HDFEOS/SWATHS/HIRDLS/Geolocation Fields/Pressure';
pre_id=H5D.open(file_id, PRESSURE_NAME);

TIME_NAME='HDFEOS/SWATHS/HIRDLS/Geolocation Fields/Time';
time_id=H5D.open(file_id, TIME_NAME);

% Read datasets.
data1=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');

pressure=H5D.read(pre_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                  'H5P_DEFAULT');

time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
              'H5P_DEFAULT');

% Read the units attribute.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name(pre_id, ATTRIBUTE);
units_pre = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title attribute.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (pre_id, ATTRIBUTE);
long_name_pre = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missingvalue attribute.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Set subset index.
tdim = 1;

% Convert 2-D data to 1-D data.
data=squeeze(data1(:,tdim));

% Time is second from TAI93.
% We don't handle leap second.
timelvl=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(tdim)/86400));

% Apply log scale along Y-axis get a better image.
pressure = log10(double(pressure));


%Replace the fill value with NaN
data(data==fillvalue) = NaN;

%Replace the missing value with NaN
data(data==missingvalue) = NaN;

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
unit_pre = sprintf('%s', units_pre);
name_pre = sprintf('%s', long_name_pre);

f = figure('Name', FILE_NAME, 'visible', 'off');

plot(data, pressure)
xlabel([name ' (' unit ')'], 'Interpreter', 'none'); 
ylabel([name_pre ' (' unit_pre ') in log_{10} scale']);

% Put title.
tstring = {FILE_NAME;[name ' at ' timelvl]};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 400 300];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;

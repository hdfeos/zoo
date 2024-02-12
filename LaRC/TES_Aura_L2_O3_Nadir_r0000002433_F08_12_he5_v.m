% 
%   This example code illustrates how to access and visualize TES O3 
%   HDF-EOS5 Swath file in MATLAB.
%
%   If you have any questions, suggestions, comments  on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  If you would like to see an example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r TES_Aura_L2_O3_Nadir_r0000002433_F08_12_he5_v
%
% Tested under: MATLAB R2021a
% Last updated: 2021-12-01

clear
% Open the HDF5 File.
FILE_NAME = 'TES-Aura_L2-O3-Nadir_r0000002433_F08_12.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'HDFEOS/SWATHS/O3NadirSwath/Data Fields/O3';
data_id = H5D.open (file_id, DATAFIELD_NAME);

PRESSURE_NAME='HDFEOS/SWATHS/O3NadirSwath/Data Fields/Pressure';
pre_id=H5D.open(file_id, PRESSURE_NAME);

TIME_NAME='HDFEOS/SWATHS/O3NadirSwath/Geolocation Fields/Time';
time_id=H5D.open(file_id, TIME_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');

pressure=H5D.read(pre_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                  'H5P_DEFAULT');

time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Time is second from TAI93.
% See 4-25 of "TES Science Data Processing Standard and Special Observation
% Data Products Specification" [1].
% Please note that the computed time is off by 7 seconds from the
% values stored in "/HDFEOS/SWATHS/O3NadirSwath/Data Fieds/UTCTime".
timelvl_1=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(56)/86400));
timelvl_2=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(156)/86400));
timelvl_3=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(956)/86400));
timelvl_4=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(1115)/86400));


% Read the title.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (pre_id, ATTRIBUTE);
long_name_p = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (pre_id, ATTRIBUTE);
units_p = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

attr_id = H5A.open_name (pre_id, ATTRIBUTE);
fillvalue_p=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missing value.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

attr_id = H5A.open_name (pre_id, ATTRIBUTE);
missingvalue_p=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');


% Close and release resources.
H5A.close (attr_id);
H5D.close (data_id);
H5D.close (pre_id);
H5D.close (time_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
pressure(pressure==fillvalue_p) = NaN;

% Replace the missing value with NaN.
data(data==missingvalue) = NaN;
pressure(pressure==missingvalue_p) = NaN;

% Convert 2-D data to 1-D data.
data_1=squeeze(data(:,56));
data_2=squeeze(data(:,156));
data_3=squeeze(data(:,956));
data_4=squeeze(data(:,1115));

% Convert 2-D data to 1-D data.
pressure_1=squeeze(pressure(:,56));
pressure_2=squeeze(pressure(:,156));
pressure_3=squeeze(pressure(:,956));
pressure_4=squeeze(pressure(:,1115));

% Set axis label strings.
u_p = sprintf('%s', units_p);
u = sprintf('%s', units);
name = sprintf('%s', long_name);
name_p = sprintf('%s', long_name_p);
x_label_string = [name ' (' u ')'];
y_label_string = [name_p ' (' u_p ')'];

f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% Draw plot.
subplot(2,2,1);
semilogy(data_1, pressure_1);
xlabel(x_label_string);
ylabel(y_label_string);

% Put highest pressure at the bottom of Y-axis.
ax = gca;
ax.YDir = 'reverse';

% Apply log scale along Y-axis get a better image.
set(gca, 'YScale', 'log')

% Turn off scientific notation (e.g., 10^3) in Y-axis tick labels.
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);

% Set title.
tstring = {FILE_NAME;[name ' at ' timelvl_1]};
title(tstring, 'Interpreter', 'none', 'FontSize',8,'FontWeight', ...
      'bold');


% Draw another at different time.
subplot(2,2,3);
semilogy(data_2, pressure_2);
xlabel(x_label_string);
ylabel(y_label_string);
ax = gca;
ax.YDir = 'reverse';
set(gca, 'YScale', 'log')
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);
tstring = {FILE_NAME;[name ' at ' timelvl_2]};
title(tstring, 'Interpreter', 'none', 'FontSize',8,'FontWeight', ...
      'bold');

subplot(2,2,2);
semilogy(data_3,pressure_3);
xlabel(x_label_string);
ylabel(y_label_string);
ax = gca;
ax.YDir = 'reverse';
set(gca, 'YScale', 'log')
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);
tstring = {FILE_NAME;[name ' at ' timelvl_3]};
title(tstring, 'Interpreter', 'none', 'FontSize',8,'FontWeight', ...
      'bold');

subplot(2,2,4);
semilogy(data_4, pressure_4);
xlabel(x_label_string);
ylabel(y_label_string);
ax = gca;
ax.YDir = 'reverse';
set(gca, 'YScale', 'log')
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);
tstring = {FILE_NAME;[name ' at ' timelvl_4]};
title(tstring, 'Interpreter', 'none', 'FontSize',8,'FontWeight', ...
      'bold');
saveas(f, [FILE_NAME '.v.m.png']);
exit;

% Reference 
% [1] https://asdc.larc.nasa.gov/wagdocuments/25/TES_Data_Product_Specification_V11.8_R11.1.pdf

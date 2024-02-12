%
%  This example code illustrates how to access and visualize
% GES DISC MLS L2GP HDF-EOS5 Swath file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MLS_Aura_L2GP_BrO_v04_23_c03_2016d302_he5
%
% Please note that there is no .m in the above command at the end.
%
% Tested Under:
% Tested under: MATLAB R2019b
% Last Update: 2019-11-04


% Open the HDF5 File.
FILE_NAME = 'MLS-Aura_L2GP-BrO_v04-23-c03_2016d302.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'HDFEOS/SWATHS/BrO/Data Fields/L2gpValue';
data_id = H5D.open (file_id, DATAFIELD_NAME);

% Open the dimension fields.
PRESSURE_NAME='HDFEOS/SWATHS/BrO/Geolocation Fields/Pressure';
pre_id=H5D.open(file_id, PRESSURE_NAME);

TIME_NAME='HDFEOS/SWATHS/BrO/Geolocation Fields/Time';
time_id=H5D.open(file_id, TIME_NAME);

% Read the dataset and dimension fields.
data1=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');

pressure=H5D.read(pre_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                  'H5P_DEFAULT');

time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
              'H5P_DEFAULT');

% Time is second from TAI93.
time1lvl=datestr(datevec(datenum(1993,1,1,0,0,0)+time(400)/86400));

% Convert 2-D data to 1-D data.
data=squeeze(data1(:,400));

% Read the units of data.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the units of pressure axis.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (pre_id, ATTRIBUTE);
units_pre = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missing value.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the title.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
titles = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (pre_id);
H5D.close (time_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Replace the missing value with NaN.
data(data==missingvalue) = NaN;

f = figure('Name', FILE_NAME, 'visible', 'off');
yunit = sprintf('%s', units_pre);
xunit = sprintf('%s', units);
name = sprintf('%s', titles);

% Read MLS Data Quality Document [1] for useful range in BrO data, 
% which is 3.2hPa - 10hPa.
% You can check Pressure variable values using HDFView.
semilogy(data(13:16), pressure(13:16));

% The value of 'Title' attributes is same as variable name.
% Thus, we skipped reading the 'Title' attribute.
ylabel(['Pressure (' yunit ')']);
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);


xlabel([name ' (' xunit ')']);

ax = gca;
ax.YDir = 'reverse';

title({FILE_NAME; [name ' at Time=' time1lvl]}, ... 
      'Interpreter', 'None', 'FontSize',16,'FontWeight','bold');

saveas(f, [FILE_NAME, '.m.png']);
exit;

% References
% [1] http://mls.jpl.nasa.gov/data/v4-2_data_quality_document.pdf

% 
%  This example code illustrates how to access and visualize GESDISC MEaSUREs
% Ozone swath HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2012a
% Last updated: 2012-10-17

clear

% Open the HDF5 File.
FILE_NAME = 'SBUV2-NOAA17_L2-SBUV2N17L2_2011m1231_v01-01-2012m0905t152911.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = '/SCIENCE_DATA/ProfileO3Retrieved';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='/GEOLOCATION_DATA/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LEVFIELD_NAME='/ANCILLARY_DATA/PressureLevels';
lev_id=H5D.open(file_id, LEVFIELD_NAME);

TIMEFIELD_NAME='nTimes';
time_id=H5D.open(file_id, TIMEFIELD_NAME);

% Get dataspace.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lev=H5D.read(lev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Release resources.
H5S.close (data_space)

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lat_id, ATTRIBUTE);
units_lat = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lev_id, ATTRIBUTE);
units_lev = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lat_id, ATTRIBUTE);
long_name_lat = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lev_id, ATTRIBUTE);
long_name_lev = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the valid range (min).
ATTRIBUTE = 'valid_min';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_min=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the valid range (max).
ATTRIBUTE = 'valid_max';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_max=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Set subset index.
i = 71;

% Convert 3-D data to 2-D data.
%data=squeeze(data1(:,:,i));

% Time is second from TAI93.
timelvl=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(1)/86400));
timelvl2=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(i)/ ...
                        86400));

% Convert type.
data = double(data);
lat = double(lat);

% Apply log scale along Y-axis get a better image.
lev = log10(double(lev));

% Transpose data to match the dimension.
%data = data';

% Replace the fill value with NaN.
data(data==double(fillvalue)) = NaN;

% Replace the invalid range values with NaN.
data(data < double(valid_min)) = NaN;
data(data > double(valid_max)) = NaN;

% Subset data.
lats = lat(1:i);
datas = data(:,1:i);

% Plot the data.
f = figure('Name', FILE_NAME, 'visible', 'off');

% Don't draw a line.
[ch,ch] = contourf(lats, lev, datas);
set(ch, 'edgecolor', 'none');

% Put colorbar.
colormap('Jet');
h = colorbar();


% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
unit_lat = sprintf('%s', units_lat);
name_lat = sprintf('%s', long_name_lat);
unit_lev = sprintf('%s', units_lev);
name_lev = sprintf('%s', long_name_lev);

% Draw unit.
set(get(h, 'title'), 'string', unit, ...
                  'FontSize', 16, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Set axis labels.
xlabel([name_lat ' (' unit_lat ')'], 'Interpreter', 'none'); 
ylabel([name_lev ' (' unit_lev ') in log_{10} scale']);

% Put title.
tstring = {FILE_NAME;name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% Put time strings outside plot at the right bottom corner.
ylim=get(gca,'YLim');
xlim=get(gca,'XLim');
text(xlim(2)+0.1, ylim(1)-0.1, {timelvl;timelvl2},...
     'VerticalAlignment','top', ...
     'HorizontalAlignment','left', ...
     'EdgeColor', 'black', 'LineWidth', 1, 'LineStyle', '-');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;
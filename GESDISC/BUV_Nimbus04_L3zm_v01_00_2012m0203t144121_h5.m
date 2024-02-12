% 
%  This example code illustrates how to access and visualize GESDISC MEaSUREs
% Ozone Zonal Average HDF5 file in MATLAB. 
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
FILE_NAME = 'BUV-Nimbus04_L3zm_v01-00-2012m0203t144121.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = '/Data_Fields/ProfileOzone';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME = '/Data_Fields/Latitude'; 
lat_id = H5D.open(file_id, LATFIELD_NAME);

LEVFIELD_NAME = '/Data_Fields/ProfilePressureLevels';
lev_id = H5D.open(file_id, LEVFIELD_NAME);

TIMEFIELD_NAME = '/Data_Fields/Date';
date_id = H5D.open(file_id, TIMEFIELD_NAME);

% Get dataspace.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lev=H5D.read(lev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
date=H5D.read(date_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
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


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Set subset index.
i = 1;

% Convert 3-D data to 2-D data.
data=squeeze(data(:,:,i));

% This product's time is not in TAI 1993 format. 
% It uses a 4+2 digit number that indicates year and month.
datelvl=date(i);

% Convert type.
data = double(data);
lat = double(lat);

% Apply log scale along Y-axis get a better image.
lev = log10(double(lev));

% Transpose data to match the dimension.
%data = data';

% Replace the fill value with NaN.
data(data==double(fillvalue)) = NaN;

% Plot the data.
f = figure('Name', FILE_NAME, 'visible', 'off');

% Don't draw a line.
[ch,ch] = contourf(lat, lev, data);
set(ch, 'edgecolor', 'none');

% Put colorbar.
colormap('Jet');
h = colorbar();


% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
% Also, trimming any blank spaces is necessary.
unit = deblank(sprintf('%s', units));
name = deblank(sprintf('%s', long_name));
unit_lat = deblank(sprintf('%s', units_lat));
name_lat = deblank(sprintf('%s', long_name_lat));
unit_lev = deblank(sprintf('%s', units_lev));
name_lev = deblank(sprintf('%s', long_name_lev));

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

% Put date strings outside plot at the right bottom corner.
date_str = sprintf('%d', datelvl);

ylim=get(gca,'YLim');
xlim=get(gca,'XLim');
text(xlim(2)+0.1, ylim(1)-0.1, ['Date:' date_str],...
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

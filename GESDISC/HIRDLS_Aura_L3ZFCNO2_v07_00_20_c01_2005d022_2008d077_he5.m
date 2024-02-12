%
%  This example code illustrates how to access and visualize GES DISC HIRDLS
%  Zonal Average HDF-EOS5 file in MATLAB. 
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
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r HIRDLS_Aura_L3ZFCNO2_v07_00_20_c01_2005d022_2008d077_he5
%
% Tested under: MATLAB R2019b
% Last updated: 2019-11-04

clear

% Open the HDF5 File.
FILE_NAME = 'HIRDLS-Aura_L3ZFCNO2_v07-00-20-c01_2005d022-2008d077.he5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = 'HDFEOS/ZAS/HIRDLS/Data Fields/NO2Ascending';
data_id = H5D.open(file_id, DATAFIELD_NAME);

LATFIELD_NAME='HDFEOS/ZAS/HIRDLS/Data Fields/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LEVFIELD_NAME='HDFEOS/ZAS/HIRDLS/Data Fields/Pressure';
lev_id=H5D.open(file_id, LEVFIELD_NAME);

TIMEFIELD_NAME='HDFEOS/ZAS/HIRDLS/Data Fields/Time';
time_id=H5D.open(file_id, TIMEFIELD_NAME);

NCO_NAME = 'HDFEOS/ZAS/HIRDLS/nCoeffs';
nco_id=H5D.open(file_id, NCO_NAME);
    
% Get dataspace.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the datasets.
data1=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lev=H5D.read(lev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
nco=H5D.read(nco_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Release resources.
H5S.close (data_space)

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lat_id, ATTRIBUTE);
units_lat = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lev_id, ATTRIBUTE);
units_lev = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title.
ATTRIBUTE = 'Title';
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

% Read the missingvalue.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Set subset index.
tdim = 1;

% Convert 4-D data to 2-D data.
data=squeeze(data1(1,:,:,tdim));

% Time is second from TAI93.
timelvl=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(tdim)/86400));

% Convert type.
data = double(data);
lat = double(lat);

% Transpose data to match the dimension.
data = data';

% Replace the fill value with NaN.
data(data==double(fillvalue)) = NaN;

% Replace the missing value with NaN.
data(data==double(missingvalue)) = NaN;

% Plot the data.
f = figure('Name', FILE_NAME, 'visible', 'off');
contourf(lat, lev, data);

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
            'Interpreter', 'none');

% Set axis labels.
xlabel([name_lat ' (' unit_lat ')'], 'Interpreter', 'none'); 
ylabel([name_lev ' (' unit_lev ')']);

% Put highest pressure at the bottom of Y-axis.
ax = gca;
ax.YDir = 'reverse';

% Apply log scale along Y-axis get a better image.
set(gca, 'YScale', 'log')

% Turn off scientific notation (e.g., 10^3) in Y-axis tick labels.
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);

% Put title.
tstring = {FILE_NAME;[strcat(name,' at ',timelvl,' and nCoeffs=', ...
                             string(nco(1)))]};
title(tstring, 'FontSize', 8, 'Interpreter', 'none');

% Save plot as PNG image.
saveas(f, [FILE_NAME '.m.png']);
exit;


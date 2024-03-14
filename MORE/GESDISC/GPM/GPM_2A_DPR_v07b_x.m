%
%  This example code illustrates how to access and visualize GPM L2 file
% in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%                                   
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r GPM_2A_DPR_v07b_x
%
% Tested under: MATLAB R2023b
% Last updated: 2024-03-14

% Open the HDF5 File.
FILE_NAME = '2A.GPM.DPR.V9-20211125.20231018-S150222-E163452.054761.V07B.HDF5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'FS/SLV/zFactorFinal';
data_id = H5D.open(file_id, DATAFIELD_NAME);

Lat_NAME = 'FS/Latitude';
lat_id = H5D.open(file_id, Lat_NAME);

Lon_NAME = 'FS/Longitude';
lon_id = H5D.open(file_id, Lon_NAME);

Alt_NAME = 'FS/PRE/height';
alt_id = H5D.open(file_id, Alt_NAME);

% Read the dataset.
data = H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat = H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');
lon = H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');
alt = H5D.read(alt_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue = H5A.read(attr_id, 'H5ML_DEFAULT');

                                   
% Read the units attribute.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');
H5A.close (attr_id)

attr_id = H5A.open_name(lon_id, ATTRIBUTE);
units_lon = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name(alt_id, ATTRIBUTE);
units_alt = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (lat_id);
H5D.close (lon_id);
H5D.close (alt_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Find indexes for the region of interest.
x = (lon > 68.7 & lon < 97.25 & ...
     lat > 8.4 & lat < 37.6 );
lon_s = lon(x);
lat_s = lat(x);
alt_s = alt(:,x);
data_s = data(:,:,x);

f=figure('Name', FILE_NAME, 'visible', 'off');

[lon_ss, I] = sort(lon_s);
[lon_v, I, J] = unique(lon_ss);

% Check alt values if they are close enough for each lat/lon point.
alt_s1 = squeeze(alt_s(:,1));
alt_s2 = squeeze(alt_s(:,2));

% They are close so we will use alt values 
% from the first lat/lon point.
% contourf() requires monotonic values for axis.
[alt_v, J] = sort(alt_s1);
data_v = squeeze(data_s(1,J,I));

contourf(lon_v, alt_v, data_v);
h = colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, 
% the characters in unit will appear in a vertical direction.
units_lon = sprintf("(%s)", units_lon(1:end-1));
units_hgt = sprintf("(%s)", units_alt(1:end-1));
units_zff = sprintf("(%s)", units(1:end-1));

xlabel([Lon_NAME units_lon]);
ylabel([Alt_NAME units_hgt]);

set (get(h, 'title'), 'string', units_zff, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');

name = [DATAFIELD_NAME, ' Ka(=red) band at India region'];

title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 10,'FontWeight','bold');
saveas(f, [FILE_NAME '.x.m.png']);
exit;

%
%  This example code illustrates how to access and visualize an
%  LaRC CALIPSO L2 HDF5 file in Octave.
%
%  If you have any questions, suggestions, comments on this example, please
% use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run
%
%  $octave CAL_LID_L2_BlowingSnow_Antarctica-Standard-V2-00.2023-06.hdf5.o.m
%
% Tested under: Octave 8.4.0
% Last updated: 2024-02-16

% pkg install -forge netcdf
pkg load netcdf

addpath ./m_map;

fname = 'CAL_LID_L2_BlowingSnow_Antarctica-Standard-V2-00.2023-06.hdf5';

% Use Octave's built-in HDF5 reader for reading datasets.
h5 = load(fname);
lat = h5.Geolocation_Fields.Latitude;
lon = h5.Geolocation_Fields.Longitude;
data = h5.Snow_Fields.Blowing_Snow_Depol_Profile;

% Although ncinfo() fails, reading attribute is fine.
long_name = 'Blowing_Snow_Depol_Profile';
units = ncreadatt(fname, '/Snow_Fields/Blowing_Snow_Depol_Profile', ...
                  'units');

% Remove a garbage character at the end.
units = units(1:end-1);

% Plot data.
clf;
colormap('jet');
m_proj('stereo', 'lat', -90, 'lon', 0, 'radius', 30);				
datas = data(1,:);				
m_scatter(lon, lat, 0.1, datas);
m_coast('color', 'black');
m_grid;
h = colorbar();

% Annotate the plot.
title_str = [fname '\n', long_name];
set(get(h, 'title'), 'string', units);
title(sprintf(title_str), 'Interpreter', 'None', 'FontSize', 10);
print('-dpng', '-r300', [fname, '.o.m.png']);

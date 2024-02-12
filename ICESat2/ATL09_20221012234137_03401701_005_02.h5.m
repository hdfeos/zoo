%
%  This example code illustrates how to access and visualize an
%  NSIDC ICESat-2 ATL09 L3A version 5.2 HDF5 file in Octave.
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
%  $octave ATL09_20221012234137_03401701_005_02.h5.m
% 
%
% Tested under: Octave 7.3.0
% Last updated: 2023-02-08

pkg install -forge netcdf
pkg load netcdf

addpath ./m_map;

fname = 'ATL09_20221012234137_03401701_005_02.h5';

% Use Octave's built-in HDF5 reader for reading data.
h5 = load(fname);
lat = h5.profile_1.high_rate.latitude;
lon = h5.profile_1.high_rate.longitude;
data = h5.profile_1.high_rate.apparent_surf_reflec;

% Although ncinfo() fails, reading attribute is fine.
long_name = ncreadatt(fname, '/profile_1/high_rate/apparent_surf_reflec', ...
                      'long_name')
units = ncreadatt(fname, '/profile_1/high_rate/apparent_surf_reflec', ...
                  'units')

% Remove a garbage character at the end.
long_name = long_name(1:end-1)
units = units(1:end-1)

% Plot data.
clf;
cmap =jet();

colormap(cmap);
m_proj('miller');
m_scatter(lon, lat, 1, data);
shading flat;
m_grid();
m_coast('color', 'black');
h = colorbar();

% Annotate the plot.
title_str = [fname '\n', long_name];
set(get(h, 'title'), 'string', units);
title(sprintf(title_str), 'Interpreter', 'None', 'FontSize', 10);
print('-dpng', '-r300', [fname, '.m.png']);

%> @file      startup.m
%> @brief     Matlab Environment Initialization.
%> @authors   Sameh Eldessoki (sameh.eldessoki[at]hhi.fraunhofer.de)
%> @date      20.04.2016
%>
%> @version   1.0
%> - Recursively add subdirectories,
%> - Check version Matlab,
%> - Check operation system.
%>
%> @copyright
%> Copyright 2011-2015 Fraunhofer Heinrich-Hertz-Institute (HHI)
%>
%> @details
%> Script is executed by Matlab if folder is choosen as startup folder. \n\n
%> @b References: \n
%> http://www.mathworks.de/help/techdoc/ref/startup.html

function startup()

startup_init();
startup_check();
startup_help();

end

%% subfunctions

function startup_init()

% Windows file seperator has to be escaped in regexp, therefor a backslash
% has to be written befor the windows backslash file seperator.
if ispc % Windows
    filesep_regexp = [filesep, filesep];
else
    filesep_regexp = filesep;
end

% Get path to this function, because further init is related to startuo path
full_fpath = mfilename('fullpath');
function_path = full_fpath(1:end-1-length(mfilename()));

% get path string that includes all the folders
% and subfolders below source_path, excluding /.svn, /.git, class-paths /@
% and package-paths /+.
addpath( [function_path, filesep, 'generic'] );
path_str = genpath( function_path );
path_str = generic_exclude_subpaths(path_str, {[filesep_regexp, '.svn'], [filesep_regexp, '.git']});

% add remaining sub paths
addpath( path_str );

end

function startup_check()

% indicate project requirements

%% check Matlab

correct_matlab_version = {};
correct_matlab_version{end+1} = '2013b';
correct_matlab_version{end+1} = '2014a';
correct_matlab_version{end+1} = '2014b';
correct_matlab_version{end+1} = '2015a';

matlab_version_string = version('-release');
is_correct_matlab_release = sum(strcmpi( matlab_version_string(1:5), correct_matlab_version ));

if ( ~is_correct_matlab_release  )
    warning([mfilename ':MatlabVersionNotSupported ', 'Please use ' strjoin(correct_matlab_version) ', otherwise some GUIs may not work.']);
end

%% check Operating System

if ~isunix % Is not Unix
%     warning([mfilename ':OSNotSupported ', 'This project has only been tested with Ubuntu LTS 12.04!']);

    if ispc % Windows
%         warning('Windows is only partly supported!');
    elseif ismac % Mac
        warning('Mac-OS is not supported!');
    else
        warning('This operating system is not supported!');
    end
end

%% check MATLAB

if verLessThan('matlab', '7.14')
    warning([mfilename ':MatlabVersionNotSupported ', 'This project has been tested with MATLAB version 7.14 (R2012a)']);
end

%% check Toolboxes

% check Signal Processing Toolbox
if verLessThan('signal', '6.17')
    warning([mfilename ':ToolboxVersionNotSupported ', 'This project has been tested with Signal Processing Toolbox version 6.17 (R2012a)']);
end

% check Communications System Toolbox
if verLessThan('comm', '5.2')
    warning([mfilename ':ToolboxVersionNotSupported ', 'This project has been tested with Communications System Toolbox version 5.2 (R2012a)']);
end

end

function startup_help()

% Usage help message
disp('---------------------------------------');
disp('Welcome to IDMA');

end

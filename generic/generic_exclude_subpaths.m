%> @file      generic_exclude_subpaths.m
%> @brief     Exclude Specific subpaths matching String.
%> @authors   Dennis Wieruch (dennis.wieruch[at]hhi.fraunhofer.de)
%> @date      09.03.2015
%>
%> @version   1.0
%> - Initial function, derived from part in generic_get_subpaths_ugly.m.
%>
%> <hr>
%> $LastChangedRevision: 402 $
%>     $LastChangedDate: 2015-05-06 10:58:51 +0200 (Mi, 06 Mai 2015) $
%>       $LastChangedBy: wieruch $
%>                 $URL: https://slig-svn.fe.hhi.de/svn/student_eldessoki/simulator/generic/generic_exclude_subpaths.m $
%>
%> @copyright
%> Copyright 2014-2015 Fraunhofer Heinrich-Hertz-Institute (HHI)
%
%
%> @brief   Exclude Specific subpaths matching String.
%>
%>	[ SUBPATHS ] = GENERIC_EXCLUDE_SUBPATHS( SUBPATHS, EXCLUDE_STRING ) \n
%>
%> @param[in]   SUBPATHS     String [1x?] \n
%>                  Sub paths concatenated and separated by Matlab
%>                   internal pathsep-function.
%> @param[in]   EXCLUDE_STRING   Cell with String {N}.[1x?] Optional \n
%>              	Exclude all sub paths which contain one of the strings
%>              	 in cell. \n
%>              	Default: No Strings are excluded. \n
%>
%> @param[out]  SUBPATHS  String [1x?] \n
%>                  Base path and all sub paths concatenated and separated
%>                   by Matlab internal pathsep-function. \n
%>
%> @details
%>  Keep in mind, that currently regexp symbols '^' and '$' cannot be used
%>   in this context. Therefor, you are always excluding strings matching
%>   any part of path or even part of a folder.
%>
%> <b> Example 01: </b>
%> @code
%>  subpaths = generic_get_subpaths(pwd);
%>  subpaths = generic_exclude_subpaths(subpaths, {'/.svn', '/.git'});
%> @endcode
%>
%> <b> Example 02: </b>
%> @code
%>  subpaths = generic_get_subpaths('.');
%>  subpaths = generic_exclude_subpaths(subpaths, {'/private', '/@', '/\+', '/.svn', '/.git'});
%> @endcode
%>
%> <b> Example 03: </b> Alternative to Example 02
%> @code
%>  subpaths = genpath( '.' );
%>  subpaths = generic_exclude_subpaths(subpaths, {'/.svn', '/.git'});
%> @endcode
%>
%> <b> Example 04: </b> (For Windows support of regexp)
%> @code
%>  if ispc % Windows
%>      filesep_regexp = [filesep, filesep];
%>  else
%>      filesep_regexp = filesep;
%>  end
%>
%>  subpaths = generic_get_subpaths('.');
%>  subpaths = generic_exclude_subpaths(subpaths, {[filesep_regexp, 'private'], [filesep_regexp, '@'], [filesep_regexp, '\+'], [filesep_regexp, '.svn'], [filesep_regexp, '.git']});
%> @endcode
%>
%> <b> Example 05: </b> Alternative to Example 04
%> @code
%>  if ispc % Windows
%>      filesep_regexp = [filesep, filesep];
%>  else
%>      filesep_regexp = filesep;
%>  end
%>
%>  subpaths = genpath( '.' );
%>  subpaths = generic_exclude_subpaths(subpaths, {[filesep_regexp, '.svn'], [filesep_regexp, '.git']});
%> @endcode
%>
function subpaths = generic_exclude_subpaths(subpaths, exclude_string)

% Add PATHSEP at begging and end of string for easier exclusion of strings.
subpaths = [pathsep subpaths pathsep];

% Exclusion do need to be processed, if no EXCLUDE_STRING is committed.
if nargin > 1
    % Exclude all paths containing EXCLUDE_STRING
    for idx = 1:length(exclude_string)
        expr_out = [ [ '[^' pathsep ']*' ] exclude_string{idx} [ '[^' pathsep ']*' ] pathsep ];
        subpaths = regexprep( subpaths, expr_out, '' );
    end
end

% Remove previous add of PATHSEP at begging and end of string.
subpaths = subpaths(2:end-1);

end % function


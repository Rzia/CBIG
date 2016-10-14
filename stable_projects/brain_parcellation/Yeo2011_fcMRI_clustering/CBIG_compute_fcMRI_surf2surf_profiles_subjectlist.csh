#!/bin/csh -f

# Author: Jingwei Li, Date: 2016/06/18

# Assume the order of subjects list and surface data list are the same, since the surface data list is created from subjects list by CBIG_create_subject_surf_list.csh

set VERSION = '$Id: CBIG_compute_fcMRI_surf2surf_profiles_subjectlist.csh, v 1.0 2016/06/18 $'

set sub_dir = "";
set subjects = "";
set surf_list = "";
set target = fsaverage5
set roi = fsaverage3
set scrub_flag = 0;

set PrintHelp = 0;
if( $#argv == 0 ) goto usage_exit;
set n = `echo $argv | grep -e -help | wc -l`
if( $n != 0 ) then
	set PrintHelp = 1;
	goto usage_exit;
endif
set n = `echo $argv | grep -e -version | wc -l`
if( $n != 0 ) then
	echo $VERSION
	exit 0;
endif

goto parse_args;
parse_args_return:

goto check_params;
check_params_return:

set root_dir = `python -c "import os; print os.path.realpath('$0')"`
set root_dir = `dirname $root_dir`

set sub_list = `cat $subjects`
if( $scrub_flag == 1 ) then
	set outlier_files = ("`cat $outlier_list`")
endif

set i = 1;
foreach surf ("`cat ${surf_list}`")
	set s = $sub_list[$i];
	set output_dir = "${sub_dir}/${s}/surf2surf_profiles"
	if( ! -d $output_dir ) then
		mkdir $output_dir
	endif
	set cmd = "${root_dir}/CBIG_compute_fcMRI_surf2surf_profiles.csh -sd ${sub_dir} -s ${s} -surf_data '${surf}' -target ${target} -roi ${roi} -output_dir ${output_dir}"
	if( $scrub_flag == 1 ) then
		set outlier = "$outlier_files[$i]"
		set cmd = "$cmd -outlier_files '$outlier'"
	endif
	echo $cmd
	eval $cmd
	@ i = $i + 1;
	#exit 0
end

exit 0

#############################
# parse arguments
#############################
parse_args:
set cmdline = "$argv";
while( $#argv != 0 )
	set flag = $argv[1]; shift;
	
	switch($flag)
		# subjects directory
		case "-sd":
			if( $#argv == 0 ) goto arg1err;
			set sub_dir = $argv[1]; shift;
			breaksw

		# subject list
		case "-sub_ls":
			if( $#argv == 0 ) goto arg1err;
			set subjects = $argv[1]; shift;
			breaksw

		# surface data list
		case "-surf_ls":
			if( $#argv == 0 ) goto arg1err;
			set surf_list = $argv[1]; shift;
			breaksw
			
		# outlier files list
		case "-outlier_ls":
			if( $#argv == 0 ) goto arg1err;
			set outlier_list = $argv[1]; shift;
			set scrub_flag = 1
			breaksw
			
		# target resolution
		case "-target":
			if( $#argv == 0 ) goto arg1err;
			set target = $argv[1]; shift;
			breaksw
			
		# ROI resolution
		case "-roi":
			if( $#argv == 0 ) goto arg1err;
			set roi = $argv[1]; shift;
			breaksw

		default:
			echo "ERROR: Flag $flag unrecognized."
			echo $cmdline
			exit 1;
			breaksw
	endsw
end

goto parse_args_return;


############################
# check parameters
############################
check_params:

if( $#sub_dir == 0 ) then
	echo "ERROR: subjects directory not specified."
	exit 1;
endif

if( $#subjects == 0 ) then
	echo "ERROR: subject list not specified."
	exit 1;
endif

if( $#surf_list == 0 ) then
	echo "ERROR: surface data list not specified."
	exit 1;
endif

goto check_params_return;


###########################
# Error message
###########################
arg1err:
  echo "ERROR: flag $flag requires one argument"
  exit 1;


###########################
# Usage exit
###########################
usage_exit:
	
	echo ""
	echo "USAGE: CBIG_compute_fcMRI_surf2surf_profiles_subjectlist.csh"
	echo ""
	echo "  Required arguments"
	echo "    -sd          sub_dir      : fMRI subejcts directory"
	echo "    -sub_ls      sub_list     : subjects list"
	echo "    -surf_ls     surf_list    : surface data list, created by 'CBIG_create_subject_surf_list.csh'"
	echo ""
	echo "  Optional arguments"
	echo "    -outlier_ls  outlier_list : motion outliers files list"
	echo "    -target        target     : the resolution of clustering (default is fsaverage5)"
	echo "    -roi           roi        : the resolution of ROIs (defaule is fsaverage3)"
	echo ""

	if ( $PrintHelp == 0 ) exit 1
	echo $VERSION
	
	cat $0 | awk 'BEGIN{prt=0}{if(prt) print $0; if($1 == "BEGINHELP") prt = 1 }'

exit 1

#-------- Everything below is printed as part of help --------#
BEGINHELP

  Given a subjects list, this function calls 'CBIG_compute_fcMRI_surf2surf_profiles.csh' for each subject to compute functional connectivity profiles on surface.
  It also needs a surface data list, which is created by 'CBIG_create_subject_surf_list.csh' based on the subjects list. Therefore, the ordering of subjects in subjects list and surface data list must be the same.
  The motion outliers files list is optional. It is also generated by 'CBIG_create_subject_surf_list.csh', if needed. If motion outliers files list is passed in, the high motion frames will be ignored when computing functional connectivity. High motion frames are indicated by '0' in motion outliers files.
  

#! /bin/bash

#######################################################################
#
# $1 -u
# $2 means,u need input repo url
#
# Usage(example): 
# single url run：sh x.sh -u url
# more   url run：sh x.sh -u url01@url02@url03 
#
# New，just support  the following repo url:
# 1）http://vault.centos.org/7.8.2003/extras/Source/SPackages/
# 2）http://vault.centos.org/7.8.2003/os/Source/SPackages/
# 3）http://vault.centos.org/7.8.2003/updates/Source/SPackages/
#
######################################################################

while [ "$1" != "" ]
do
   case $1 in
       -u) URL=$2 ;         shift;;
       *) echo  "unknown option $1" ;;
   esac
   shift
done

get_pkg_list (){
   for os_url  in $(echo $URL | sed 's/@/ /g')
   do
       echo "$os_url"
       #download url html info :
       > html
       curl $os_url -o html
       
       > first_list
       cat html | while read line
       do     
               rpm_list=$(echo $line |awk '/src.rpm/'  | sed -e "s@\"@ @g" -e "s@>@ @g"  -e "s@<@ @g" | awk '{print $19}')
               rpm_date=$(echo $line |awk '/src.rpm/'  | sed -e "s@\"@ @g" -e "s@>@ @g"  -e "s@<@ @g" | awk '{print $26,$27}')
               [ -n "$rpm_list" ] && [ -n "$rpm_date" ] &&  echo  "$rpm_date    $rpm_list" >> first_list
       done 

   rename_list_file
   done
}


#rename list file for each source url:
rename_list_file (){
    echo "$os_url" | grep -sq "\/updates\/" && \
                              mv first_list 7.8.2003-updates-src
   
    echo "$os_url" | grep -sq "\/os\/" &&  \
                              mv first_list 7.8.2003-os-src

    echo "$os_url" | grep -sq "\/extras\/" &&  \
                              mv first_list 7.8.2003-extras-src
}

clean_before_run (){
   rm -rf 7.8.2003-updates-src 7.8.2003-os-src 7.8.2003-extras-src html first_list
}



#start here:
clean_before_run
get_pkg_list


###############################  introduce 该脚本用法说明  ##################################################


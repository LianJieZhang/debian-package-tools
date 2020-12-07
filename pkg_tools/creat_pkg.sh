set -e

source_name=$1
rpm_pkg_link=$2

cur_dir=`pwd`

source_dir=$cur_dir/$source_name
uos_dir=$source_dir/uos/

mkdir $source_dir
mkdir $uos_dir

# download uos source code
cd $uos_dir
apt source $source_name


# download euler rpm source code
if [ ! $rpm_pkg_link ]
then
        echo "warnning: no euler rpm source code" 
	mv $uos_dir/* $source_dir
        exit
fi

cd $source_dir

wget $rpm_pkg_link

rpm2cpio *.src.rpm    |cpio -di 

# copy uos source code  debian for euler rpm

for i in `ls $uos_dir`
do
	sub_dir=$uos_dir$i
	if [ -d $sub_dir ]
	then
		cp -r $sub_dir/debian $source_dir
	fi
done

# update patches
if [ -d $source_dir/debian/patches ]
then 
	rm -rf $source_dir/debian/patches
fi

patch_files=`ls *.patch`
if [ $? -eq 0 ]
then
	echo $patch_files
	mkdir $source_dir/debian/patches
	mv $patch_files  $source_dir/debian/patches/
	cat *.spec | grep ^Patch| grep \.patch	| awk -F ' ' '{print $2}' > $source_dir/debian/patches/series
	if [ $? -ne 0 ]
	then
		echo "Error: patch failed"	
	fi
fi


# modify pkg name





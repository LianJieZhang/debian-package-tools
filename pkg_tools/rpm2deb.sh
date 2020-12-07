
pkgname=$1 
rpmlink=$2

curdir=`pwd`


workdir=$curdir/$pkgname
uosdir=$curdir/$pkgname-uos


mkdir $workdir
mkdir $uosdir


# 进入uos目录
cd $uosdir

apt source $pkgname >/dev/null 2>&1 

if [ $? -ne 0 ]
then
	echo "$0: download uos source failed"
	exit 1
fi

# 查找具体的源码目录
for i in `ls $uosdir`
do
        uos_sub_dir=$uosdir/$i
        if [ -d $uos_sub_dir ]
        then
                uos_src_dir=$uos_sub_dir
        fi
done

# 进入rpm目录
cd $workdir
wget $rpmlink

# 解压rpm
rpm2cpio *.src.rpm |cpio -di

#修改changelog
rpm_name=`ls *.src.rpm|awk -F '-' '{print $1}'`
rpm_version=`ls *.src.rpm| grep -Po "\-\d+.*\-\d+"|grep -Po "\d+.*"`
cp -r $uos_src_dir/debian  $workdir

#获取uos源码包名
uos_srcname=`apt-cache madison $pkgname | grep uos|grep Sources| awk -F ' ' '{print $1}'  2>/dev/null |sort|uniq`
if [ -z "$uos_srcname" ]
then
	echo "$0: uos source name is null"
	exit 1
fi

cp $workdir/debian/changelog /tmp/$pkgname.changelog

cat >$workdir/debian/changelog <<EOF
$uos_srcname ($rpm_version) unstable; urgency=medium

  * pkg from rpm.

 -- UOS Developer <zhanglianjie@uniontech.com>  Tue, Sep 22 08:18:33 UTC 2020

EOF

cat /tmp/$pkgname.changelog >> $workdir/debian/changelog

# 处理patch文件
ls  $workdir/debian/patches >/dev/null 2>&1
if [ $? -eq 0 ]
then
	rm -rf   $workdir/debian/patches
fi

ls *.patch >/dev/null 2>&1
if [ $? -eq 0 ] 
then
	mkdir $workdir/debian/patches
	cp *.patch  $workdir/debian/patches
	cat *.spec| grep ^Patch|awk -F ' ' '{print $2}' >$workdir/debian/patches/series
fi

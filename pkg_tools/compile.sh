set -e
srcname=$1
workdir=/home/uos/zlj/euler/auto_genernal
srcdir=$workdir/$srcname


mkdir $srcdir

cd $srcdir

apt source $srcname


for i in `ls $srcdir`
do
        sub_dir=$srcdir/$i
        if [ -d $sub_dir ]
        then
                compiledir=$sub_dir
        fi
done

cd $compiledir


sudo apt build-dep $srcname  -y

dpkg-buildpackage -us -uc -sa -j8

cd $srcdir

#dput -u  eulerone *.changes 
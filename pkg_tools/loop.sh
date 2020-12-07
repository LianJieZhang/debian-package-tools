pkgfile=$1
  
>2.txt
>2.orig.txt
for pkgname in `cat $pkgfile`
do
        sh findrpm/find_pkg.sh findrpm/rpm.list  findrpm/35.list $pkgname 1>&2
        if [ $? -eq 0 ]
        then
                srcname=`apt-cache madison $pkgname | grep Sources| awk -F ' ' '{print $1}'  2>/dev/null`
                echo $srcname >> 2.txt
                sh compile.sh $srcname 2>&1 >/dev/null
                if [ $? -ne 0 ]
                then
                        echo "compile $pkgname failed!"
                else
                        echo $srcname >> 2.orig.txt
                fi



        fi
done
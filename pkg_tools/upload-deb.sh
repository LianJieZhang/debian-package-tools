pkgname=$1
ls -l $pkgname
if [ $? -eq 0 ]
then
        echo "error: $pkgname exist!" 
        exit
fi

sudo cp -r  runOs/base-sys2/root/$1   /home/zlj/euler/ 

sudo chown -R zlj:zlj /home/zlj/euler/$pkgname

ls -l /home/zlj/euler/$pkgname

dput -u eulerone /home/zlj/euler/$pkgname/*.changes 

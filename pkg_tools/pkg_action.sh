set -e
mkdir $1
cd $1
apt source $1
sudo pbuilder --build  --logfile log.txt --basetgz ~/base.tgz --allow-untrusted --hookdir /var/cache/pbuilder/hooks --use-network yes --aptcache "" --buildresult . --debbuildopts -sa *.dsc

dput -u eulerone  $1/*.changes 

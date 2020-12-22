sudo umount $1/proc
sudo umount $1/dev/pts
sudo umount $1/dev/shm
sudo umount $1/sys
if [ $2 ]
then
        exit
fi
sudo mount proc-live -t proc $1/proc
sudo mount devpts-live -t devpts -o gid=5,mode=620 $1/dev/pts
sudo mount --bind /dev/shm $1/dev/shm
sudo mount sysfs-live -t sysfs $1/sys
sudo chroot $1


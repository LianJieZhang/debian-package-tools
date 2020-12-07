rm -rf /tmp/dep_soft.txt
rm -rf /tmp/dep_txt
rm -rf /tmp/35_exist.txt
rm -rf /tmp/35_exist_filter.txt

echo "$1" > /tmp/total.txt

while read -r soft
do
	##寻找依赖
	apt-cache showsrc $soft > /tmp/dep.txt

	##从log文件查看是否有依赖软件包1
	DEP=`cat /tmp/dep.txt |  grep "Build-Depends:"`
	echo $DEP | awk -F 'Build-Depends:' '{printf("%s\n",$2)}' >> /tmp/dep_soft.txt
	sed -i 's/, /\n/g' /tmp/dep_soft.txt;  sed  -i  's/\n/\n\r/g' /tmp/dep_soft.txt; sed -i '/^$/d' /tmp/dep_soft.txt; sed -i 's/(.*)//g' /tmp/dep_soft.txt;sed -i 's/\[.*\]//g' /tmp/dep_soft.txt;sed -i 's/<.*>//g' /tmp/dep_soft.txt;sed -i 's/ | /\n\r/g' /tmp/dep_soft.txt


	##如果该软件包已经存在，则删除
	while read -r line
	do
	        sed -i "/$line/d" /tmp/dep_soft.txt
	done < /tmp/total.txt


	##寻找软件包是否在35仓库中存在。##如果软件包在仓库中存在，则删除。不再继续寻找该包的依赖。
	while read -r line
	do
	    apt-cache madison $line 2>&1 | grep "mouse1">> /dev/null

	    if [ $? -eq 0 ]
	    then
			    sed -i "/$line/d" /tmp/dep_soft.txt
		fi

	done < /tmp/dep_soft.txt

	##添加到total中。
	cat /tmp/dep_soft.txt >> /tmp/total.txt

	rm -rf /tmp/35_exist_filter.txt
	rm -rf /tmp/dep_soft.txt

	cd $pwd_cur
done < /tmp/total.txt

#dpkg -i *.deb
#dput -u eulerone *.changes

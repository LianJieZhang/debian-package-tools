
cat >/etc/apt/sources.list <<EOF
deb [trusted=yes] http://10.20.32.35/mouse1 mouse1 main
deb-src [trusted=yes] http://10.20.32.35/mouse1 mouse1 main
EOF

apt update   >/dev/null  2>&1

apt list > 35.list

cat >/etc/apt/sources.list <<EOF
deb [trusted=yes] http://10.20.32.35/mouse1 mouse1 main
deb-src [trusted=yes] http://10.20.32.35/mouse1 mouse1 main

deb http://pools.corp.deepin.com/uos eagle main contrib non-free
deb-src http://pools.corp.deepin.com/uos eagle main contrib non-free
EOF

apt update  >/dev/null  2>&1
> result.log


find_depends_version() {
    packagename=$1
    local dependpath=$2

    dep_str1=`apt-cache showsrc $packagename |  grep "Build-Depends:"| awk -F 'Build-Depends:' '{printf("%s\n",$2)}' |sed -e 's/([^(,)]*)//g' -e 's/\[[^]]*\]//g' -e 's/<[^>]*>//g' -e 's/|/,/g' `
    dep_str2=`apt-cache showsrc $packagename |  grep "Build-Depends-Indep:"| awk -F 'Build-Depends-Indep:' '{printf("%s\n",$2)}' |sed -e 's/([^(,)]*)//g' -e 's/\[[^]]*\]//g' -e 's/<[^>]*>//g' -e 's/|/,/g' `

    dep_str=$dep_str1,$dep_str2

    if [ -z "$dep_str" ]
    then
        echo "$dependpath->$packagename" >> result.log
    fi

    for i in `echo $dep_str| awk -F ',' '{for(i=1;i<=NF;i++) print $i}'`
    do
        local subname=$i
        # 是否已经在文件中了，防止重复查找这个包的依赖
        cat result.log| grep "\->$subname\->"  >> /dev/null
        if [ $? -eq 0 ]
        then
            echo "$dependpath->$subname   find depends loop in file" >>result.log
            continue
        fi

        #apt-cache madison $subname 2>&1 | grep Source |grep "mouse1" >> /dev/null
        grep ^$subname\/ 35.list 2>&1 >> /dev/null
        if [ $? -ne 0 ]
        then
            echo $dependpath| grep "$subname\->"  >> /dev/null
            if [ $? -eq 0 ]
            then
                echo "$dependpath->$subname   find depends loop" >> result.log
            else
                find_depends_version $subname "$dependpath->$subname"
            fi
        else
            echo "$dependpath found in mouse1" >&2  >>result.log
        fi
    done
}



find_depends_version $1 $1
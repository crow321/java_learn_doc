#!/bin/sh

function scandir() {
    local cur_dir parent_dir workdir mod_count
    workdir=$1
    cd ${workdir}
    if [ ${workdir} = "/" ]
    then
        cur_dir=""
    else
        cur_dir=$(pwd)
    fi
    mod_count=0
    for dirlist in $(ls ${cur_dir}|grep -rl 'D:\/workplace\/PyTest-frame\/qtec.conf')
    do
        if test -d ${dirlist};then
            cd ${dirlist}
            scandir ${cur_dir}/${dirlist}
            cd ..
        else
            mod_count=$[${mod_count}+1]
            echo "mod_count---${mod_count} :"${cur_dir}/${dirlist}
            #grep -rl 'D:\/workplace\/PyTest-frame\/qtec.conf' ${dirlist} | xargs sed -i 's/D:\/workplace\/PyTest-frame\/qtec.conf/\/home\/qkcl\/PyTest-frame\/qtec.conf/g' ${dirlist}
            grep -rl '\/home\/qkcl\/PyTest-frame\/qtec.conf' ${dirlist} | xargs sed -i 's/\/home\/qkcl\/PyTest-frame\/qtec.conf/\/usr\/local\/lib\/python2.7\/site-packages\/linuxPy\/qtec.conf/g' ${dirlist}

        fi
    done
}

if test -d $1
then
    scandir $1
elif test -f $1
then
    echo "you input a file but not a directory,pls reinput and try again"
    exit 1
else
    echo "the Directory isn't exist which you input,pls input a new one!!"
    exit 1
fi
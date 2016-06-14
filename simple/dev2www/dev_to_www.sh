#!/bin/bash

#Author By zhangwentao<wentmac@vip.qq.com>
#自动部署脚本，根据ssh key配合rsync 
#支持记录每次的同步日志记录
#支持每次同步前自动备份旧文件
#支持根据一个文档中的文件列表来同步文件
#支持排除文件

###ssh端口号###
SSH_PORT=1204
TT=`date +%Y%m%d-%T`
timeLog=`date +\%Y-\%m-\%d`
#current_dir=$(pwd)
current_dir=/root/dev2www/
###定义同步日志文件路径###
rsync_log_dir=${current_dir}log/rsync_update/
###判断同步日志的目录是否存在，不存在创建###
test ! -d "$rsync_log_dir" && mkdir -p "$rsync_log_dir"
###定义rsync的命令位置###
rsync=/usr/bin/rsync
###定义需要排除的目录###
excludeDir=${current_dir}'excludeFile.txt'
###定义开发环境的ip###
web_test_ip="12.134.118.125 "
###同步菜单选择###
PS3="请选择您要更新到的项目，1:部署{project_name}到测试环境代码[测试]  2:退出 ==>"; export PS3

#开始写日志函数
function startLog()
{
    echo "---------------rsync start--------$(date +%T)------------------------" | tee -a $1
}

#结束写日志函数
function endLog()
{
    echo "---------------rsync end----------$(date +%T)------------------------" | tee -a $1
}

select COMPONENT in www.weixinshow.com quit
do
        case $COMPONENT in
        www.weixinshow.com)
            time=`date +\%Y/\%m/\%d/\%H_\%M`
            ###定义同步日志文件名###
            rsync_log_file="$rsync_log_dir"${COMPONENT}-${timeLog}.log
            ###定义要同步的远程服务器的目录路径（必须是绝对路径）###
            clientPath=/var/www/weixinshow/release_1.0/
            ###定义要同步的远程服务器的目录备份路径（必须是绝对路径）###
            CLIENT_BACKUP_DIR='/var/www/rsync/bak/'${COMPONENT}'/'${time}'/'
            ###定义要镜像的本地文件目录路径 源服务器（必须是绝对路径）###
            serverPath=/var/www/rsync/wwwroot/weixinshow_dev/trunk/
            ###定义ssh auto key的文件###
            ID_RSA=${current_dir}'auth_key/id_rsa_rsync.rsa'
            ###定义ssh auto username###            
            ID_RSA_USER=www-rsync
            ###定义根据一个文档中的文件列表来同步文件###
            rsync_file_list=${current_dir}'rsync_file_list.txt'

            cd ${serverPath}
            svn up > ${rsync_file_list}
            ###删除第一行Updateing:的提示###
            sed -i '1d' ${rsync_file_list}
            ###删除最后1行的svn提示信息###            
            sed -i '$d' ${rsync_file_list}
            ###替换每一行前面的U    字符串###            
            sed -i 's/^.....//' ${rsync_file_list}
            vim ${rsync_file_list}
            ####输入开始时间到同步日志####
            startLog $rsync_log_file
            for j in $(echo ${web_test_ip})
            do
                ####定义rsync的主要参数####                
                echo '正在部署服务器'${j} | tee -a $rsync_log_file
                ###判断同步日志的目录备份是否存在，不存在创建###                                
                ssh -p ${SSH_PORT} -i ${ID_RSA} ${ID_RSA_USER}@${j} "test ! -d "${CLIENT_BACKUP_DIR}" && mkdir -p "${CLIENT_BACKUP_DIR}
                ### 同步 ###
                rsync -avz --progress --backup --backup-dir=${CLIENT_BACKUP_DIR} --exclude-from "$excludeDir" --files-from=${rsync_file_list} $serverPath -e "ssh -p "${SSH_PORT}" -i "${ID_RSA} ${ID_RSA_USER}@${j}:$clientPath 2>&1 | tee -a $rsync_log_file
            done
            ####输入结束时间到同步日志####
            endLog $rsync_log_file
        ;;

                quit)
                        exit 0
                ;;
                *) echo "ERROR:Invalid selection,$REPLY." ;;
                esac
done
exit 0


####删除3天前的同步日志####
#cd "$rsync_log_dir"
#yes|find . -name "*.log" -type f -mtime 3 |xargs rm  -rf
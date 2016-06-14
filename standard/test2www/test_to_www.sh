#!/bin/bash

#Author By zhangwentao<wentmac@vip.qq.com> 支持测试环境全量上线到生产环境
#自动部署脚本，根据ssh key配合rsync 
#支持记录每次的同步日志记录
#支持每次同步前自动备份旧文件
#支持根据一个文档中的文件列表来同步文件
#支持排除文件

###ssh端口号###
SSH_PORT=22
TT=`date +%Y%m%d-%T`
timeLog=`date +\%Y-\%m-\%d`
#current_dir=$(pwd)'/'
current_dir=/home/zhangwentao/test_to_www/
###定义同步日志文件路径###
rsync_log_dir=${current_dir}log/rsync_update/
###判断同步日志的目录是否存在，不存在创建###
test ! -d "$rsync_log_dir" && mkdir -p "$rsync_log_dir"
###定义rsync的命令位置###
rsync=/usr/bin/rsync
###定义需要排除的目录###
excludeDir=${current_dir}'excludeFile.txt'
###定义开发环境的ip###
#web_test_ip="114.103.113.121 "
###定义生产环境的ip###
web_ip=(111.140.43.114 42.18.110.151)
#web_ip=(192.168.0.242)
###定义生产环境的port###
web_ip_port=(1204 1204)
#web_ip_port=(22)

###定义 住哪下单项目 生产环境的ip###
web_order_ip=(192.168.0.245 192.168.0.240 192.168.0.241)
###定义生产环境的port###
web_order_ip_port=(22 22 22)

###定义 住哪静态资源 生产环境的ip###
web_static_ip=(192.168.0.239)
###定义生产环境的port###
web_static_ip_port=(22)

###同步菜单选择###
PS3="请选择您要更新到的项目，1:部署住哪网主站(index,hotellist,hotel) 2:部署住哪下单项目 3:住哪css,js,images静态资源项目 4:退出 ==>"; export PS3


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

select COMPONENT in zhuna_www zhuna_order zhuna_static quit
do
	case $COMPONENT in          
        zhuna_www)     
            time=`date +\%Y/\%m/\%d/\%H_\%M`
            ###定义同步日志文件名###
            rsync_log_file="$rsync_log_dir"${COMPONENT}-${timeLog}.log
            ###定义要同步的远程服务器的目录路径（必须是绝对路径）###
            clientPath=/var/www/www.zhuna.cn/release_1.0/
            ###定义要同步的远程服务器的目录备份路径（必须是绝对路径）###
            CLIENT_BACKUP_DIR='/var/www/rsync/bak/'${COMPONENT}'/'${time}'/'            
            ###定义要镜像的本地文件目录路径 源服务器（必须是绝对路径）###
            serverPath=/var/wwwroot/www.zhuna.cn/release_1.0/
            ###定义ssh auto key的文件###
            ID_RSA=${current_dir}'auth_key/id_rsa_zhuna.rsa'
            ###定义ssh auto username###
            ID_RSA_USER=www-rsync            
			###定义需要指定的目录###
			include_rules=${current_dir}'rsync_rules_zhuna_www.txt'
            ####输入开始时间到同步日志####
            startLog $rsync_log_file
            web_ip_count=${#web_ip[@]}
            for ((i=0; i<web_ip_count; ++i))
            do                                
                ####定义rsync的主要参数####
				ip=${web_ip[i]}
				port=${web_ip_port[i]}
                echo '正在部署服务器'${ip} | tee -a $rsync_log_file 
                ###判断同步日志的目录备份是否存在，不存在创建###
                ssh -p ${port} -i ${ID_RSA} ${ID_RSA_USER}@${ip} "test ! -d "${CLIENT_BACKUP_DIR}" && mkdir -p "${CLIENT_BACKUP_DIR}
                ### 同步 ###
                rsync -avz --progress --backup --backup-dir=${CLIENT_BACKUP_DIR} --delete --delete-after --exclude-from=${excludeDir} --include-from=${include_rules} $serverPath -e "ssh -p "${port}" -i "${ID_RSA} ${ID_RSA_USER}@${ip}:$clientPath 2>&1 | tee -a $rsync_log_file
            done                           
            ####输入结束时间到同步日志####
            endLog $rsync_log_file            
        ;;          
               		
	zhuna_order)
            time=`date +\%Y/\%m/\%d/\%H_\%M`
            ###定义同步日志文件名###
            rsync_log_file="$rsync_log_dir"${COMPONENT}-${timeLog}.log
            ###定义要同步的远程服务器的目录路径（必须是绝对路径）###
            clientPath=/var/www/www.zhuna.cn/release_1.0/
            ###定义要同步的远程服务器的目录备份路径（必须是绝对路径）###
            CLIENT_BACKUP_DIR='/var/www/rsync/bak/'${COMPONENT}'/'${time}'/'            
            ###定义要镜像的本地文件目录路径 源服务器（必须是绝对路径）###
            serverPath=/var/wwwroot/www.zhuna.cn/release_1.0/
            ###定义ssh auto key的文件###
            ID_RSA=${current_dir}'auth_key/id_rsa_zhuna.rsa'
            ###定义ssh auto username###
            ID_RSA_USER=www-rsync
            ###定义需要指定的目录###
			include_rules=${current_dir}'rsync_rules_zhuna_order.txt'
            ####输入开始时间到同步日志####
            startLog $rsync_log_file
            web_ip_count=${#web_order_ip[@]}
            for ((i=0; i<web_ip_count; ++i))
            do                                
                ####定义rsync的主要参数####
				ip=${web_order_ip[i]}
				port=${web_order_ip_port[i]}
                echo '正在部署服务器'${ip} | tee -a $rsync_log_file 
                ###判断同步日志的目录备份是否存在，不存在创建###
                ssh -p ${port} -i ${ID_RSA} ${ID_RSA_USER}@${ip} "test ! -d "${CLIENT_BACKUP_DIR}" && mkdir -p "${CLIENT_BACKUP_DIR}
                ### 同步 ###
                rsync -avz --progress --backup --backup-dir=${CLIENT_BACKUP_DIR} --delete --delete-after --exclude-from=${excludeDir} --include-from=${include_rules} $serverPath -e "ssh -p "${port}" -i "${ID_RSA} ${ID_RSA_USER}@${ip}:$clientPath 2>&1 | tee -a $rsync_log_file
            done                           
            ####输入结束时间到同步日志####
            endLog $rsync_log_file 
        ;;        

	zhuna_static)
            time=`date +\%Y/\%m/\%d/\%H_\%M`
            ###定义同步日志文件名###
            rsync_log_file="$rsync_log_dir"${COMPONENT}-${timeLog}.log
            ###定义要同步的远程服务器的目录路径（必须是绝对路径）###
            clientPath=/var/www/www.zhuna.cn/release_1.0/
            ###定义要同步的远程服务器的目录备份路径（必须是绝对路径）###
            CLIENT_BACKUP_DIR='/var/www/rsync/bak/'${COMPONENT}'/'${time}'/'            
            ###定义要镜像的本地文件目录路径 源服务器（必须是绝对路径）###
            serverPath=/var/wwwroot/www.zhuna.cn/release_1.0/
            ###定义ssh auto key的文件###
            ID_RSA=${current_dir}'auth_key/id_rsa_zhuna.rsa'
            ###定义ssh auto username###
            ID_RSA_USER=www-rsync
            ###定义需要指定的目录###
			include_rules=${current_dir}'rsync_rules_zhuna_static.txt'
            ####输入开始时间到同步日志####
            startLog $rsync_log_file
            web_ip_count=${#web_static_ip[@]}
            for ((i=0; i<web_ip_count; ++i))
            do                                
                ####定义rsync的主要参数####
				ip=${web_static_ip[i]}
				port=${web_static_ip_port[i]}
                echo '正在部署服务器'${ip} | tee -a $rsync_log_file 
                ###判断同步日志的目录备份是否存在，不存在创建###
                ssh -p ${port} -i ${ID_RSA} ${ID_RSA_USER}@${ip} "test ! -d "${CLIENT_BACKUP_DIR}" && mkdir -p "${CLIENT_BACKUP_DIR}
                ### 同步 ###
                rsync -avz --progress --backup --backup-dir=${CLIENT_BACKUP_DIR} --delete --delete-after --exclude-from=${excludeDir} --include-from=${include_rules} $serverPath -e "ssh -p "${port}" -i "${ID_RSA} ${ID_RSA_USER}@${ip}:$clientPath 2>&1 | tee -a $rsync_log_file
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

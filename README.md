# www_sync
网站自动化上线部署shell,解决了网站开发过程中的上线烦恼。传统ftp上线效率低下还容易出错，多台web主机的时候更是恶梦.实现一键完成上线部署。
自带上线修改文件备份，方便回档，有后悔药吃咯~

# 使用说明

## 简单版(simple)
用于小型站点。没有测试环境的，只能本地开发环境和生产环境。
使用方法：
### 在开发机中执行
	bash /root/simple/dev2www/dev_to_www.sh
按1后回车。会有一个待上线的文件列表，可以选择需要上线的文件按:wq保存后，这样就要上线的代码文件直接同步到生产环境中了。
同时产生一份修改文件的备份。
## 标准版（standard）
用于（本地开发环境，线上测试环境，线上生产环境）这种中型项目的。
先从开发机上线到测试机，测试没问题后，再从测试机上到生产机中。
使用方法：
### 在开发机中执行
	bash /root/standard/dev2test/dev_to_test.sh 
从开发机本次有修改的文件列表中选择中需要上线的文件，上线到测试环境中去测试。
### 测试没问题
### 在测试机中执行
	bash /root/standard/test2www/test_to_www.sh 
从测试机中把本次测试的文件上线到线上（N台）web server中。

# 原理
## 在开发机上使用了Svn co的命令行，取得每次更新的文件列表
## 拿文件列表使用rsync配合sshkey证书同步到远程服务器指定的项目目录中，并且指定好备份文件策略。

# 服务器需要配置的

	* 服务器机群中的操作
	* 
		* useradd -d /home/www-rsync -m -s /bin/bash -g www-data www-rsync
		* chmod -R 700 /home/www-rsync
		* mkdir -p /home/www-rsync/.ssh/
		* chown www-rsync:www-data -R /var/www/www.zhuna.cn/release_1.0/
		* mkdir -p /var/www/rsync/bak/
		* chown -R www-rsync:root /var/www/rsync/bak/
		* chmod -R 700 /var/www/rsync/bak/



	* 上传机上的操作
	* 
		* mkdir -p /root/sshkey/www-rsync/
		* ssh-keygen -t rsa
		* /root/sshkey/www-rsync/id_rsa
		* cat id_rsa.pub >> authorized_keys
		* scp -i /root/sshkey/id_rsa -r /root/sshkey/www-rsync/authorized_keys root@192.168.0.238:/home/www-rsync/.ssh/
		* 测试是否能登录web机群成功
		* 
			* ssh -i /root/sshkey/www-rsync/id_rsa www-rsync@192.168.0.247

	* 建立同步备份目录，并给权限
	* chown -R www-rsync:root /var/www/rsync/bak/
	* chmod -R 700 /var/www/rsync_bak/








chown www-rsync:www-data -R /var/www/www.kuailezu.com/release_1.4/
chmod -R 650 /var/www/www.kuailezu.com/release_1.4/

# www_sync
网站自动化上线部署shell,解决了网站开发过程中的上线烦恼。传统ftp上线效率低下还容易出错，多台web主机的时候更是恶梦.实现一键完成上线部署。
自带上线修改文件备份，方便回档，有后悔药吃咯~

# 使用说明

## 简单版(simple)
	用于小型站点。没有测试环境的，只能本地开发环境和生产环境。
	使用方法：		
root@scgc-dev:~/rsync_weixinshow# bash test_rsync.sh 
1) www.weixinshow.com
2) quit
请选择您要更新到的项目，1:部署weixinshow到测试环境代码[测试]  2:退出 ==>


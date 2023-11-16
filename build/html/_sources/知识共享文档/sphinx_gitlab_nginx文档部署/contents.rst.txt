5.1 sphinx_gitlab_nginx文档部署
==================================================
    文档更新仅需要参考前3个步骤，第4,6步骤为一次性部署(本项目已部署完成)，第5步骤已设置为本地服务节点自动rebuild更新，每分钟更新一次，所以每次更新push推送后，一分钟之后线上文档即会自动更新。

step1) 创建gitlab项目,并clone到本地,比如深圳terminal;
    已创建git项目地址：http://10.0.1.111:9527/lzw/genecloudblog

    git clone git@10.0.1.111:lzw/genecloudblog.git
    
    git checkout master

step2) 进入项目可编辑文档目录,编写或者升级文档.rst|.md文件;
    cd ./genecloudblog/source/

    学习熟悉rst语法或者markdown语法，编辑相关.rst和.md 文件

    注意：如果新增目录，一定要编辑对应的 index.rst 文件

step3) push本地仓库到远程仓库，等待同步：
    git add . 

    git commit -a -m "update XXX doc"

    git pull origin master

    git push origin master

step4) 拉取sphinx镜像;
    podman pull 本地镜像：172.16.50.43/toolkit/blog_sphinx:v0.7.1

step5) rebuild 项目内容;
    podman run -it -v `pwd`:`pwd` 172.16.50.43/toolkit/blog_sphinx:v0.7.1

    cd ./genecloudblog/

    /bin/bash rebuild.sh

step6) 用nginx 部署本地服务;
     修改配置：nginx.conf中的location/root项修改为监听路径即可，比如`pwd`/genecloudblog/build/html/

     启动nginx服务：/usr/local/nginx/sbin/nginx 

step7) 部署完成，可访问在线文档;
     在线文档IP：http://172.16.10.11/

参考文档博客1：https://zhuanlan.zhihu.com/p/264647009

参考文档博客2：https://blog.csdn.net/DynastyRumble/article/details/118379119


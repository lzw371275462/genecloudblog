while ((1)) ; do
	cd /mnt/GeneCloud/luozw/git/genecloudblog_gitlab/
	git pull origin master
	docker run -v /mnt/:/mnt/ --rm 172.16.50.43/toolkit/blog_sphinx:v0.7.2 /mnt/GeneCloud/luozw/git/genecloudblog_gitlab/rebuild.sh
	##sh git_submit.sh "rebuild update check"
	sleep 60
done

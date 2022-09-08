#!/bin/bash
yum install -y rpmdevtools rpm-build createrepo
yum-builddep -y nginx
cat <<'EOF' | tee /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/8/x86_64/
gpgcheck=0
enabled=1
[nginx-source]
name=nginx source repo
baseurl=http://nginx.org/packages/mainline/centos/8/SRPMS/
gpgcheck=0
enabled=1
EOF
yumdownloader --source nginx
rpmdev-setuptree
rpm -ivh /home/vagrant/nginx-*
rpmbuild -bb ~/rpmbuild/SPECS/nginx.spec
yum localinstall -y /home/vagrant/rpmbuild/RPMS/x86_64/nginx-*
systemctl start nginx
mkdir /usr/share/nginx/html/repo
cp /home/vagrant/rpmbuild/RPMS/x86_64/nginx-* /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm	
createrepo /usr/share/nginx/html/repo/
nginx -s reload
cat <<'EOF' | sudo tee /etc/yum.repos.d/nginxlab.repo
[nginxlab]
name=nginxlab-linux
baseurl=http://localhost/repo
enabled=1
gpgcheck=0
EOF
yum install percona-release -y

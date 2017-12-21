FROM centos:centos7

RUN yum -y update && yum -y install curl wget unzip git vim \
iproute hostname inotify-tools yum-utils which \
epel-release openssh-server openssh-clients

# Set root password
RUN echo root:docker | chpasswd && yum install -y passwd
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_key \
&& ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key \
&& ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key \
&& sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
&& sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config \
&& sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


# Install Epel packages and Apache 
RUN yum -y install htop supervisor httpd mod_ssl

# Reconfigure Apache
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf \
&& chown root:apache /var/www/html \
&& chmod g+s /var/www/html

# Test index.html
WORKDIR /var/www/html
COPY index.html index.html

# Install PHP
RUN yum -y install php php-devel php-gd php-pdo php-soap php-xmlrpc php-xml php-mysql 

# Install MariaDB
RUN yum -y install mariadb-devel mariadb-libs mariadb mariadb-server

# Clean up yum
#RUN rm -rf /var/cache/yum/* && yum clean all

# EST Timezone & Networking
RUN ln -sf /usr/share/zoneinfo/EST /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

#Copy SupervisorD conf
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Ports
EXPOSE 22 25 80 443 3306
#CMD ["/usr/bin/supervisord"]
#CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# Start the service
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]

FROM centos:latest
MAINTAINER Werner Gillmer <werner.gillmer@gmail.com>

# install saltstack
# based on https://repo.saltstack.com/#rhel
RUN yum update -y && yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest-1.el7.noarch.rpm -y && \
    yum clean expire-cache -y && \
    yum	install virt-what \
        install salt-master \ 
	install salt-minion \
	install salt-ssh \
	install salt-syndic \ 
	install salt-cloud \
	install salt-api -y

# install tools 
RUN yum install kubernetes-client \ 
	install golang \ 
	install git -y

RUN mkdir -p /opt/go
ENV GOPATH /opt/go

# useful vultr commmand line tool 
RUN go get github.com/JamesClonk/vultr
RUN ln -s /opt/go/bin/vultr /usr/bin/vultr


# map volumes
# VOLUME ['/etc/salt/', '/var/cache/salt', '/var/log/salt']
EXPOSE 4505 4506 

CMD /usr/bin/salt-master -l debug 

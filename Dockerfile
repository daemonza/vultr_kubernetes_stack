FROM centos:latest
MAINTAINER Werner Gillmer <werner.gillmer@gmail.com>

# give more information for salt
RUN yum install virt-what -y
# kubectl
RUN yum install kubernetes-client -y
RUN yum install golang -y
RUN yum install git -y

RUN mkdir -p /opt/go
ENV GOPATH /opt/go

# setup salt master
RUN curl -o /opt/bootstrap-salt.sh -L https://bootstrap.saltstack.com
# only install master, not minion, with salt-cloud and don't auto start after install
RUN /bin/sh /opt/bootstrap-salt.sh -X -L -M -N -P

# useful vultr commmand line tool 
RUN go get github.com/JamesClonk/vultr
RUN ln -s /opt/go/bin/vultr /usr/bin/vultr


# TODO
# map volumes

VOLUME ['/etc/salt', '/var/cache/salt', '/var/logs/salt', '/srv/salt']
EXPOSE 4505 4506 

CMD /usr/bin/salt-master -l info 

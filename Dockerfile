#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM ubuntu:bionic
MAINTAINER Christian Christelis <christian@kartoza.com>

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

# Use local cached debs from host (saves your bandwidth!)
# Change ip below to that of your apt-cacher-ng host
# Or comment this line out if you do not with to use caching
ADD 71-apt-cacher-ng /etc/apt/apt.conf.d/71-apt-cacher-ng

RUN apt -y update
# socat can be used to proxy an external port and make it look like it is local
RUN apt -y install pwgen

#-------------Application Specific Stuff ----------------------------------------------------
RUN apt -y install uwsgi uwsgi-plugin-python python-pip

ADD server-conf /home/web/server-conf
ADD REQUIREMENTS.txt /home/web/REQUIREMENTS.txt
# Note that ww-data does not have permissions
# for the django project dir - so we will copy it over and then set the 
# permissions in the start script. COPY is like ADD but does not 
# automatically unpack tarballs. We need to copy it as a tarball
# and then unzip it as www-data because docker copies files with
# uid/gid = 0
COPY django_project.tar.gz /tmp/django_project.tar.gz
RUN cd /home/web; tar xfz /tmp/django_project.tar.gz; chown -R www-data.www-data /home/web

CMD /usr/bin/uwsgi --ini /etc/uwsgi/apps-enabled/default

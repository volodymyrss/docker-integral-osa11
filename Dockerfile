FROM centos

RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install gcc git curl make zlib-devel bzip2 bzip2-devel \
                   readline-devel sqlite sqlite-devel openssl \
                   openssl-devel patch libjpeg libpng12 libX11 \
                   which libXpm libXext curlftpfs wget libgfortran file \
                   ruby-devel fpm rpm-build \
                   ncurses-devel \
                   libXt-devel \
                   gcc gcc-c++ gcc-gfortran \
                   perl-ExtUtils-MakeMaker \
                   net-tools strace sshfs sudo iptables \
                   git cmake gcc-c++ gcc binutils libX11-devel libXpm-devel \
                   libXft-devel libXext-devel gcc-gfortran openssl-devel pcre-devel \
                   mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel \
                   fftw-devel cfitsio-devel graphviz-devel avahi-compat-libdns_sd-devel \
                   libldap-dev python-devel libxml2-devel gsl-static \
                   compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-c++.gfortran \
                   colordiff

RUN cp -fv /usr/bin/gfortran /usr/bin/g95

RUN ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.0
#RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && yum -y install git-lfs

ARG uid
RUN groupadd -r integral -g $uid && useradd -u $uid -r -g integral integral && \
    mkdir /home/integral /data && \
    chown -R integral:integral /home/integral /data
USER integral

## pyenv

WORKDIR /home/integral

RUN git clone git://github.com/yyuu/pyenv.git .pyenv

ENV HOME  /home/integral
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN export PYTHON_CONFIGURE_OPTS="--enable-shared" && pyenv install 2.7.12
RUN pyenv global 2.7.12
RUN pyenv rehash


# basic
RUN pip install pip --upgrade
RUN pip install future
RUN pip install numpy scipy astropy matplotlib
RUN pip install termcolor

# heasoft
USER root
RUN wget https://www.isdc.unige.ch/~savchenk/gitlab-ci/savchenk/osa-build-heasoft-binary-tarball/CentOS_7.5.1804_x86_64/heasoft-CentOS_7.5.1804_x86_64.tar.gz && \
    (cd /; tar xvzf $OLDPWD/heasoft-CentOS_7.5.1804_x86_64.tar.gz) && \
    rm -fv heasoft-CentOS_7.5.1804_x86_64.tar.gz

ADD heasoft_init.sh /heasoft_init.sh

# root
RUN cd / && \ 
    wget https://root.cern.ch/download/root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
    tar xvzf root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
    rm -f root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz 

# osa
#USER root
#RUN wget https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/CentOS_7.5.1804_x86_64/latest/build-latest/osa-11.0-3-g78d73880-20190124-105932-CentOS_7.5.1804_x86_64-tiny.tar.gz && \
#    cd / && tar xvzf $OLDPWD/osa-11.0-3-g78d73880-20190124-105932-CentOS_7.5.1804_x86_64-tiny.tar.gz && \
#    rm -fv osa-11.0-3-g78d73880-20190124-105932-CentOS_7.5.1804_x86_64-tiny.tar.gz && \
#    mv /osa11 /osa

ARG OSA_VERSION

RUN cd / && \
    if [ ${OSA_VERSION} == "10.2" ]; then \
        wget https://www.isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-bin-linux64.tar.gz && \
        tar xvzf osa10.2-bin-linux64.tar.gz && \
        rm -fv osa10.2-bin-linux64.tar.gz && \
        mv osa10.2 osa; \
    else \
        wget https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-binary-tarball/CentOS_7.5.1804_x86_64/${OSA_VERSION}/build-latest/osa-${OSA_VERSION}-CentOS_7.5.1804_x86_64.tar.gz && \
        tar xvzf osa-${OSA_VERSION}-CentOS_7.5.1804_x86_64.tar.gz && \
        rm -fv osa-${OSA_VERSION}-CentOS_7.5.1804_x86_64.tar.gz && \
        mv osa11 osa; \
    fi


USER integral

ADD osa_init.sh /osa_init.sh

# prep OSA

USER root
RUN mkdir -pv /host_var; chown integral:integral /host_var &&  \
    mkdir -pv /data/rep_base_prod; chown integral:integral /data/rep_base_prod && \
    mkdir -pv /data/ddcache; chown integral:integral /data/ddcache  && \
    mkdir -pv /data/rep_base_prod/aux /data/ic_tree_current/ic /data/ic_tree_current/idx /data/resources /data/rep_base_prod/cat /data/rep_base_prod/ic /data/rep_base_prod/idx && \
    chown -R integral:integral /data/rep_base_prod/aux /data/ic_tree_current/ic /data/ic_tree_current/idx /data/resources /data/rep_base_prod/cat /data/rep_base_prod/ic /data/rep_base_prod/idx
USER integral


# custom private python
RUN mkdir -pv /home/integral/.ssh; ssh-keyscan -t rsa github.com >> /home/integral/.ssh/known_hosts
ADD deploy-keys deploy-keys
ADD keys/known_hosts /home/integral/.ssh/known_hosts
ADD keys/integral-containers-key /home/integral/.ssh/id_rsa
ADD keys/integral-containers-key.pub /home/integral/.ssh/id_rsa.pub
ADD keys keys

# duplication?
USER root
RUN mkdir -pv .ssh && chown -R integral:integral deploy-keys .ssh
RUN cp keys/id_rsa-sdsc /home/integral/.ssh/id_rsa && cp keys/id_rsa-sdsc.pub /home/integral/.ssh/id_rsa.pub && cp keys/known_hosts /home/integral/.ssh/
RUN cp keys/id_rsa-osa11 /home/integral/.ssh/id_rsa && cp keys/id_rsa-osa11.pub /home/integral/.ssh/id_rsa.pub && cp keys/known_hosts /home/integral/.ssh/
RUN chown integral:integral -Rv keys /home/integral/.ssh
RUN chown -R integral:integral /home/integral/.ssh/ &&  \
    chmod 644 /home/integral/.ssh/id_rsa.pub &&  \
    chmod 400 /home/integral/.ssh/id_rsa
RUN echo "integral ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER integral




# additional software

RUN pip install --upgrade pip  
RUN pip install pyyaml
RUN pip install logzio-python-handler
RUN pip install numpy pandas  --upgrade
RUN pip install python-logstash logstash_formatter
RUN pip install logstash_formatter
RUN pip install requests-unixsocket 
RUN pip install pymysql
RUN pip install peewee
RUN pip install ruamel.yaml
RUN pip install pyyaml luigi pandas jupyter pytest nose sshuttle && \
    pip install git+ssh://git@github.com/volodymyrss/pilton.git@504e245 -U && \
    pip install git+ssh://git@github.com/volodymyrss/heaspa.git -U && \
    pip install git+ssh://git@github.com/volodymyrss/headlessplot.git && \
    pip install git+ssh://git@github.com/volodymyrss/dda-ddosadm.git -U && \
    pip install git+ssh://git@github.com/volodymyrss/dda-ddosa.git@7c45922 -U && \
    pip install git+ssh://git@github.com/volodymyrss/dlogging.git@6df5b37 --upgrade
RUN pip install git+ssh://git@github.com/volodymyrss/restddosaworker.git@f19ccb --upgrade
RUN pip install git+ssh://git@github.com/volodymyrss/dqueue
RUN git clone https://github.com/mtorromeo/mattersend.git && cd mattersend && pip install pyfakefs && pip install . 


ARG dda_revision
RUN pip install git+ssh://git@github.com/volodymyrss/data-analysis.git@$dda_revision --upgrade


# dda service
ENV EXPORT_SERVICE_PORT 5691
ENV EXPORT_SERVICE_HOST 0.0.0.0
EXPOSE $EXPORT_SERVICE_PORT


# jupyter
RUN mkdir -p /home/integral/.jupyter/
EXPOSE 8888


# access group
ARG private_group=""
USER root
RUN  [ "$private_group" != "" ] && ( groupadd data -g 4915; usermod integral -G data -a) || echo 'not adding private group!'
USER integral

#USER root
#RUN su - -c 'yum install netstat lsof -y'
#USER integral

#ADD choose_proxy.sh /home/integral/choose_proxy.sh

#RUN rm -rf /home/integral/pfiles

ADD entrypoint.sh /home/integral/entrypoint.sh
ENTRYPOINT /home/integral/entrypoint.sh
#ENV DDA_QUEUE /data/ddcache/queue

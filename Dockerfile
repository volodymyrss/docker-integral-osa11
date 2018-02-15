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
                   net-tools strace sshfs sudo iptables

RUN ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.0
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash && yum -y install git-lfs

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

RUN pip install numpy scipy astropy matplotlib

## build heasoft

ENV LD_LIBRARY_PATH /home/integral/.pyenv/versions/2.7.12/lib/
ENV LDFLAGS "-L/home/integral/.pyenv/versions/2.7.12/lib/"

ARG heasoft_version=6.22.1
ENV HEASOFT_VERSION $heasoft_version

ADD heasoft_build.sh .
RUN sh heasoft_build.sh

RUN pip install git+https://git@github.com/volodymyrss/pilton.git

ADD heasoft_init.sh .

## keys


#RUN ls -lotra deploy-keys; chmod 700 deploy-keys; chmod 600 deploy-keys/*; \
#    git lfs install && \
#    ssh-agent bash -c 'ssh-add deploy-keys/deploy-osa-package-reduced_id_rsa; ls -lotra deploy-keys/; git clone git@github.com:volodymyrss/osa-package-reduced.git' && \
#    cd osa-package-reduced && git checkout dc511db && ls -ltroah && sh install.sh && cp osa10.2_init.sh ../ &&\
#    cd ../ && rm -rf osa-package-reduced



## pipeline and scripts
#
#ADD update_packages.sh /home/integral/
#RUN sh update_packages.sh

#ADD run.sh /home/integral/run.sh

ADD deploy-keys deploy-keys
ADD keys/known_hosts /home/integral/.ssh/known_hosts
ADD keys/integral-containers-key /home/integral/.ssh/id_rsa
ADD keys/integral-containers-key.pub /home/integral/.ssh/id_rsa.pub
ADD keys keys

#RUN ssh-keyscan -t rsa github.com >> /home/integral/.ssh/known_hosts


USER root
RUN mkdir -pv .ssh && chown -R integral:integral deploy-keys .ssh
#RUN cp keys/id_rsa-sdsc /home/integral/.ssh/id_rsa && cp keys/id_rsa-sdsc.pub /home/integral/.ssh/id_rsa.pub && cp keys/known_hosts /home/integral/.ssh/
RUN cp keys/id_rsa-osa11 /home/integral/.ssh/id_rsa && cp keys/id_rsa-osa11.pub /home/integral/.ssh/id_rsa.pub && cp keys/known_hosts /home/integral/.ssh/
RUN chown integral:integral -Rv keys /home/integral/.ssh
RUN chown -R integral:integral /home/integral/.ssh/ &&  \
    chmod 644 /home/integral/.ssh/id_rsa.pub &&  \
    chmod 400 /home/integral/.ssh/id_rsa
RUN echo "integral ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER integral


RUN pip install --upgrade pip  && \
    pip install git+ssh://git@github.com/volodymyrss/pilton.git@504e245 -U && \
    pip install git+ssh://git@github.com/volodymyrss/data-analysis.git@332d51a -U && \
    pip install git+ssh://git@github.com/volodymyrss/dda-ddosadm.git -U && \
    pip install git+ssh://git@github.com/volodymyrss/dda-ddosa.git@7c45922 -U && \
    pip install git+ssh://git@github.com/volodymyrss/heaspa.git -U && \
    pip install git+ssh://git@github.com/volodymyrss/headlessplot.git && \
    pip install git+ssh://git@github.com/volodymyrss/dlogging.git@6df5b37 --upgrade && \
    pip install pyyaml luigi pandas jupyter pytest nose sshuttle && \
    pip install git+ssh://git@github.com/volodymyrss/restddosaworker.git@04cd7f1 && \
    pip install git+ssh://git@github.com/volodymyrss/dda-sdsc.git@29b0bdf && \
    pip install git+ssh://git@github.com/volodymyrss/data-analysis.git@90cc924     --upgrade && \
    pip install git+ssh://git@github.com/volodymyrss/dda-ddosa    --upgrade


# prep OSA

USER root
RUN mkdir -pv /host_var; chown integral:integral /host_var &&  \
    mkdir -pv /data/rep_base_prod; chown integral:integral /data/rep_base_prod && \
    mkdir -pv /data/ddcache; chown integral:integral /data/ddcache 
USER integral

# additional software

ADD common_integral_software_init.sh .

ADD install_common_integral_software.sh .
RUN bash install_common_integral_software.sh

ADD osa10.2_preparedata.sh .

ADD secret-ddosa-server /home/integral/.secret-ddosa-server

ADD entrypoint.sh /home/integral/entrypoint.sh

RUN rm -rf /home/integral/pfiles
ENTRYPOINT /home/integral/entrypoint.sh


ENV EXPORT_SERVICE_PORT 5967
ENV EXPORT_SERVICE_HOST 0.0.0.0
EXPOSE $EXPORT_SERVICE_PORT

RUN mkdir -p /home/integral/.jupyter/
ADD jupyter_notebook_config.json /home/integral/.jupyter/jupyter_notebook_config.json
EXPOSE 8888

#RUN ssh-agent bash -c 'ssh-add deploy-keys/deploy-osa-package-reduced_id_rsa; ls -lotra deploy-keys/; git clone git@github.com:volodymyrss/osa-package-reduced.git -b isgrijemx' && \
#    cd osa-package-reduced && git checkout isgrijemx && ls -ltroah && sh install.sh;  cp osa10.2_init.sh ../ &&\
#    cd ../ && rm -rf osa-package-reduced

RUN sudo su - -c 'yum install -y git cmake gcc-c++ gcc binutils libX11-devel libXpm-devel libXft-devel libXext-devel gcc-gfortran openssl-devel pcre-devel mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel fftw-devel cfitsio-devel graphviz-devel avahi-compat-libdns_sd-devel libldap-dev python-devel libxml2-devel gsl-static'

RUN wget https://root.cern.ch/download/root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
    tar xvzf root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz && \
    rm -f root_v5.34.26.Linux-slc6_amd64-gcc4.4.tar.gz 


#RUN wget https://root.cern.ch/download/root_v5.34.26.Linux-slc6_amd64-gcc4.8.tar.gz && \
#    tar xvzf root_v5.34.26.Linux-slc6_amd64-gcc4.8.tar.gz

#RUN mkdir -p /home/integral/ && \
#    cd /home/integral/ && \
#    wget https://root.cern.ch/download/root_v5.34.34.source.tar.gz && \
#    tar xvzf root_v5.34.34.source.tar.gz  && \

#RUN mkdir -p /home/integral/ && \
#    cd /home/integral/ && \
#    wget https://root.cern.ch/download/root_v5.34.34.source.tar.gz && \
#    tar xvzf root_v5.34.34.source.tar.gz  && \
#    cd root && \
#    ./configure  && \
#    make
    


#ADD g95-x86_64-64-linux.tgz g95-x86_64-64-linux

#USER root
#RUN cp g95-x86_64-64-linux/g95-install/bin/x86_64-unknown-linux-gnu-g95 /usr/bin/f95
#USER integral

RUN sudo su - -c 'yum install -y  compat-gcc-44 compat-gcc-44-c++ compat-gcc-44-c++.gfortran'
RUN sudo su - -c 'cp -fv /usr/bin/gfortran /usr/bin/g95'

ADD install_osa102.sh install_osa102.sh
RUN sh install_osa102.sh
ADD osa10.2_init.sh osa10.2_init.sh

#ADD install_common_integral_software_ii.sh install_common_integral_software_ii.sh
#RUN bash install_common_integral_software_ii.sh

RUN git clone git@github.com:volodymyrss/osa-builder.git && \
    cd osa-builder

RUN pip install termcolor
RUN sudo su - -c 'yum install -y colordiff'

ADD install_osa11_update.sh install_osa11_update.sh
RUN sh install_osa11_update.sh dal3ibis
RUN sh install_osa11_update.sh '^ibis_.*'
RUN sh install_osa11_update.sh '^ii_.*'
RUN sh install_osa11_update.sh '^spe_pick'
RUN sh install_osa11_update.sh '^barycent'
RUN sh install_osa11_update.sh '^j_.*'
#rmf-templates
#templates-all
#test-ibis_isgr_energy
#test-ii_shadow_build
#test-jemx_image




USER root
RUN mkdir -pv /data/rep_base_prod/aux /data/ic_tree_current/ic /data/ic_tree_current/idx /data/resources /data/rep_base_prod/cat /data/rep_base_prod/ic /data/rep_base_prod/idx && \
    chown -R integral:integral /data/rep_base_prod/aux /data/ic_tree_current/ic /data/ic_tree_current/idx /data/resources /data/rep_base_prod/cat /data/rep_base_prod/ic /data/rep_base_prod/idx
USER integral
    
RUN pip install git+ssh://git@github.com/volodymyrss/data-analysis.git@44266de --upgrade 
RUN git clone git@github.com:volodymyrss/osa-templates-all.git && \
    source /home/integral/osa10.2_init.sh && \
    cp -rf osa-templates-all/* $CFITSIO_INCLUDE_FILES/

ADD init.sh init.sh

USER root
RUN su - -c 'yum install -y redhat-lsb'
USER integral

RUN platform=`lsb_release -is`_`lsb_release -sr`_`uname -i` && \
    cd /home/integral/osa && \
    tar cvzf /home/integral/osa11-${platform}.tar.gz * && \
    ls -lotr


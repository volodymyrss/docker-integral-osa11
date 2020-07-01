FROM integralsw/osa-python:11.1-3-g87cee807-20200410-144247-refcat-42.0-heasoft-6.26.1-python-3.6.9

# also add osa10.2

RUN mkdir -pv /osa10.2 && \
    curl -q https://www.isdc.unige.ch/integral/download/osa/sw/10.2/osa10.2-bin-linux64-CentOS7.tar.gz | tar xzf - -C /opt/

RUN cat /init.sh >> /init-osa10.2.sh && \
    echo "export OSA_VERSION=10.2" >> /init-osa10.2.sh && \
    echo "export CONTAINER_COMMIT=$CONTAINER_COMMIT" >> /init-osa10.2.sh && \
    echo "export ISDC_ENV=/opt/osa10.2" >> /init-osa10.2.sh && \
    echo "source /opt/osa10.2/bin/isdc_init_env.sh" >> /init-osa10.2.sh


# additional software

ENV HOME_OVERRRIDE=/tmp/home

RUN . /init.sh; pip install --upgrade pip; pip install wheel

ADD requirements.txt /requirements.txt
RUN . /init.sh; pip install -r /requirements.txt

ADD dda-interface-app /dda-interface-app
RUN . /init.sh; pip install /dda-interface-app

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh

RUN echo "export OSA_VERSION=$OSA_VERSION" >> /init.sh
RUN echo "export CONTAINER_COMMIT=$CONTAINER_COMMIT" >> /init.sh

#RUN export HOME=/tmp; id; source /osa_init.sh; python -c 'import yaml, collections; yaml.load(yaml.dump(collections.OrderedDict()))'

#ENV DDA_QUEUE /data/ddcache/queue

ADD etc-passwd /etc/passwd

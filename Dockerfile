FROM integralsw/osa-python:11.1-3-g87cee807-20200410-144247-refcat-42.0-heasoft-6.26.1-python-3.6.9

# additional software

ENV HOME_OVERRRIDE=/tmp/home

RUN . /init.sh; pip install --upgrade pip; pip install wheel

ADD requirements.txt /requirements.txt
RUN . /init.sh; pip install -r /requirements.txt

ADD dda-interface-app /dda-interface-app
RUN . /init.sh; pip install /dda-interface-app

# access group
ARG private_group=""
USER root
RUN  [ "$private_group" != "" ] && ( groupadd data -g 4915; usermod integral -G data -a) || echo 'not adding private group!'
USER integral


ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh

USER root
RUN echo "export OSA_VERSION=$OSA_VERSION" >> /init.sh
RUN echo "export CONTAINER_COMMIT=$CONTAINER_COMMIT" >> /init.sh
USER integral

RUN pip install pyyaml==3.12
ENTRYPOINT /home/integral/entrypoint.sh

#RUN export HOME=/tmp; id; source /osa_init.sh; python -c 'import yaml, collections; yaml.load(yaml.dump(collections.OrderedDict()))'

#ENV DDA_QUEUE /data/ddcache/queue

FROM integralsw/osa-python

# additional software

RUN pip install --upgrade pip  

ADD requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

ADD dda-interface-app /dda-interface-app
RUN pip install /dda-interface-app

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

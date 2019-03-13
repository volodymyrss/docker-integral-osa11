CONTAINER_NAME=${1:?}

SCRATCH=${SCRATCH:-/tmp/scratch}
LOGS=${LOGS:-/tmp/logs}

mkdir -pv $SCRATCH $LOGS

docker run \
    -v netrc-integral-containers:/home/integral/.netrc \
    -v sentry-key:/home/integral/.sentry-key \
    -v mattermost-hook:/home/integral/.mattermost-hook \
    -v secret-ddosa-server:/home/integral/.secret-ddosa-server \
    -v jupyter_notebook_config.json:/home/integral/.jupyter/jupyter_notebook_config.json \
    -v $SCRATCH:/scratch \
    -v $LOGS:/var/log/containers \
    -e DDA_QUEUE=queue-osa11 \
    $CONTAINER_NAME

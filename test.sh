CONTAINER_NAME=${1:?}

SCRATCH=${SCRATCH:-/tmp/scratch}
LOGS=${LOGS:-/tmp/logs}

echo ${WORKER_MODE:=interface}

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
    -e WORKER_MODE=${WORKER_MODE} \
    -e DDA_INTERFACE_TOKEN="" \
    --name dda-${WORKER_MODE} \
    -p 8100:8000 \
    --rm \
    $CONTAINER_NAME &

sleep 1


echo "healthcheck"
curl http://localhost:8100/healthcheck

echo "DataAnalysis"
curl http://remoteintegral:@localhost:8100/api/v1.0/DataAnalysis


export DDOSA_WORKER_URL=http://localhost:8100/
echo "ii_skyimage"
dda-client -v ii_skyimage -m git://ddosa -a 'ddosa.ScWData(input_scwid="066500220010.001")'

docker rm -f dda-${WORKER_MODE}

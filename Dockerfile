ARG BASE=dellelce/py-base
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"


# temp install line before switching to use multi-stage install
RUN apk add --no-cache gcc binutils

# commands are intended for busybox: if BASE is changed to non-BusyBox these may fail!
ARG GID=2001
ARG UID=2000
ARG GROUP=airflow
ARG USERNAME=airflow
ARG DATA=/app/data/${USERNAME}
ARG AIRPORT=8000
ARG AIRHOME=/home/${USERNAME}
ARG AIRENV=/home/${USERNAME}/air-env

ENV ENV   $AIRHOME/.profile

RUN addgroup -g "${GID}" "${GROUP}" && adduser -D -s /bin/sh \
    -g "AirFlow user" \
    -G "${GROUP}" -u "${UID}" \
    "${USERNAME}" \
    && chown -R "${USERNAME}:${GROUP}" "${AIRHOME}" \
    && mkdir -p "${DATA}" && chown "${USERNAME}":"${GROUP}" "${DATA}" \
    && echo '. '${AIRENV}'/bin/activate'           >> ${AIRHOME}/.profile

USER ${USERNAME}

#create virtualenv
WORKDIR $AIRENV
COPY requirements.txt  /tmp/requirements.txt

# install airflow and requirents
RUN    . ${AIRENV}/bin/activate \
    && pip install -U pip setuptools \
    && pip install -r /tmp/requirements.txt

VOLUME ${DATA}
ENV AIRDATA  ${DATA}

EXPOSE ${AIRPORT}:${AIRPORT}


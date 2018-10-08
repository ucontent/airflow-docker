ARG BASE=dellelce/py-base
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"
ARG USERNAME=airflow
ARG AIRENV=/home/${USERNAME}/air-env


# temp install line before switching to use multi-stage install
RUN apk add --no-cache gcc g++ binutils gfortran make libc-dev linux-headers \
                       libxslt-dev

WORKDIR $AIRENV
COPY requirements.txt  /tmp/requirements.txt

# install airflow and requirements
RUN cd "${AIRENV}" && "${INSTALLDIR}/bin/python3" -m venv . \
 && . ${AIRENV}/bin/activate \
 && pip install -U pip setuptools \
 && SLUGIFY_USES_TEXT_UNIDECODE=yes pip install -r /tmp/requirements.txt

ARG BASE=dellelce/py-base
FROM $BASE as finale

# commands are intended for busybox: if BASE is changed to non-BusyBox these may fail!
ARG GID=2001
ARG UID=2000
ARG GROUP=airflow
ARG USERNAME=airflow
ARG BASEDATA=/app/data
ARG DATA=${BASEDATA}/${USERNAME}
ARG AIRPORT=8000
ARG AIRHOME=/home/${USERNAME}
ARG AIRENV=/home/${USERNAME}/air-env

ENV ENV   $AIRHOME/.profile

# copy virtualenv from first stage
COPY --from=build ${AIRENV} ${AIRENV} 

RUN mkdir -p ${BASEDATA} && chmod 777 ${BASEDATA} \
    && addgroup -g "${GID}" "${GROUP}" && adduser -D -s /bin/sh \
       -g "AirFlow user" \
       -G "${GROUP}" -u "${UID}" \
       "${USERNAME}"

USER ${USERNAME}

RUN    mkdir -p "${AIRENV}" && chown "${USERNAME}":"${GROUP}" "${AIRENV}" \
    && chown -R "${USERNAME}:${GROUP}" "${AIRHOME}" \
    && mkdir -p "${DATA}" && chown "${USERNAME}":"${GROUP}" "${DATA}" \
    && echo '. '${AIRENV}'/bin/activate'           >> ${AIRHOME}/.profile


VOLUME ${DATA}
ENV AIRDATA  ${DATA}

EXPOSE ${AIRPORT}:${AIRPORT}


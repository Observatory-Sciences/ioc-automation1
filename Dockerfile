# Add support for Aerotech Automation1 motion controllers
ARG REGISTRY=ghcr.io/epics-containers
ARG MODULES_VERSION=4.41r3.0

ARG MOTOR_VERSION=R7-2-1
ARG IPAC_VERSION=2.16
ARG MOTOR_AUTOMATION1_VERSION=dls
ARG AEROTECH_BIN=Aerotech_H_SO
##### build stage ##############################################################

FROM ${REGISTRY}/epics-modules:${MODULES_VERSION} AS developer

ARG MOTOR_VERSION
ARG MOTOR_AUTOMATION1_VERSION
ARG IPAC_VERSION
ARG AEROTECH_BIN

ENV LD_LIBRARY_PATH=${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}/bin/linux-x86_64:${LD_LIBRARY_PATH}

# install additional tools and libs
USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y \
     && apt-get install -y --no-install-recommends \
     libsodium-dev \
     && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

# get additional support modules
RUN python3 module.py add epics-modules ipac IPAC ${IPAC_VERSION} && \
    python3 module.py add epics-modules motor MOTOR ${MOTOR_VERSION} && \
    python3 module.py add Observatory-Sciences motorAutomation1 MOTOR_AUTOMATION1 ${MOTOR_AUTOMATION1_VERSION}

RUN cp ${SUPPORT}/motor-${MOTOR_VERSION}/motorApp/Db/basic_asyn_motor.db ${SUPPORT}/motor-${MOTOR_VERSION}/motorApp/Db/basic_asyn_motor.template

RUN mkdir ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}/automation1Sup/Lib/
RUN mkdir ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}/automation1Sup/Include/

COPY --chown=${USER_UID}:${USER_GID} Makefile ${EPICS_ROOT}/ioc/iocApp/src
COPY --chown=${USER_UID}:${USER_GID} RELEASE.local ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}/configure
COPY --chown=${USER_UID}:${USER_GID} ${AEROTECH_BIN}/*.so ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}/automation1Sup/Lib/
COPY --chown=${USER_UID}:${USER_GID} ${AEROTECH_BIN}/*.h ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}/automation1Sup/Include/

# update dependencies and build the support modules and the ioc
RUN python3 module.py dependencies
RUN make -j -C  ${SUPPORT}/motor-${MOTOR_VERSION}
RUN make -C  ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}
RUN make -j -C ${IOC} && \
    make -j clean

##### runtime stage ############################################################

FROM ${REGISTRY}/epics-modules:${MODULES_VERSION}.run AS runtime

ARG MOTOR_VERSION
ARG MOTOR_AUTOMATION1_VERSION
ARG IPAC_VERSION
ARG AEROTECH_BIN

ENV LD_LIBRARY_PATH=${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}/bin/linux-x86_64:${LD_LIBRARY_PATH}

# install runtime libraries from additional packages section above
USER root

RUN apt-get update && apt-get upgrade -y \
     && apt-get install -y --no-install-recommends \
     libsodium-dev \
     && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

COPY --from=developer --chown=${USER_UID}:${USER_GID} ${SUPPORT}/motor-${MOTOR_VERSION} ${SUPPORT}/motor-${MOTOR_VERSION}
COPY --from=developer --chown=${USER_UID}:${USER_GID} ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION} ${SUPPORT}/motorAutomation1-${MOTOR_AUTOMATION1_VERSION}
COPY --from=developer --chown=${USER_UID}:${USER_GID} ${IOC} ${IOC}
COPY --from=developer --chown=${USER_UID}:${USER_GID} ${SUPPORT}/configure ${SUPPORT}/configure

#########################################
# Dockerfile for setting up the MEIGarage.
# This installs dependencies to the system, 
# then downloads the latest artifacts 
# of the MEIGarage (backend),
# and installs it in a Tomcat application server
#########################################
FROM tomcat:9-jdk11-openjdk


LABEL org.opencontainers.image.source=https://github.com/edirom/meigarage
LABEL maintainer="Anne Ferger and Peter Stadler for the ViFE"

ARG VERSION_STYLESHEET=latest
ARG VERSION_ODD=latest
ARG VERSION_ENCODING_TOOLS=latest
ARG VERSION_W3C_MUSICXML=latest
ARG VERSION_MEILER=latest
#ARG VERSION_MUSIC_ENCODING=latest : no version to be specified available yet
#ARG VERSION_DATA_CONFIGURATION=latest : no releases/versions available yet
ARG WEBSERVICE_ARTIFACT=https://nightly.link/Edirom/MEIGarage/workflows/maven/dev/artifact.zip

ENV CATALINA_WEBAPPS ${CATALINA_HOME}/webapps
ENV OFFICE_HOME /usr/lib/libreoffice
ENV TEI_SOURCES_HOME /usr/share/xml/tei
ENV MEI_SOURCES_HOME /usr/share/xml/mei

USER root:root

RUN apt-get update \
    && apt-get install -y --no-install-recommends fonts-dejavu \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-baekmuk \
    fonts-junicode \
    fonts-linuxlibertine \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    cmake \
    build-essential \
    libgcc-10-dev \
    librsvg2-bin \
    curl \
    && rm -rf /var/lib/apt/lists/*

# installs lilypond into /usr/local/lilypond and /usr/local/bin as shortcut
ADD https://lilypond.org/download/binaries/linux-64/lilypond-2.20.0-1.linux-64.sh /tmp/lilypond.sh
RUN chmod a+x /tmp/lilypond.sh \
    && /tmp/lilypond.sh --batch

# clone and run
RUN git clone -b master https://github.com/rism-digital/verovio /tmp/verovio \
    && cd /tmp/verovio/tools \
    && cmake ../cmake \
    && make -j 8 \
    && make install \
    && cp /tmp/verovio/fonts/VerovioText-1.0.ttf /usr/local/share/fonts/ \
    && fc-cache

# entrypoint script
COPY docker-entrypoint.sh /my-docker-entrypoint.sh

# log4j.xml configuration
COPY log4j.xml /var/cache/oxgarage/log4j.xml

# download artifacts to /tmp and deploy them at ${CATALINA_WEBAPPS}
# the war-file is zipped so we need to unzip it twice at the next stage 
RUN rm -Rf ${CATALINA_WEBAPPS}/ROOT \
    && curl -Ls ${WEBSERVICE_ARTIFACT} -o /tmp/meigarage.zip \
    && unzip -q /tmp/meigarage.zip -d /tmp/ \
    && unzip -q /tmp/meigarage.war -d ${CATALINA_WEBAPPS}/ege-webservice/ \
    && cp ${CATALINA_WEBAPPS}/ege-webservice/WEB-INF/lib/oxgarage.properties /etc/ \
    && rm /tmp/*.war \
    && rm /tmp/*.zip \
    && chmod 755 /my-docker-entrypoint.sh

#check if the version of stylesheet version is supplied, if not find out latest version

#https://github.com/TEIC/Stylesheets/releases/latest
RUN if [ "$VERSION_STYLESHEET" = "latest" ] ; then \
    VERSION_STYLESHEET=$(curl "https://api.github.com/repos/TEIC/Stylesheets/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \    
    fi \
    && echo "Stylesheet version set to ${VERSION_STYLESHEET}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders (${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/stylesheet.zip https://github.com/TEIC/Stylesheets/releases/download/v${VERSION_STYLESHEET}/tei-xsl-${VERSION_STYLESHEET}.zip \
    && unzip /tmp/stylesheet.zip -d /tmp/stylesheet \
    && rm /tmp/stylesheet.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/stylesheet \
    && cp -r /tmp/stylesheet/xml/tei/stylesheet/*  ${TEI_SOURCES_HOME}/stylesheet \
    && rm -r /tmp/stylesheet

#https://github.com/TEIC/TEI/releases/latest 
RUN if [ "$VERSION_ODD" = "latest" ] ; then \
    VERSION_ODD=$(curl "https://api.github.com/repos/TEIC/TEI/releases/latest" | grep -Po '"tag_name": "P5_Release_\K.*?(?=")'); \   
    fi \
    && echo "ODD version set to ${VERSION_ODD}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/odd.zip https://github.com/TEIC/TEI/releases/download/P5_Release_${VERSION_ODD}/tei-${VERSION_ODD}.zip \
    && unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/odd \
    && cp -r /tmp/odd/xml/tei/odd/*  ${TEI_SOURCES_HOME}/odd \
    && rm -r /tmp/odd

#https://github.com/music-encoding/encoding-tools/releases/latest
RUN if [ "$VERSION_ENCODING_TOOLS" = "latest" ] ; then \
    VERSION_ENCODING_TOOLS=$(curl "https://api.github.com/repos/music-encoding/encoding-tools/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \   
    fi \
    && echo "Encoding tools version set to ${VERSION_ENCODING_TOOLS}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/encoding.zip https://github.com/music-encoding/encoding-tools/archive/refs/tags/v${VERSION_ENCODING_TOOLS}.zip \
    && unzip /tmp/encoding.zip -d /tmp/encoding \
    && rm /tmp/encoding.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/encoding-tools \
    && cp -r /tmp/encoding/*/*  ${MEI_SOURCES_HOME}/music-stylesheets/encoding-tools \
    && rm -r /tmp/encoding

#https://github.com/w3c/musicxml/releases/latest
RUN if [ "$VERSION_W3C_MUSICXML" = "latest" ] ; then \
    VERSION_W3C_MUSICXML=$(curl "https://api.github.com/repos/w3c/musicxml/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \    
    fi \
    && echo "W3C Music XML version set to ${VERSION_W3C_MUSICXML}" \
    # download the required stylesheet sources in the image and move them to the respective folders (${MEI_SOURCES_HOME})
    && curl -s -L -o /tmp/musicxml.zip https://github.com/w3c/musicxml/releases/download/v${VERSION_W3C_MUSICXML}/musicxml-${VERSION_W3C_MUSICXML}.zip \
    && unzip /tmp/musicxml.zip -d /tmp/musicxml \
    && rm /tmp/musicxml.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/w3c-musicxml/ \
    && cp -r /tmp/musicxml/*  ${MEI_SOURCES_HOME}/music-stylesheets/w3c-musicxml/ \
    && rm -r /tmp/musicxml

#https://github.com/rettinghaus/MEILER/releases/latest
RUN if [ "$VERSION_MEILER" = "latest" ] ; then \
    VERSION_MEILER=$(curl "https://api.github.com/repos/rettinghaus/MEILER/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \   
    fi \
    && echo "MEILER version set to ${VERSION_MEILER}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/meiler.zip https://github.com/rettinghaus/MEILER/archive/refs/tags/v${VERSION_MEILER}.zip \
    && unzip /tmp/meiler.zip -d /tmp/meiler \
    && rm /tmp/meiler.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/meiler \
    && cp -r /tmp/meiler/*/*  ${MEI_SOURCES_HOME}/music-stylesheets/meiler \
    && rm -r /tmp/meiler

#https://github.com/music-encoding/music-encoding - todo sort each version into correct folder, no version applicable yet
# download the required tei odd and stylesheet sources in the image and move them to the respective folders (${TEI_SOURCES_HOME})
RUN curl -s -L -o /tmp/mei200.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/MEI2012_v2.0.0.zip \
    && unzip /tmp/mei200.zip -d /tmp/mei200 \
    && rm /tmp/mei200.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei200 \
    && cp -r /tmp/mei200/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei200 \
    && rm -r /tmp/mei200 \
    && curl -s -L -o /tmp/mei211.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/MEI2013_v2.1.1.zip \
    && unzip /tmp/mei211.zip -d /tmp/mei211 \
    && rm /tmp/mei211.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei211 \
    && cp -r /tmp/mei211/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei211 \
    && rm -r /tmp/mei211 \
    && curl -s -L -o /tmp/mei300.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/v3.0.0.zip \
    && unzip /tmp/mei300.zip -d /tmp/mei300 \
    && rm /tmp/mei300.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei300 \
    && cp -r /tmp/mei300/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei300 \
    && rm -r /tmp/mei300 \
    && curl -s -L -o /tmp/mei401.zip https://github.com/music-encoding/music-encoding/archive/refs/tags/v4.0.1.zip \
    && unzip /tmp/mei401.zip -d /tmp/mei401 \
    && rm /tmp/mei401.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-encoding/mei401 \
    && cp -r /tmp/mei401/*/*  ${MEI_SOURCES_HOME}/music-encoding/mei401 \
    && rm -r /tmp/mei401


#https://github.com/Edirom/data-configuration - no releases, clone most recent version in dev branch and move to correct folder
RUN git clone -b dev https://github.com/Edirom/data-configuration /tmp/data-configuration \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/data-configuration \
    && cp -r /tmp/data-configuration/*  ${MEI_SOURCES_HOME}/music-stylesheets/data-configuration \
    && rm -r /tmp/data-configuration

VOLUME ["/usr/share/xml/tei/stylesheet", "/usr/share/xml/tei/odd", "/user/share/xml/mei"]

EXPOSE 8080 8081

ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]

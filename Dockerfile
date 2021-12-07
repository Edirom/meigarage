#########################################
# Dockerfile for setting up the MEIGarage.
# This installs dependencies to the system, 
# then downloads the latest artifacts 
# of the MEIGarage (backend),
# and installs it in a Tomcat application server
#########################################
FROM tomcat:7

LABEL org.opencontainers.image.source=https://github.com/edirom/meigarage
LABEL maintainer="Anne Ferger and Peter Stadler for the ViFE"

ARG VERSION_STYLESHEET=latest
ARG VERSION_ODD=latest
ARG VERSION_ENCODING_TOOLS=latest
ARG VERSION_W3C_MUSICXML=latest
ARG VERSION_MEILER=latest
ARG VERSION_MUSIC_ENCODING=latest
ARG VERSION_DATA_CONFIGURATION=latest


ENV CATALINA_WEBAPPS ${CATALINA_HOME}/webapps
ENV OFFICE_HOME /usr/lib/libreoffice
ENV TEI_SOURCES_HOME /usr/share/xml/tei
ENV MEI_SOURCES_HOME /usr/share/xml/mei

USER root:root

RUN apt-get update \
    && apt-get install -y ttf-dejavu \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-baekmuk \
    fonts-junicode \
    fonts-linuxlibertine \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    cmake \
    build-essential \
    libgcc-8-dev \
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

# download artifacts to /tmp
# the war-file is zipped so we need to unzip it twice at the next stage 
ADD https://nightly.link/Edirom/MEIGarage/workflows/maven/main/artifact.zip /tmp/meigarage.zip

RUN rm -Rf ${CATALINA_WEBAPPS}/ROOT \
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
    && echo "Stylesheet version set to ${VERSION_ODD}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/odd.zip https://github.com/TEIC/TEI/releases/download/P5_Release_${VERSION_ODD}/tei-${VERSION_ODD}.zip \
    && unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/odd \
    && cp -r /tmp/odd/xml/tei/odd/*  ${TEI_SOURCES_HOME}/odd \
    && rm -r /tmp/odd

#https://github.com/music-encoding/encoding-tools
RUN if [ "$VERSION_ENCODING_TOOLS" = "latest" ] ; then \
    VERSION_ENCODING_TOOLS=$(curl "https://api.github.com/repos/TEIC/TEI/releases/latest" | grep -Po '"tag_name": "P5_Release_\K.*?(?=")'); \   
    fi \
    && echo "Stylesheet version set to ${VERSION_ENCODING_TOOLS}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/odd.zip https://github.com/TEIC/TEI/releases/download/P5_Release_${VERSION_ENCODING_TOOLS}/tei-${VERSION_ENCODING_TOOLS}.zip \
    && unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/odd \
    && cp -r /tmp/odd/xml/tei/odd/*  ${TEI_SOURCES_HOME}/odd \
    && rm -r /tmp/odd

#https://github.com/w3c/musicxml/releases/latest
RUN if [ "$VERSION_W3C_MUSICXML" = "latest" ] ; then \
    VERSION_W3C_MUSICXML=$(curl "https://api.github.com/repos/w3c/musicxml/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \    
    fi \
    && echo "W3C Music XML version set to ${VERSION_W3C_MUSICXML}" \
    # download the required stylesheet sources in the image and move them to the respective folders (${MEI_SOURCES_HOME})
    && curl -s -L -o /tmp/musicxml.zip https://api.github.com/repos/w3c/musicxml/releases/download/v${VERSION_W3C_MUSICXML}/musicxml-${VERSION_W3C_MUSICXML}.zip \
    && unzip /tmp/musicxml.zip -d /tmp/musicxml \
    && rm /tmp/musicxml.zip \
    && mkdir -p  ${MEI_SOURCES_HOME}/music-stylesheets/w3c-musicxml/ \
    && cp -r /tmp/musicxml/*  ${MEI_SOURCES_HOME}/music-stylesheets/w3c-musicxml/ \
    && rm -r /tmp/musicxml

#https://github.com/rettinghaus/MEILER/releases/latest
RUN if [ "$VERSION_MEILER" = "latest" ] ; then \
    VERSION_MEILER=$(curl "https://api.github.com/repos/TEIC/TEI/releases/latest" | grep -Po '"tag_name": "P5_Release_\K.*?(?=")'); \   
    fi \
    && echo "Stylesheet version set to ${VERSION_MEILER}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/odd.zip https://github.com/TEIC/TEI/releases/download/P5_Release_${VERSION_MEILER}/tei-${VERSION_MEILER}.zip \
    && unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/odd \
    && cp -r /tmp/odd/xml/tei/odd/*  ${TEI_SOURCES_HOME}/odd \
    && rm -r /tmp/odd

RUN if [ "$VERSION_MUSIC_ENCODING" = "latest" ] ; then \
    VERSION_MUSIC_ENCODING=$(curl "https://api.github.com/repos/TEIC/Stylesheets/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")'); \    
    fi \
    && echo "Stylesheet version set to ${VERSION_MUSIC_ENCODING}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders (${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/stylesheet.zip https://github.com/TEIC/Stylesheets/releases/download/v${VERSION_MUSIC_ENCODING}/tei-xsl-${VERSION_MUSIC_ENCODING}.zip \
    && unzip /tmp/stylesheet.zip -d /tmp/stylesheet \
    && rm /tmp/stylesheet.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/stylesheet \
    && cp -r /tmp/stylesheet/xml/tei/stylesheet/*  ${TEI_SOURCES_HOME}/stylesheet \
    && rm -r /tmp/stylesheet

RUN if [ "$VERSION_DATA_CONFIGURATION" = "latest" ] ; then \
    VERSION_DATA_CONFIGURATION=$(curl "https://api.github.com/repos/TEIC/TEI/releases/latest" | grep -Po '"tag_name": "P5_Release_\K.*?(?=")'); \   
    fi \
    && echo "Stylesheet version set to ${VERSION_DATA_CONFIGURATION}" \
    # download the required tei odd and stylesheet sources in the image and move them to the respective folders ( ${TEI_SOURCES_HOME})
    && curl -s -L -o /tmp/odd.zip https://github.com/TEIC/TEI/releases/download/P5_Release_${VERSION_DATA_CONFIGURATION}/tei-${VERSION_DATA_CONFIGURATION}.zip \
    && unzip /tmp/odd.zip -d /tmp/odd \
    && rm /tmp/odd.zip \
    && mkdir -p  ${TEI_SOURCES_HOME}/odd \
    && cp -r /tmp/odd/xml/tei/odd/*  ${TEI_SOURCES_HOME}/odd \
    && rm -r /tmp/odd

VOLUME ["/usr/share/xml/tei/stylesheet", "/usr/share/xml/tei/odd"]

EXPOSE 8080 8081

ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]

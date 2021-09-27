#########################################
# Dockerfile for setting up the MEIGarage.
# This installs dependencies to the system, 
# then downloads the latest artifacts 
# of the MEIGarage (backend),
# and installs it in a Tomcat application server
#########################################
FROM tomcat:7

ENV CATALINA_WEBAPPS ${CATALINA_HOME}/webapps
ENV OFFICE_HOME /usr/lib/libreoffice

USER root:root

RUN apt-get update \
    && apt-get install -y libreoffice \
    ttf-dejavu \
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
    && ln -s ${OFFICE_HOME} /usr/lib/openoffice \
    && rm -rf /var/lib/apt/lists/*

# installs lilypond into /usr/local/lilypond and /usr/local/bin as shortcut
ADD https://lilypond.org/download/binaries/linux-64/lilypond-2.20.0-1.linux-64.sh /tmp/lilypond.sh
RUN chmod a+x /tmp/lilypond.sh \
    && /tmp/lilypond.sh --batch

# clone and run
RUN git clone -b master https://github.com/rism-ch/verovio /tmp/verovio \
    && cd /tmp/verovio/tools \
    && cmake ../cmake \
    && make -j 8 \
    && make install \
    && cp /tmp/verovio/fonts/VerovioText-1.0.ttf /usr/local/share/fonts/ \
    && fc-cache

# entrypoint script
COPY docker-entrypoint.sh /my-docker-entrypoint.sh

# where do we put/get this? 
# COPY log4j.xml /var/cache/oxgarage/log4j.xml

# download artifacts to /tmp
# the war-file is zipped so we need to unzip it twice at the next stage 
ADD https://nightly.link/Edirom/MEIGarage/workflows/maven/main/meigarage.war.zip /tmp/meigarage.zip

RUN rm -Rf ${CATALINA_WEBAPPS}/ROOT \
    && unzip -q /tmp/meigarage.zip -d /tmp/ \
    && unzip -q /tmp/meigarage.war -d ${CATALINA_WEBAPPS}/meigarage/ \
    && cp ${CATALINA_WEBAPPS}/meigarage/WEB-INF/lib/oxgarage.properties /etc/ \
    && rm /tmp/*.war \
    && rm /tmp/*.zip \
    && chmod 755 /my-docker-entrypoint.sh

VOLUME ["/usr/share/xml/tei/stylesheet", "/usr/share/xml/tei/odd"]

EXPOSE 8080 8081

ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]

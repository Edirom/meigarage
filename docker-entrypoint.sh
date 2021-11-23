#!/bin/sh

# download TEI and MEI resources to /tmp & unzip resources and move them to correct folder
FOLDER_STY=/usr/share/xml/tei/stylesheet/profiles
if [ -d "$FOLDER_STY" ]; then
    echo "$FOLDER_STY exists."
else 
    echo "$FOLDER_STY will be downloaded."
    DOWNLOAD_URL_STY=$(curl -s https://api.github.com/repos/TEIC/Stylesheets/releases/latest \
        | grep browser_download_url \
        | cut -d '"' -f 4)
    curl -s -L -o /tmp/stylesheet.zip "$DOWNLOAD_URL_STY"
    unzip /tmp/stylesheet.zip -d /tmp/stylesheet
    rm /tmp/stylesheet.zip
    mkdir /usr/share/xml/tei/stylesheet
    cp -r /tmp/stylesheet/xml/tei/stylesheet/* /usr/share/xml/tei/stylesheet    
    rm -r /tmp/stylesheet
fi

FILE_ODD=/usr/share/xml/tei/odd/p5subset.xml
if [ -f "$FILE_ODD" ]; then
    echo "$FILE_ODD exists."
else 
    echo "$FILE_ODD will be downloaded."
    DOWNLOAD_URL_ODD=$(curl -s https://api.github.com/repos/TEIC/TEI/releases/latest \
        | grep browser_download_url \
        | cut -d '"' -f 4)
    curl -s -L -o /tmp/odd.zip "$DOWNLOAD_URL_ODD"
    unzip /tmp/odd.zip -d /tmp/odd
    rm /tmp/odd.zip
    mkdir /usr/share/xml/tei/odd
    cp -r /tmp/odd/xml/tei/odd/* /usr/share/xml/tei/odd
    rm -r /tmp/odd
fi

FOLDER_W3C=/usr/share/xml/mei/music-stylesheets/w3c-musicxml/schema
if [ -d "$FOLDER_W3C" ]; then
    echo "$FOLDER_W3C exists."
else 
    echo "$FOLDER_W3C will be downloaded."
    DOWNLOAD_URL_W3C=$(curl -s https://api.github.com/repos/w3c/musicxml/releases/latest \
        | grep browser_download_url \
        | cut -d '"' -f 4)
    curl -s -L -o /tmp/w3c.zip "$DOWNLOAD_URL_W3C"
    unzip /tmp/w3c.zip -d /tmp/w3c
    rm /tmp/w3c.zip
    mkdir /usr/share/xml/mei/music-stylesheets/w3c-musicxml/
    cp -r /tmp/w3c/* /usr/share/xml/mei/music-stylesheets/w3c-musicxml/
    rm -r /tmp/w3c
fi

FOLDER_W3C=/usr/share/xml/mei/music-stylesheets/w3c-musicxml/schema
if [ -d "$FOLDER_W3C" ]; then
    echo "$FOLDER_W3C exists."
else 
    echo "$FOLDER_W3C will be downloaded."
    DOWNLOAD_URL_W3C=$(curl -s https://api.github.com/repos/w3c/musicxml/releases/latest \
        | grep browser_download_url \
        | cut -d '"' -f 4)
    curl -s -L -o /tmp/w3c.zip "$DOWNLOAD_URL_W3C"
    unzip /tmp/w3c.zip -d /tmp/w3c
    rm /tmp/w3c.zip
    mkdir /usr/share/xml/mei/music-stylesheets/w3c-musicxml/
    cp -r /tmp/w3c/* /usr/share/xml/mei/music-stylesheets/w3c-musicxml/
    rm -r /tmp/w3c
fi

# adding a HTTPS connector.
# Define the connector on port 8081 to handle
# originating HTTPS requests. Here we
# set scheme to https and secure to true. Tomcat
# will still serve this as plain HTTP because
# SSLEnabled is set to false.
# See https://creechy.wordpress.com/2011/08/22/ssl-termination-load-balancers-java/
CONNECTOR='<Connector port="8081" protocol="HTTP/1.1" maxThreads="150" clientAuth="false" SSLEnabled="false" scheme="https" secure="true" proxyPort="443" />';
sed -i -e "s@<Service name=\"Catalina\">@<Service name=\"Catalina\">$CONNECTOR@" ${CATALINA_HOME}/conf/server.xml

# run the command given in the Dockerfile at CMD 
exec "$@"

# Main stage
FROM alpine:3.20.2

# Copy necessary files
COPY scripts /scripts
COPY pipeline /pipeline
COPY src/main/resources/static/fonts/*.ttf /usr/share/fonts/opentype/noto/
#COPY src/main/resources/static/fonts/*.otf /usr/share/fonts/opentype/noto/

ARG VERSION_TAG

# Set Environment Variables
ENV DOCKER_ENABLE_SECURITY=false \
    VERSION_TAG=$VERSION_TAG \
    JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -XX:MaxRAMPercentage=75" \
    HOME=/home/stirlingpdfuser \
    PUID=1000 \
    PGID=1000 \
    UMASK=022


RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
# JDK for app
RUN echo "@testing https://mirrors.aliyun.com/alpine/edge/main" | tee -a /etc/apk/repositories && \
    echo "@testing https://mirrors.aliyun.com/alpine/edge/community" | tee -a /etc/apk/repositories && \
    echo "@testing https://mirrors.aliyun.com/alpine/edge/testing" | tee -a /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
        ca-certificates \
        tzdata \
        tini \
        bash \
        curl \
        shadow \
        su-exec \
        openssl \
        openssl-dev \
        openjdk21-jre \
# Doc conversion
        libreoffice \
# pdftohtml
        poppler-utils \
# OCR MY PDF (unpaper for descew and other advanced featues)
        ocrmypdf \
        tesseract-ocr-data-eng \
# CV
        py3-opencv \
# python3/pip
        python3 \
    py3-pip && \
# uno unoconv and HTML
    pip install --break-system-packages --no-cache-dir --upgrade unoconv WeasyPrint -i https://mirrors.aliyun.com/pypi/simple && \
    mv /usr/share/tessdata /usr/share/tessdata-original && \
    mkdir -p $HOME /configs /logs /customFiles /pipeline/watchedFolders /pipeline/finishedFolders && \
    fc-cache -f -v && \
    chmod +x /scripts/* && \
    chmod +x /scripts/init.sh && \
# User permissions
    addgroup -S stirlingpdfgroup && adduser -S stirlingpdfuser -G stirlingpdfgroup && \
    chown -R stirlingpdfuser:stirlingpdfgroup $HOME /scripts /usr/share/fonts/opentype/noto /configs /customFiles /pipeline && \
    chown stirlingpdfuser:stirlingpdfgroup /app.jar && \
    tesseract --list-langs

EXPOSE 8080/tcp

# Set user and run command
ENTRYPOINT ["tini", "--", "/scripts/init.sh"]
CMD ["java", "-Dfile.encoding=UTF-8", "-jar", "/app.jar"]

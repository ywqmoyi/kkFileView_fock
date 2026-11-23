FROM ubuntu:24.04

ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV KKFILEVIEW_VERSION=5.0.3

# 换阿里云源 + 装 JDK21、LibreOffice nogui、中文字体、转换依赖
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.aliyun.com@g;s@//security.ubuntu.com@//mirrors.aliyun.com@g' \
        /etc/apt/sources.list.d/ubuntu.sources && \
    echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80retries && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-21-jdk \
        libreoffice-core-nogui libreoffice-writer-nogui libreoffice-calc-nogui \
        libreoffice-impress-nogui libreoffice-draw-nogui libreoffice-math-nogui \
        libreoffice-impress \
        fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei \
        ttf-mscorefonts-installer \
        poppler-utils ghostscript ffmpeg \
        libxext6 libxrender1 libxt6 curl tzdata ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 刷新字体缓存
RUN fc-cache -fv

COPY server/target/kkFileView-${KKFILEVIEW_VERSION}.tar.gz /opt/
RUN cd /opt && tar -xzf kkFileView-${KKFILEVIEW_VERSION}.tar.gz && rm -f kkFileView-${KKFILEVIEW_VERSION}.tar.gz

WORKDIR /opt/kkFileView-${KKFILEVIEW_VERSION}/bin

EXPOSE 8012

HEALTHCHECK --interval=60s --retries=3 \
    CMD curl -f http://127.0.0.1:8012/actuator/health || exit 1

CMD ["./startup.sh"]

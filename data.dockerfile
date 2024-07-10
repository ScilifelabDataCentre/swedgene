FROM node:22.2.0
WORKDIR /swedgene
VOLUME /swedgene/data
RUN curl -fsSL https://github.com/samtools/samtools/releases/download/1.20/samtools-1.20.tar.bz2 \
    | tar -C /tmp -xjf-  \
    && cd /tmp/samtools-1.20 && ./configure && make all all-htslib && make install install-htslib \
    && cd - && rm -rf /tmp/samtools-1.20
RUN curl -fsSL --output /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/bin/yq
RUN npm install -g @jbrowse/cli
COPY config config
COPY scripts scripts
COPY Makefile .
ARG SWG_UID=1000
ARG SWG_GID=1000
RUN groupmod -g ${SWG_GID} node && usermod -u ${SWG_UID} -g ${SWG_GID} node
USER node
CMD ["make", "debug"]

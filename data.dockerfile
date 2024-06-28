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
# COPY config config fails
COPY config config
COPY scripts scripts
COPY Makefile .
CMD ["make", "debug"]

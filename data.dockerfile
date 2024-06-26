FROM node:22.2.0
WORKDIR /swedgene
VOLUME /swedgene/data
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq
RUN npm install -g @jbrowse/cli
RUN git init -q
# COPY config config fails
COPY config species
COPY scripts scripts/
COPY Makefile .
CMD ["make", "CONFIG_DIR=species", "debug"]

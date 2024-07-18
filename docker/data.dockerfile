ARG NODE_VERSION=22.2.0


# Stage 1:
FROM node:${NODE_VERSION} AS build
ARG SAMTOOLS_VERSION="1.20"

RUN curl -fsSL https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    | tar -C /tmp -xjf-  \
    && cd /tmp/samtools-${SAMTOOLS_VERSION} && ./configure && make all all-htslib && make install install-htslib \
    && cd - && rm -rf /tmp/samtools-${SAMTOOLS_VERSION}

RUN curl -fsSL --output /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/bin/yq

RUN npm install -g @jbrowse/cli

# Stage 2: Slim image to reduce size. 
FROM node:${NODE_VERSION}-slim 

WORKDIR /swedgene
VOLUME /swedgene/data

# Install missing dependencies, then clean up non-required files.
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    libdeflate0 \
    libcurl4 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy required installs from the build stage 
COPY --from=build /usr/local/bin/samtools /usr/local/bin/
COPY --from=build /usr/local/bin/htsfile /usr/local/bin/
COPY --from=build /usr/local/bin/bgzip /usr/local/bin/
COPY --from=build /usr/local/bin/tabix /usr/local/bin/
COPY --from=build /usr/bin/yq /usr/bin/
COPY --from=build /usr/local/lib/node_modules/@jbrowse /usr/local/lib/node_modules/@jbrowse
RUN ln -s /usr/local/lib/node_modules/@jbrowse/cli/bin/jbrowse /usr/local/bin/jbrowse

COPY config config
COPY scripts scripts
COPY Makefile .

ARG SWG_UID=1000
ARG SWG_GID=1000
RUN groupmod -g ${SWG_GID} node && usermod -u ${SWG_UID} -g ${SWG_GID} node
USER node

CMD ["make", "debug"]
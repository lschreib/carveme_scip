#This Dockerfile creates a functional CarveMe container using th SCIP solver
#Funtionality has been verified for the initial model carving.
#Functionality of gapfilling or other functions so far not verified.

FROM condaforge/mambaforge:23.11.0-0

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update -q && \
     apt-get install -q --yes --no-install-recommends \
        bzip2 \
        ca-certificates \
        git \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        openssh-client \
        wget \
        software-properties-common \
        tini \
        gawk

ENV PATH /opt/conda/bin:$PATH

CMD [ "/bin/bash" ]

RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority false && \
    mamba create -n CarveMe python=3.11 && \
    mamba install -n CarveMe -y diamond -c bioconda && \
    mamba install -n CarveMe -y pyscipopt -c conda-forge

RUN echo "source activate CarveMe" > ~/.bashrc

COPY carveme_scip-1.6.2.tar.gz /carveme_main/carveme_scip.tar.gz

ENV PATH /opt/conda/envs/CarveMe/bin:$PATH

#Install CarveMe 
RUN cd /carveme_main/ && \
    pip install carveme_scip.tar.gz

#Pre-built BIGG DIAMOND database to prevent issues when converting container into Singularity format    
RUN cd /opt/conda/envs/CarveMe/lib/python3.11/site-packages/carveme/data/generated && \
    diamond makedb --threads 4 --in bigg_proteins.faa -d bigg_proteins

RUN mkdir -p /carveme_tools
COPY misc /carveme_tools

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]
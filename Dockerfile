# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

ARG enable_spark
ARG enable_postgresql
ENV enable_spark=${enable_spark}
ENV enable_postgresql=${enable_postgresql}

# Set environment variables for PostgreSQL
ENV PG_PATH /usr/local/pgsql/13.1
ENV PG_DATA /var/lib/pgsql/13.1/data
ENV CONDA_DIR /miniconda3
ENV LD_LIBRARY_PATH $PG_PATH/lib:$LD_LIBRARY_PATH
ENV JAVA_HOME /usr/local/jdk1.8.0_202
ENV PATH $JAVA_HOME/bin:$PG_PATH/bin:$CONDA_DIR/bin:$PATH

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt-get update && apt-get install -y sudo wget git bzip2 vim openssh-server gcc build-essential libreadline-dev zlib1g-dev bison flex gdb libssl-dev libbz2-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev xz-utils libffi-dev liblzma-dev


RUN mkdir /pilotscope
WORKDIR /pilotscope

RUN git config --global http.postBuffer 524288000

# Set ssh
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


####### Install PilotScope Core #######
RUN git -c http.sslVerify=false clone --depth 1 --branch master https://github.com/alibaba/pilotscope.git PilotScopeCore
# Install Miniconda
RUN mkdir -p ${CONDA_DIR} && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${CONDA_DIR}/miniconda.sh && \
    bash ${CONDA_DIR}/miniconda.sh -b -u -p ${CONDA_DIR} && \
    rm -rf ${CONDA_DIR}/miniconda.sh

RUN conda create --name pilotscope python=3.8

# Install libraries
RUN source ${CONDA_DIR}/bin/activate pilotscope && \
    cd ./PilotScopeCore && \
    pip install -e . -i https://mirrors.aliyun.com/pypi/simple/   && \
    pip install -e '.[dev]' -i https://mirrors.aliyun.com/pypi/simple/

####### Install PostgreSQL #######
RUN if [ "$enable_postgresql" = "true" ]; then \
        git -c http.sslVerify=false clone --depth 1 --branch pilotscope-postgresql https://github.com/alibaba/pilotscope.git PilotScopePostgreSQL && \
        cd ./PilotScopePostgreSQL && \
        ./configure --prefix=$PG_PATH --enable-depend --enable-cassert --enable-debug CFLAGS="-ggdb -O0" && \
        make && make install && \
        sh install_extension.sh && \
        make && make install ; \
    fi

RUN if [ "$enable_postgresql" = "true" ]; then \
        # Create a non-root user
        echo 'root:root' | chpasswd && \
        useradd -m -s /bin/bash postgres && echo "postgres:postgres" | chpasswd && \
        # Change owner of PG_PATH to `postgres` user and allow access
        chown -R postgres:postgres /var && \
        chown -R postgres:postgres $PG_PATH && \
        chmod -R 777 $PG_PATH && \
        # Initialize the database
        su postgres -c "${PG_PATH}/bin/initdb -D $PG_DATA" && \
        # Configure PostgreSQL to allow connections
        echo "listen_addresses = '*'" >> $PG_DATA/postgresql.conf && \
        echo "host all all all md5" >> $PG_DATA/pg_hba.conf && \
        echo "shared_preload_libraries = 'pg_hint_plan'" >> $PG_DATA/postgresql.conf && \
        # Start the PostgreSQL service and set the password for the `postgres` user
        su postgres -c "${PG_PATH}/bin/pg_ctl -D $PG_DATA start" && \
        su postgres -c "${PG_PATH}/bin/psql -c \"ALTER USER postgres PASSWORD 'postgres';\"" \
    ; else \
        echo "PostgreSQL installation skipped"; \
    fi

######## Install Spark #######
USER root

RUN if [ "$enable_spark" = "true" ]; then \
        # Download and install PilotScope patch for Spark
        git -c http.sslVerify=false clone --depth 1 --branch pilotscope-spark https://github.com/alibaba/pilotscope.git PilotScopeSpark && \
        cd ./PilotScopeSpark && \
        # Download Spark
        wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2.tgz && \
        tar -xzvf spark-3.3.2.tgz && \
        rm spark-3.3.2.tgz; \
    fi

RUN if [ "$enable_spark" = "true" ]; then \
        # Apply patch
        cd ./PilotScopeSpark && \
        git config --global user.email "pilotscope@example.com" && \
        git config --global user.name "pilotscope" && \
        bash apply_patch.sh /pilotscope_spark.patch;  \
    fi


RUN if [ "$enable_spark" = "true" ]; then \
        # Install JDK
        wget https://github.com/WoodyBryant/JDK/releases/download/v2/jdk-8u202-linux-x64.tar.gz && \
        tar -xzf jdk-8u202-linux-x64.tar.gz -C  /usr/local/ && \
        rm jdk-8u202-linux-x64.tar.gz; \
    fi

RUN if [ "$enable_spark" = "true" ]; then \
        # Compile Spark
        cd ./PilotScopeSpark/spark-3.3.2 && \
        ./build/mvn -DskipTests clean package;\
    fi

RUN if [ "$enable_spark" = "true" ]; then \
        # Install PySpark
        cd ./PilotScopeSpark/spark-3.3.2/python && \
        source ${CONDA_DIR}/bin/activate pilotscope && \
        python setup.py install \
    ; else \
        echo "Spark installation skipped"; \
    fi

CMD ["/bin/bash"]
# PilotScope (For SparkSQL)

An extension named PilotScope for SparkSQL.

## Setup

This demo is based on a modified version of Spark 3.3.2, these are some related installation processes.

```bash
# 1. download the Spark 3.3.2
wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2.tgz
tar -xzvf spark-3.3.2.tgz

# 2. download the jdk-8u202-linux-x64.tar.gz 
#    and set JAVA_HOME & PATH in `~/.bashrc`
export JAVA_HOME=/path/to/your/jdk1.8.0_202
export PATH=$JAVA_HOME/bin:$PATH
source ~/.bashrc

# 3. apply PilotScope extension on it
cd spark-3.3.2/ && git apply ../0001-add-pilotscope-extensions.patch

# 4. compile and build Spark
./build/mvn -DskipTests clean package

# 5. install PySpark
cd python && python setup.py install
```
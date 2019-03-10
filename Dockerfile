FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
    apt update && \
    apt install -y git wget curl build-essential libatlas-base-dev && \
    apt build-dep -y caffe-cpu

RUN apt install -y python-dev python-tk && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    pip install numpy matplotlib scikit-image scipy protobuf

RUN git clone -b master --single-branch https://github.com/richzhang/colorization.git && \
    cd colorization && \
    sed -i 's|train/caffe-colorization.tar.gz|train/caffe-colorization_old.tar.gz|' train/fetch_caffe.sh && \
    ./train/fetch_caffe.sh && \
    ./models/fetch_release_models.sh

RUN cd colorization/caffe-colorization && \
    rm -rf python/caffe/_caffe.so && \
    sed -Ei 's/^# CPU_ONLY/CPU_ONLY/' Makefile.config && \
    sed -Ei 's/^USE_CUDNN/# USE_CUDNN/' Makefile.config && \
    sed -i 's|INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include|INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial|' Makefile.config && \
    sed -i 's|LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib|LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib/x86_64-linux-gnu/hdf5/serial/|' Makefile.config && \
    sed -i 's|/usr/lib/python2.7/dist-packages/numpy/core/include|/usr/local/lib/python2.7/dist-packages/numpy/core/include|' Makefile.config

RUN cd colorization/caffe-colorization && \
    make all && \
    make test && \
    make runtest && \
    make pycaffe

COPY colorize.py /colorization/colorization/colorize.py

ENV PYTHONPATH /colorization/caffe-colorization/python

ENTRYPOINT ["python", "/colorization/colorization/colorize.py", "--prototxt=/colorization/models/colorization_deploy_v2.prototxt", "--caffemodel=/colorization/models/colorization_release_v2.caffemodel"]

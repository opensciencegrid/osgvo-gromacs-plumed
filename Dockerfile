# based on https://github.com/ur-whitelab/docker-images/blob/master/plumed/gromacs/Dockerfile

FROM opensciencegrid/osgvo-ubuntu-18.04

#enable contributed packages
#RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list

#install dependencies
RUN apt-get update && apt-get install -y libfftw3-dev git cmake g++ gcc libblas-dev xxd openmpi-bin libopenmpi-dev && apt-get clean

#get plumed
RUN git clone -b v2.6 https://github.com/plumed/plumed2 /opt/plumed
WORKDIR /opt/plumed
RUN ./configure --enable-modules=all --prefix=/usr/share && make -j4 && make install && make clean

ENV PATH="/usr/share/bin/:$PATH"
ENV LIBRARY_PATH="/usr/share/lib/:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/usr/share/lib/:$LD_LIBRARY_PATH"
ENV PLUMED_KERNEL="/usr/share/lib/libplumedKernel.so"

#get gromacs
RUN git clone https://github.com/gromacs/gromacs /opt/gromacs
WORKDIR /opt/gromacs
RUN git fetch --tags && git checkout v2019.1
RUN /bin/bash -c "source /opt/plumed/sourceme.sh";\
    echo 3 | plumed patch -p;\
    mkdir build build_mpi;\
    cd /opt/gromacs/build;\
    cmake .. && make -j4 install && make clean;\
    ln -s /usr/local/gromacs/bin/gmx /usr/bin/gmx;\
    cd ../build_mpi;\
    cmake .. -DGMX_MPI=on && make -j4 install && make clean;\
    ln -s /usr/local/gromacs/bin/gmx_mpi /usr/bin/gmx_mpi;

COPY .singularity.d /.singularity.d



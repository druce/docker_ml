# http://www.science.smith.edu/dftwiki/index.php/Tutorial:_Docker_Anaconda_Python_--_4#Running_a_Jupyter_Notebook
# possibly there's a better base image that includes some of the below
# but ML distributions tend to be out of date and missing stuff
FROM nvidia/cuda
# FROM ubuntu

# just get latest versions from conda
# not pinning module versions via requirements.txt
ARG CONDA_VERSION=2019.10
ARG PYTHON_VERSION=3.6

# run updates
RUN apt-get -y update && yes|apt upgrade

# run apt installs necessary for Anaconda
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# more installs for for rllib
RUN apt-get update --fix-missing && \
    apt-get install -y libsm6 libxrender1 libfontconfig1 build-essential libglib2.0-0 libxext6 libxrender-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add user ubuntu with no password, add to sudo group
RUN adduser --disabled-password --gecos '' ubuntu
RUN adduser ubuntu sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ubuntu
WORKDIR /home/ubuntu/
RUN chmod a+rwx /home/ubuntu/

# Anaconda install
# https://www.anaconda.com/distribution/#download-section
RUN wget https://repo.anaconda.com/archive/Anaconda3-${CONDA_VERSION}-Linux-x86_64.sh
RUN bash Anaconda3-2019.10-Linux-x86_64.sh -b
RUN rm Anaconda3-2019.10-Linux-x86_64.sh
ENV PATH /home/ubuntu/anaconda3/bin:$PATH

# Miniconda install
# https://docs.conda.io/en/latest/miniconda.html
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# some cert problem sometimes
# RUN wget --no-check-certificate       https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# RUN bash Miniconda3-latest-Linux-x86_64.sh -b
# RUN rm Miniconda3-latest-Linux-x86_64.sh
# ENV PATH /home/ubuntu/miniconda3/bin:$PATH

# Updating Anaconda packages in base env
RUN conda init
RUN conda update conda
# updates everything, or a lot of stuff
# RUN conda update anaconda

# Create tf env
RUN conda create --name tf_gpu tensorflow-gpu python=${PYTHON_VERSION}
# https://pythonspeed.com/articles/activate-conda-dockerfile/
SHELL ["conda", "run", "-n", "tf_gpu", "/bin/bash", "-c"]
RUN conda update --all

# sometimes anaconda has eg tf 2.0 and we want tf 2.1
# pip install --upgrade tensorflow

# install anaconda packages not in tensorflow-gpu by default
RUN conda install -y pandas tabulate matplotlib seaborn jupyter
RUN pip install gym opencv-python lz4 ray ray[debug] msgpack

# Configure access to Jupyter with password 'root'
RUN mkdir -p '/home/ubuntu/.jupyter'
COPY jupyter_notebook_config.py /home/ubuntu/.jupyter/jupyter_notebook_config.py

# install a certificate and configure SSL
# openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem
# <hit enter for everything>
RUN mkdir -p '/home/ubuntu/certs'
COPY mycert.pem /home/ubuntu/certs/mycert.pem

RUN echo "#!/bin/bash" > runjupyter.sh
RUN echo "/home/ubuntu/anaconda3/envs/tf_gpu/bin/jupyter notebook --notebook-dir=/home/ubuntu --no-browser" >> runjupyter.sh
RUN chmod +x ./runjupyter.sh

# Jupyter listens on port 8888
EXPOSE 8888

# Run Jupyter notebook as Docker main process
CMD ["/home/ubuntu/anaconda3/envs/tf_gpu/bin/jupyter", "notebook", "--notebook-dir=/home/ubuntu", "--no-browser"]

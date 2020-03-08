#### A Docker configuration for machine learning

Why Docker for machine learning?

- *Portability*: Move your ML environment easily from AWS to Google Cloud to Azure to your laptop to corporate cloud.
- *Reproduceability*: Save the image of the Docker container that ran a set of research experiments in a  repository, and as long as the repo, Docker and suitable hardware are around, you can reproduce the environment and experiments exactly.
- *Production integration*: Modern cloud-based applications are increasingly loosely coupled microservices in containers. Take an ML model container, add a Flask REST API, and you have a (nearly) production-ready microservice, or at least one in a package the production team can easily understand and integrate.

Once you've captured your environment as code, you can save it, move it around and reproduce many copies of complex environments with one or two commands.

This is set up to run on an instance with 50GB of disk space and GPU. Caveat: I'm a Docker neophyte, this may not follow best practices, I am trying to install everything under the sun I may need, tested only on Ubuntu, YMMV.

**1) [Install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) per website docs, TL;DR:** 

​	*a)* Install Docker prerequisites

```bash
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common 

```

​	*b)* Add GPG key and repository to apt

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

​	*c)* Install

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

​	*d)* Add user to Docker group (log in and out to make changes take effect)

```bash
sudo usermod -aG docker ${USER}
```

​	*e)* Test Docker

```bash
docker run hello-world
```

**2) Install  nvidia-docker for GPU support** (skip if you don't have/need Nvidia GPU support) 
Before installing, run `nvidia-smi` to make sure you have OS GPU support / drivers. See [Nvidia](https://devblogs.nvidia.com/gpu-containers-runtime/) for more information.

​	*a)* Add Nvidia apt key

```bash
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
```

​	*b)* Add apt repos

```bash
distrib=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -sL https://nvidia.github.io/nvidia-docker/$distrib/nvidia-docker.list | \
sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
```

​	*c)* Install nvidia-docker2

```bash
sudo apt install -y nvidia-docker2
```

​	*d)* Restart Docker

```bash
sudo pkill -SIGHUP dockerd
```

​	*e)* Check docker sees GPU

```bash
sudo docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
```

**3) Build the docker_ml container** 

- cd to the directory containing Dockerfile
- If you don't want GPU support, edit the Dockerfile
  - comment out ```FROM nvidia/cuda```
  - uncomment ```FROM ubuntu```
- Build the container (this will take a long long time and > 10GB of disk space)

```bash
docker build -t docker_ml .
```

**4) Run the container**

- For Jupyter:

  ```bash
  docker run --runtime=nvidia --name docker_ml -p 8888:8888 -v "$PWD:/home/ubuntu/local" --rm docker_ml
  ```

  - Current working directory on the host will be mounted as `/home/ubuntu/local` in the container, edit as necessary for access to your notebooks

  - Connect to the Jupyter server on port 8888 using https://<your_ip> . Ignore warnings about the self-signed https certificate. If you are connecting to a remote server via a firewall, make sure that port allows incoming traffic from your IP.

  - Password will be `root`

  - To check for functioning GPU, create a new Python notebook and say

    ```python
    import tensorflow as tf
    print(tf.__version__)
    print(tf.config.list_physical_devices('GPU'))
    
    2.1.0
    [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
    ```

- For a command line:

```bash
docker run --runtime=nvidia --name docker_ml -p 8888:8888 -v "$PWD:/home/ubuntu/local" -it --rm docker_ml bash
```

- Docker is beyond the scope of this document. See for example:

  - [https://docker-curriculum.com/](https://docker-curriculum.com/)
  - https://github.com/wsargent/docker-cheat-sheet
  - https://dockerbook.com/
  - Neverthless. a few commands to get started:
  
  ```bash
  # show containers
  docker ps -a
  # show images
  docker image ls
  # stop a running container
  docker stop <container_id>
  # remove a container
  docker rm <container_id>
  # remove an image
  docker image rm <container_id>
  # clean up images to save disk space
  docker image prune --all
  # clean up containers
  docker container prune
  ```
  
  

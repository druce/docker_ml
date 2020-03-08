#### A Docker configuration for machine learning

**1) [Install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) per website docs, TL;DR:** 

​	a) Install Docker requirements

```bash
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \

```

​	b) Add GPG key and repository to apt

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

​	c) Install

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

​	d) Add user to Docker group (log in and out to make changes take effect)

```bash
sudo usermod -aG docker ${USER}
```

​	e) Test Docker

```bash
docker run hello-world
```

**2) Install  nvidia-docker for GPU support** (skip if you don't have/need Nvidia GPU support) 
Run `nvidia-smi` to make sure you have GPU support and current drivers. See [Nvidia](https://devblogs.nvidia.com/gpu-containers-runtime/) for more information.

​	a) Add Nvidia apt key

```bash
curl -sL https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -n
```

​	b) Add apt repos

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -sL https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update

```

​	c) Install nvidia-docker2

```bash
sudo apt install -y nvidia-docker2
```

​	d) Restart Docker

```bash
sudo pkill -SIGHUP dockerd
```

​	e) Check docker sees GPU

```bash
sudo docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
```

**3) Build the container** 

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
  docker run --runtime=nvidia --name docker_ml -p 8888:8888 -v "$PWD:/home/ubuntu/docker_ml" --rm docker_ml
  ```

  - Current working directory will be mounted as `/home/ubuntu/docker_ml` , edit as necessary for access to your notebooks
  - Connect to the Jupyter server on port 8888
  - Password will be `root`

- For command line:

```bash
docker run --runtime=nvidia --name docker_ml -p 8888:8888 -v "$PWD:/home/ubuntu/docker_ml" -it --rm docker_ml bash
```

- Docker is beyond the scope (see [https://docker-curriculum.com/](https://docker-curriculum.com/)) but a few commands to get started:

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

  

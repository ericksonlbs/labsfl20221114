# labsfl20221114 (Laboratory Spectrum Fault Localization 2022.11.14)

## Purpose
This laboratory aim to test the execution time from [Flacoco](https://github.com/SpoonLabs/flacoco), [Jaguar](https://github.com/saeg/jaguar) and [Jaguar2](https://github.com/saeg/jaguar2), in the projects: "Time", "Jsoap", "Lang", "Gson", "Csv" and "Collections", from dataset [Defects4J](https://github.com/rjust/defects4j).

## Available
To running this laboratory, was created container image and available in Docker Hub, on address ericksonlbs/labsfl20221114, but it is also possible to build image through this repository. Also it's available a script to running container on cloud, on service **AZURE CONTAINER INSTANCE** from Microsoft Azure.

## Running the container available in the Docker Hub
STEP 1: Pull image `ericksonlbs/labsfl20221114:latest` from Docker Hub.
```
docker pull ericksonlbs/labsfl20221114:latest
```
STEP 2: Docker run image. 
Change `/tmp/labsfl20221114` to your local path result.
The parameter `REPEAT` set an environment variable to define amount repeat will be executed for each project.
```
docker run --name labsfl20221114 --env REPEAT=10 --rm -v /tmp/labsfl20221114:/labsfl20221114/test ericksonlbs/labsfl20221114:latest
```

## Compiling and running the container locally via this git repository
STEP 1: Clone repository
```
git clone https://github.com/ericksonlbs/labsfl20221114
```

STEP 2: Enter on path
```
cd labsfl20221114
```

STEP 3: Build image
```
docker build -t labsfl20221114:latest . 
```

STEP 4: Running container with mounted volume to export result. 
Change `/tmp/labsfl20221114` to your local path result.
The parameter `REPEAT` set an environment variable to define amount repeat will be executed for each project.
```
docker run --name labsfl20221114 --env REPEAT=10 --rm -v /tmp/labsfl20221114:/labsfl20221114/test labsfl20221114:latest
```

## Running the container on Azure Container Instance
O file [azure-container-instance.sh](azure-container-instance.sh) contain script with created resources to running container on **Azure Container Instance**, this script using [Azure CLI](https://learn.microsoft.com/pt-br/cli/azure/), then can you to execute on Cloud Shell from Azure Portal or install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and to run locally. PS.: Change the four parameters as needed in the file [azure-container-instance.sh](azure-container-instance.sh).

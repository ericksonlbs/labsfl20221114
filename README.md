# labsfl20221114 (Laboratory Spectrum Fault Localization 2022.11.14)

## Purpose
This laboratory aim to test the execution time from [Flacoco](https://github.com/SpoonLabs/flacoco), [GZoltar](https://github.com/GZoltar/gzoltar), [Jaguar](https://github.com/saeg/jaguar) and [Jaguar2](https://github.com/saeg/jaguar2), in the projects: "Codec", "Collections", "Compress", "Csv", "Gson", "JacksonDatabind", "JacksonXml", "Jsoup", "Lang", "Math" and "Time", from dataset [Defects4J](https://github.com/rjust/defects4j).

## Available
To running this laboratory it is possible to build container image through this repository.

## Compiling and running the container locally via this git repository
STEP 1: Clone repository
```
git clone https://anonymous.4open.science/r/labsfl20221114
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
The parameter `REPEAT` set an environment variable to define amount repeat will be executed for each project. Set parameters `TOOL` (options: Flacoco, GZoltarCLI, GZoltarMaven, Jaguar, Jaguar2), `PROJECT` (options: `Codec`, `Collections`, `Compress`, `Csv`, `Gson`, `JacksonDatabind`, `JacksonXml`, `Jsoup`, `Lang`, `Math` and `Time`) and `VERSION` (To tools GZoltarMaven and Jaguar2, must be specific version for each project: Codec=18, Collections=25, Compress=47, Csv=1, Gson=18, JacksonDatabind=80, JacksonXml=1, Jsoup=93, Lang=1, Math=104 and Time=1). Sample:
```
docker run --name labsfl20221114 --env REPEAT=10 --env PROJECT=Csv --env VERSION=1 --env TOOL=Jaguar2 --rm -v /tmp/labsfl20221114:/labsfl20221114/test labsfl20221114:latest
```
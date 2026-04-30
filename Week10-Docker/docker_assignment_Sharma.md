---
title: "Docker_Assignment_Ramik"
author: "Ramik S"
date: "2026-04-30"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

```{r cars}
summary(cars)
```

## Including Plots

You can also embed plots, for example:

```{r pressure, echo=FALSE}
plot(pressure)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.

## Docker Assignment 

## Part 1.Mechanics
## Task 1.1 — Change the Python version

$ docker build -t hello-docker .
[+] Building 2.4s (8/8) FINISHED
 => [internal] load build definition from Dockerfile                      0.0s
 => => transferring dockerfile: 146B                                      0.0s
 => [internal] load .dockerignore                                         0.0s
 => => transferring context: 2B                                           0.0s
 => [internal] load metadata for docker.io/library/python:3.9-slim        1.1s
 => [1/4] FROM docker.io/library/python:3.9-slim@sha256:513...            0.0s
 => [internal] load build context                                         0.0s
 => => transferring context: 52B                                          0.0s
 => [2/4] WORKDIR /app                                                    0.1s
 => [3/4] RUN pip install numpy==1.26.4                                   0.9s
 => [4/4] COPY hello.py .                                                 0.1s
 => exporting to image                                                    0.1s
 => => exporting layers                                                   0.1s
 => => writing image sha256:7f2e1a9c8...                                  0.0s
 => => naming to docker.io/library/hello-docker                           0.0s

$ docker run --rm hello-docker
Hello from Python 3.9 inside a container!


### Task 1.2 — Break and fix the Dockerfile

$ docker build -t hello-docker .
[+] Building 0.8s (8/8) FINISHED
...
 => => naming to docker.io/library/hello-docker                           0.0s

$ docker run --rm hello-docker
Traceback (most recent call last):
  File "/app/hello.py", line 1, in <module>
    import sys, pandas
ModuleNotFoundError: No module named 'pandas'

### Run is successful after adding pinned pandasto the Dockerfile

$ docker build -t hello-docker .
[+] Building 11.2s (8/8) FINISHED
 => [internal] load build definition from Dockerfile                      0.0s
 => => transferring dockerfile: 182B                                      0.0s
 => [internal] load .dockerignore                                         0.0s
 => => transferring context: 2B                                           0.0s
 => [internal] load metadata for docker.io/library/python:3.9-slim        0.9s
 => [1/4] FROM docker.io/library/python:3.9-slim@sha256:513...            0.0s
 => [internal] load build context                                         0.0s
 => => transferring context: 110B                                         0.0s
 => [2/4] WORKDIR /app                                                    0.1s
 => [3/4] RUN pip install numpy==1.26.4 pandas==2.2.0                     9.5s
 => [4/4] COPY hello.py .                                                 0.1s
 => exporting to image                                                    0.5s
 => => exporting layers                                                   0.5s
 => => writing image sha256:9d4b2f1e6...                                  0.0s
 => => naming to docker.io/library/hello-docker                           0.0s

$ docker run --rm hello-docker
Python 3.9, pandas 2.2.0


## FInal DockerFile

FROM python:3.9-slim
WORKDIR /app
RUN pip install numpy==1.26.4 pandas==2.2.0
COPY hello.py .
CMD ["python", "hello.py"]


## Part 2.Reproducibility judgment
### Question 2.1 — Why pin?
In Task 1.2 you pinned a specific version of pandas. Suppose you had instead written RUN pip install pandas (no version). Your Dockerfile would still build and run today. Why is this a reproducibility problem? What concretely could go wrong, and when?
### Answer 2.1 
If you do not pin the version of pandas, then when you build the Docker image in the future, it will install the latest version of pandas available at that time. This can lead to reproducibility issues because the latest version of pandas may have changes or updates that are not compatible with your code. In case  a new version of pandas introduces a breaking change or deprecates a function that the current code relies on, the application might fail to run correctly or to run at all. This could happen immediately after a new release of pandas or at any point in the future when you try to rebuild the image. Pinning the version, ensures that the  application always uses the same version of pandas, which helps maintain consistency and serves the reproducibility purpose.
### Question 2.2 —— Recipe or cake?
If you want a colleague to reproduce your work, you can either send them the built image (e.g. via Docker Hub) or send them only the Dockerfile and hello.py. Which is better for reproducible research, and why? Give one concrete reason beyond "easier" or "faster."
### Answer 2.2
Sending the Dockerfile and hello.py together is better for reproducible research because it allows the colleague to understand the exact steps and dependencies required to build the image as it is in plain text. This transparency is crucial for reproducibility, as it enables others to verify and modify the environment if needed. Cases where  there are  security vulnerabilities in one of the dependencies, the colleague/reviewer can easily update the Dockerfile to use a patched version. Whereas, sending alone the built image does not provide this level of information or flexibility, making it harder for others to reproduce or adapt your work in the future.

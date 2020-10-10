# Reproducible research with build tools

The goal of this project is to help reproducible research by creating a fully self-contained repo that runs the entire analysis. The major benefit of this is that you can be 100% certain that an analysis can be reproduced, as it is automatically created from git and the compute specifications.

This example uses R and Rmarkdown, but thanks to the flexible build pipeline, there are only a few requirements for an analysis: It must be dockerizeable, it must be programmable and it must have input and output. You can use Jupyter notebooks, python, julia, or anything else you can throw into docker. And you can combine them to write an analysis where parts are built in python and parts in R.

The only requirement is that your stuff has to run in docker.


## The workflow

There are two configurations in this project, for AWS and GCP respectively, utilizing their CI/CD build tools codebuild in AWS and cloudbuild in GCP.

- The project contains a Dockerfile, specifying how to build a docker image capable of running the analysis. This means that any R library needed, has to be installed in the container. As the analysis progresses and new visualizations, processing steps and more is added, any new libraries needed have to be specified in the Dockerfile.
- When working on the analysis, use the image that results from the Dockerfile. You can build this locally with `docker build -t <myiemagename> .`
- Cloudbuild/Codebuild builds the docker image from the dockerfile, saves it to a container registry, and uses this image to run the analysis. The output, is saved as an artifact to a cloud bucket.
- The configuration for GCP cloudbuild is in the `cloudbuild.yaml` file. The configuration for AWS Codebuild is in buildspec.yaml. This is the instructions that builds the image, runs the analysis, and saves the resulting file (in this case a PDF) in the specified location. In order to maintain a history of the analysis, versioning should be turned on for this bucket.
- The cloud build project needs to be set up separately. If you are on GCP and fairly new to the game, this is probably most easily done through the console at cloud.google.com. Unfortunately, this repo does not (so far) include any instructions for this, but the console makes it fairly straightforward to set up cloud build and adding a trigger. Normally, you'd want a trigger for merges to master. For AWS Codebuild, a config template for  is supplied as `buildjob_template.json`. You will need to fill in some details, but once that's done the build job can be declared by calling `aws codebuild update-project --cli-input-json file://buildjob.json`. You still need to configure a trigger (could surely be done through the config file, but has been omitted for random reasons).


## The tradeoffs

- For people not immersed in the docker and CI/CD world, this workflow introduces a lot of new concepts. As data analysis is difficult enough as it is, it might not be very tempting to sit down and learn a whole lot of new stuff just for a workflow designed to make some farily esoteric guarantees (don't get me wrong, reproducible research is important, but this workflow only assures technical reproducibility).

- For larger projects, the build times will be large, possibly racking up compute charges. All input must be stored either in the project or on the internet somewehere - possibly in a cloud bucket. This of course introduces new problems: Are your data analysis tools able to read from a bucket directly? Is the bucket publically available or does the container need access tokens? It may be possible, and easier, to download the required bucket files through the buildscript itself, as it runs with an explicit role set by the job which you can also grant bucket rights. On GCP this might work through the container itself as the container is run directly, but on AWS your container is unlikely to inherit the role assigned to the build job. To be honest the differences between how the setup is on GCP and AWS is striking. On GCP I'm fairly confident I came up with the best solution, but the AWS solution is one of many. And, strangely, the AWS solution could be adapted to GCP, so the build patterns can be a lot more similar if that is a goal.


## Lastly

Reproducible research is important and it has been a big theme over the last years, but technical reproducibility like this is only a drop in the bucket compared to other, more important types of reproducibility. Nonetheless, this type of reproducibility is easy to do something about, so there is no reason not to.

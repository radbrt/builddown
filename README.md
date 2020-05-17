# Reproducible research with build tools

This project is testing a workflow for reproducible research using R markdown, docker and cloud build (a GCP CI/CD tool).

The basic workflow is as follows:
- The project contains a Dockerfile, specifying how to build a docker image capable of running the analysis. This means that any R library needed, has to be installed in the container. As the analysis progresses and new visualizations, processing steps and more is added, any new libraries needed have to be specified in the Dockerfile.
- When working on the analysis, use the image that results from the Dockerfile. You can build this locally with `docker build -t <myiemagename> .`
- Cloudbuild builds the docker image from the dockerfile, saves it to google container registry, and uses this image to run the analysis. The output, is saved as an artifact to a cloud bucket.
- The configuration for cloudbuild is in the `cloudbuild.yaml` file. This is the instructions that builds the image, runs the analysis, and saves the resulting file (in this case a PDF) in the specified location. In order to maintain a history of the analysis, versioning should be turned on for this bucket.
- The cloud build project needs to be set up separately. If you are new to GCP, this is probably most easily done through the console at cloud.google.com. Unfortunately, this repo does not (so far) include any instructions for this, but the console makes it fairly straightforward to set up cloud build and adding a trigger. Normally, you'd want a trigger for merges to master.

The basic goal of this project is to create a fully self-contained repo that runs the entire analysis. The major benefit of this is that you can be 100% certain that an analysis can be reproduced, as it is automatically created from git.

This example uses R and Rmarkdown, but thanks to the flexible build pipeline, there are only a few requirements for an analysis: It must be dockerizeable, it must be programmable and it must have input and output. You can use Jupyter notebooks, python, julia, or anything else you can throw into docker. And you can combine them to write an analysis where parts are built in python and parts in R.

There are some tradeoffs though:
- For larger projects, the build times will be large, possibly racking up compute charges. All input must be stored either in the project or on the internet somewehere - possibly in a cloud bucket. As the project uses GCP it is tempting to use a google bucket for this, but since nobody uses google buckets, they are not really supported by anything in the world and it's a pain to get data from a google bucket into R.
- For people not immersed in the docker and CI/CD world, this workflow introduces a lot of new concepts. As data analysis is difficult enough as it is, it might not be very tempting to sit down and learn a whole lot of new stuff just for a workflow designed to make some farily esoteric guarantees (don't get me wrong, reproducible research is important, but this workflow only assures technical reproducibility).


## The way forward

- The normal workflow people would have with Rmarkdown means there will be a copy of the output (article) in the repo, but this article might not be the same as the one built by cloudbuild - and so confusion may ensue. Ideally the artifact should be committed back to the repo, but this would trigger a new commit which might trigger a new build which... you get the idea. The quickest fix is to simly add the output (article.pdf in this case) to the `.gitignore` file.This, however, means that we have to link to the article somewhere - possibly from the readme.

- Larger projects are a pain. It would be very interesting to include drake in this workflow in order to reduce build times. The drawback to that, however, is that the technical complexity of doing an analysis would skyrocket.

- Building the docker image is ususally unnecessary, as the analysis changes way more often than the dockerfile. Finding a way to prevent the image from building if there are no changes to the dockerfile would be great. Another option would be to fix this with branches: Master branch always triggers rebuild, but create another branch that triggers a different cloudbuild file, that uses the existing image and simply reruns the analysis. Drawbacks here is that you might change the Dockerfile and push to this lightweight branch and get a build error.

- Instead of simply versioning the output bucket, it would be helpful to create explicitly different article names for each build. This is probably simple to do using the `$SHORT_SHA` variable - the best solution might be to output the artcle twice per build: one as `article.pdf``and one as `article_$SHORT_SHA.pdf`

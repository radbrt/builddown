FROM rocker/geospatial

RUN install2.r --error --deps TRUE \
	janitor

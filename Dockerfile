FROM debian:jessie

# MAINTAINER Henry

RUN apt-get update && apt-get install -y \
    elvis-tiny \
    lcov 

CMD ["/bin/bash"]

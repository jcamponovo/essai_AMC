FROM debian:stable


RUN apt-get update && apt-get install apt.txt
RUN apt-get install jupyter

CMD ["jupyter","notebook","--ip","0.0.0.0"]


WORKDIR /home/docker

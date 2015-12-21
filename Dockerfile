FROM mosaiksoftware/debian:onbuild
MAINTAINER  Chrisitan Holzberger <ch@mosaiksoftware.de>

##### PACKAGE INSTALLATION #####
RUN mkdir /capture && \
 	chmod 777 /capture 

RUN set-selections machinery-build
#FFMPEG FROM SOURCE
RUN echo "include /usr/local/lib" >> /etc/ld.so.conf
COPY ./ffmpeg /usr/src/ffmpeg
RUN cd /usr/src/ffmpeg && ./configure --enable-swscale --enable-avfilter --enable-libmp3lame --enable-gpl --enable-libx264 --enable-nonfree --enable-postproc --enable-version3 --enable-shared --enable-pic  && \
	make -j8 && \
	make install && \
	ldconfig

######## MACHINERY ############

COPY ./machinery /app
RUN cd /app && rm .git && mkdir build && cd build && cmake .. && make && make check && \
	chmod -R 777 /app/config 
# ################################

COPY ./config/machinery /app/config/
COPY ./run.sh /
RUN chmod a+x /run.sh
VOLUME /capture
CMD exec /run.sh

FROM mosaiksoftware/debian:onbuild
MAINTAINER  Chrisitan Holzberger <ch@mosaiksoftware.de>

##### PACKAGE INSTALLATION #####
RUN set-selections machinery-build
#FFMPEG FROM SOURCE 

COPY ./ffmpeg /usr/src/ffmpeg
RUN echo "include /usr/local/lib" >> /etc/ld.so.conf && \
	cd /usr/src/ffmpeg && \
	./configure --enable-swscale --enable-avfilter --enable-libmp3lame --enable-gpl --enable-libx264 --enable-nonfree --enable-postproc --enable-version3 --enable-shared --enable-pic  && \
	make -j8 && \
	make install && \
	ldconfig 

# MACHINERY INSTALLATION
COPY ./machinery /app
RUN	cd /app && \
	rm .git && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make check && \
	chmod -R 777 /app/config 

# VOLUME
RUN mkdir /capture && \
 	chmod 777 /capture 

VOLUME /capture

#################################
COPY ./config/machinery /app/config/
COPY ./run.sh /
RUN chmod a+x /run.sh
CMD exec /run.sh

FROM mosaiksoftware/debian
MAINTAINER  Chrisitan Holzberger <ch@mosaiksoftware.de>

ENV DEBIAN_FRONTEND noninteractive
##### PACKAGE INSTALLATION #####
COPY ./config/dpkg_nodoc /etc/dpkg/dpkg.conf.d/01_nodoc

COPY ./config/apt_nosystemd /etc/apt/preferences.d/systemd
RUN echo "Yes, do as I say!" | apt-get remove -y --force-yes --purge --auto-remove systemd sysv-rc
# get sources 
COPY config/source.list /etc/apt/sources.list
RUN mkdir /capture && \
 	chmod 777 /capture && \
	/set-selections.sh machinery-build 		
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

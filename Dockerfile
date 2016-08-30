FROM python:2.7
MAINTAINER Victor Kulichenko <onclev@gmail.com>
ARG PUID=1000
ARG PGID=1000
#ENV PUID=${PUID:-1000} PGID=${PGID:-1000}
COPY plex-scrobble /plex-scrobble
RUN groupadd -g $PGID plex && useradd -m -g $PGID -u $PUID plex
RUN cd /tmp \
 && git clone https://github.com/jesseward/plex-lastfm-scrobbler.git \
 && cd plex-lastfm-scrobbler \
 && python setup.py install \
 && cp /root/.config/plex-lastfm-scrobbler/plex_scrobble.conf / \
 && rm -R /tmp/plex-lastfm-scrobbler /root/.config/plex-lastfm-scrobbler \
 && mkdir -p /home/plex/.config/plex-lastfm-scrobbler \
 && sed -i -e 's%/tmp/plex_scrobble.log%/home/plex/.config/plex-lastfm-scrobbler/plex_scrobble.log%g' \
           -e 's%/path/to/plex/media/server/log%/config/Library/Application Support/Plex Media Server/Logs/Plex Media Server.log%g' /plex_scrobble.conf \
 && chown plex:plex -R /home/plex/.config /plex_scrobble.conf \
 && chmod +x /plex-scrobble
USER plex
VOLUME ["/home/plex/.config/plex-lastfm-scrobbler"]
CMD ["/plex-scrobble"]

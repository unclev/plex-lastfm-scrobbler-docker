### Building the image
To build an image execute at command prompt
```bash
docker build -t plex_scrobbler .
```
This creates an image with plex user having uid(1000) and gid(1000) - the typicall fist ubuntu user. 
plex-lastfm-scrobbler executes in the name of plex user.

You may want changing plex user uid and pid, for eg. 1001. To do so build with build arguments:
```bash
docker build -t plex_scrobbler --build-arg PUID=1001 --build-arg PGID=1001 .
```
### Configuration changes
The image is supposed to be working with https://github.com/linuxserver/docker-plex.

mediaserver_log_location is chaged in the image to /config/Library/Application Support/Plex Media Server/Logs/Plex Media Server.log so that it matches linuxserver/plex log location.
plex_scrobble.log location is also moved to /home/plex/.config/plex-lastfm-scrobbler/
The mediaserver_url = http://localhost:32400 is likely have to be changed (see below).

### Starting plex-scrobble for the first time
The follwong assumes the plex container is stared with docker run command similar to:
```bash
docker run \
    --name=plex_server \
    --net=host \
    -e VERSION=latest \
    -e PUID=1000 -e PGID=1000 \
    -v /srv/plex/data:/config \
    -v /srv/storage/Plex:/data \
    -d --restart='always' \
    linuxserver/plex
```

LastFM requires 3rd party acces to be comfirmed. Run plex-lastfm-scrobbler container similar to the follows (note -it --rm options, that is in interactive mode, and removing container after execution):
```bash
docker run \
    --name=plex_scrobbler \
    --net=host \
    -v /srv/plex/plex-lastfm-scrobbler:/home/plex/.config/plex-lastfm-scrobbler \
    --volumes-from plex_server \
    -it --rm \
    plex_scrobbler
```
it shows
```
== Requesting last.fm auth ==
Please accept authorization at http://www.last.fm/api/auth/?api_key=e692f685cdb9434ade9e72307fe53b05&token=3c0029d07fac43b225c2bd8341a43e30

Have you authorized me [y/N] :
```
Copy and follow the auth URL. Don't loiter with this - the token may have been expired. If expiration happened interrupt plex-scrobble with ctrl-C, and re-start the container as shown above.
As soon as autorized at last.fm web site, reply y, the application gracefully exits:
```
Have you authorized me [y/N] :y
Please relaunch plex-scrobble service.
```
By this point there are 3 files in the /srv/plex/plex-lastfm-scrobbler/ folder on your host machine, which was mapped to /home/plex/.config/plex-lastfm-scrobbler plex_scrobbler folder:
```
plex_scrobble.conf
plex_scrobble.log
session_key
```
Modify plex_scrobble.conf so that it matches your actual configuration and preferences.
The point of interest is mediaserver_url = http://localhost:32400
Change the url so that it matches your Plex/Web host.

### Starting plex-scrobble as a daemon
Do not forget setting up plex as it is recommended at https://github.com/jesseward/plex-lastfm-scrobbler/ 
In particular your Plex Server logs must be set at DEBUG level (not VERBOSE).
```
docker run \
    --name=plex_scrobbler \
    --net=host \
    -v /srv/plex/plex-lastfm-scrobbler:/home/plex/.config/plex-lastfm-scrobbler \
    --volumes-from plex_server \
    -d --restart='always' \
    plex_scrobbler
```

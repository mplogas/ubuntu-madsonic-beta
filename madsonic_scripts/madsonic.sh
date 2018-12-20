#!/bin/sh

###################################################################################
#   version: 6.3
#   Shell script for starting Madsonic.  
#   more help at http://forum.madsonic.org
###################################################################################

MADSONIC_HOME=/var/madsonic
MADSONIC_HOST=0.0.0.0
MADSONIC_PORT=4040
MADSONIC_HTTPS_PORT=4443
MADSONIC_CONTEXT_PATH=/
MADSONIC_INIT_MEMORY=256
MADSONIC_MAX_MEMORY=512
MADSONIC_DEFAULT_MUSIC_FOLDER=/media/music
MADSONIC_DEFAULT_UPLOAD_FOLDER=/media/incoming
MADSONIC_DEFAULT_PODCAST_FOLDER=/media/podcast
MADSONIC_DEFAULT_PLAYLIST_IMPORT_FOLDER=/media/playlists/import
MADSONIC_DEFAULT_PLAYLIST_EXPORT_FOLDER=/media/playlists/export
MADSONIC_DEFAULT_PLAYLIST_BACKUP_FOLDER=/media/playlists/backup
MADSONIC_DEFAULT_KEYSTORE_PASSWORD=madsonic
MADSONIC_DEFAULT_KEYSTORE=${MADSONIC_HOME}/madsonic.keystore
MADSONIC_DEFAULT_TRANSCODE_FOLDER=${MADSONIC_HOME}/transcode #/usr/local/bin	
MADSONIC_DEFAULT_TIMEZONE=Europe/Berlin
MADSONIC_PIDFILE=
MADSONIC_UPDATE=true
MADSONIC_GZIP=
MADSONIC_DB=
MADSONIC_PROXY=false
MADSONIC_PROXY_TYPE=http
MADSONIC_PROXY_HOST=localhost
MADSONIC_PROXY_PORT=8888
MADSONIC_USE_SSL=true
quiet=0

usage() {
    echo "Usage: madsonic.sh [options]"
    echo "  --help                                This small usage guide."
    echo "  --home=DIR                            The directory where Madsonic will create files."
    echo "                                        Make sure it is writable. Default: /var/madsonic"
    echo "  --host=HOST                           The host name or IP address on which to bind Madsonic."
    echo "                                        Only relevant if you have multiple network interfaces and want"
    echo "                                        to make Madsonic available on only one of them. The default value"
    echo "                                        will bind Madsonic to all available network interfaces. Default: 0.0.0.0"
    echo "  --port=PORT                           The port on which Madsonic will listen for"
    echo "                                        incoming HTTP traffic. Default: 4040"
    echo "  --https-port=PORT                     The port on which Madsonic will listen for"
    echo "                                        incoming HTTPS traffic. Default: 0 (disabled)"
    echo "  --context-path=PATH                   The context path, i.e., the last part of the Madsonic"
    echo "                                        URL. Typically '/' or '/madsonic'. Default '/'"
    echo "  --init-memory=MB                      The memory initial size (Init Java heap size) in megabytes." 
    echo "                                        Default: 256"
    echo "  --max-memory=MB                       The memory limit (max Java heap size) in megabytes." 
    echo "                                        Default: 512"
    echo "  --pidfile=PIDFILE                     Write PID to this file."
    echo "                                        Default not created."
    echo "  --default-music-folder=DIR            Configure Madsonic to use this folder for music."
    echo "                                        This option only has effect the first time Madsonic is started." 
    echo "                                        Default '/var/media/artists'"
    echo "  --default-upload-folder=DIR           Configure Madsonic to use this folder for music."
    echo "                                        Default '/var/media/incoming'"
    echo "  --default-podcast-folder=DIR          Configure Madsonic to use this folder for Podcasts."
    echo "                                        Default '/var/media/podcast'"
    echo "  --default-playlist-import-folder=DIR  Configure Madsonic to use this folder for playlist import."
    echo "                                        Default '/var/media/playlists/import'"
    echo "  --default-playlist-export-folder=DIR  Configure Madsonic to use this folder for playlist export."
    echo "                                        Default '/var/media/playlists/export'"
    echo "  --default-playlist-backup-folder=DIR  Configure Madsonic to use this folder for playlist backup."
    echo "                                        Default '/var/media/playlists/backup'"
    echo "  --default-transcode-folder=DIR        Configure Madsonic to use this folder for transcoder."
    echo "  --default-keystore-folder=DIR         Configure Madsonic to use this keystore for HTTPS."
    echo "                                        Default is ${MADSONIC_HOME}/madsonic.keystore."
    echo "  --default-keystore-password=VALUE     Configure Madsonic to use this keystore password."
    echo "                                        Default is 'madsonic'"
    echo "  --timezone=Zone/City                  Configure Madsonic to use other timezone for time correction"
    echo "                                        Example 'Europe/Vienna', 'US/Central', 'America/New_York'"
    echo "  --db=JDBC_URL                         Use alternate database. MySQL and HSQL are currently supported."
    echo "  --update=VALUE                        Configure Madsonic to look in folder /update for updates. Default 'true'"
    echo "  --gzip=VALUE                          Configure Madsonic to use Gzip compression. Default 'true'"
    echo "  --use-ssl=VALUE                       Configure Madsonic to use TLS/SSL. Default 'true'."
    echo "  --quiet                               Don't print anything to standard out. Default false."
    exit 1 
}

# Parse arguments.
while [ $# -ge 1 ]; do
    case $1 in
        --help)
            usage
            ;;
        --home=?*)
            MADSONIC_HOME=${1#--home=}
            ;;
        --host=?*)
            MADSONIC_HOST=${1#--host=}
            ;;
        --port=?*)
            MADSONIC_PORT=${1#--port=}
            ;;
        --https-port=?*)
            MADSONIC_HTTPS_PORT=${1#--https-port=}
            ;;
        --context-path=?*)
            MADSONIC_CONTEXT_PATH=${1#--context-path=}
            ;;
        --init-memory=?*)
            MADSONIC_INIT_MEMORY=${1#--init-memory=}
            ;;
        --max-memory=?*)
            MADSONIC_MAX_MEMORY=${1#--max-memory=}
            ;;
        --pidfile=?*)
            MADSONIC_PIDFILE=${1#--pidfile=}
            ;;
        --default-music-folder=?*)
            MADSONIC_DEFAULT_MUSIC_FOLDER=${1#--default-music-folder=}
            ;;
        --default-upload-folder=?*)
            MADSONIC_DEFAULT_UPLOAD_FOLDER=${1#--default-upload-folder=}
            ;;
        --default-podcast-folder=?*)
            MADSONIC_DEFAULT_PODCAST_FOLDER=${1#--default-podcast-folder=}
            ;;
        --default-playlist-import-folder=?*)
            MADSONIC_DEFAULT_PLAYLIST_IMPORT_FOLDER=${1#--default-playlist-import-folder=}
            ;;
        --default-playlist-export-folder=?*)
            MADSONIC_DEFAULT_PLAYLIST_EXPORT_FOLDER=${1#--default-playlist-export-folder=}
            ;;
        --default-playlist-backup-folder=?*)
            MADSONIC_DEFAULT_PLAYLIST_BACKUP_FOLDER=${1#--default-playlist-backup-folder=}
            ;;
        --default-transcode-folder=?*)
            MADSONIC_DEFAULT_TRANSCODE_FOLDER=${1#--default-transcode-folder=}
            ;;
        --default-keystore-folder=?*)
           MADSONIC_DEFAULT_KEYSTORE=${1#--default-keystore-folder=}
           ;;
        --default-keystore-password=?*)
          MADSONIC_DEFAULT_KEYSTORE_PASSWORD=${1#--default-keystore-password=}
          ;;
        --timezone=?*)
           MADSONIC_DEFAULT_TIMEZONE=${1#--timezone=}
           ;;
        --update=?*)
           MADSONIC_UPDATE=${1#--update=}
           ;;           
        --gzip=?*)
           MADSONIC_GZIP=${1#--gzip=}
           ;;
        --db=?*)
            MADSONIC_DB=${1#--db=}
           ;;
        --use-ssl=?*)
          MADSONIC_USE_SSL=${1#--use-ssl=}
          ;;
        --quiet)
            quiet=1
            ;;
        *)
            usage
            ;;
    esac
    shift
done

# Use JAVA_HOME if set, otherwise assume java is in the path.
JAVA=java
if [ -e "${JAVA_HOME}" ]
    then
    JAVA=${JAVA_HOME}/bin/java
fi

# Create Madsonic home directory.
mkdir -p ${MADSONIC_HOME}
LOG=${MADSONIC_HOME}/madsonic_sh.log
rm -f ${LOG}

cd $(dirname $0)
if [ -L $0 ] && ([ -e /bin/readlink ] || [ -e /usr/bin/readlink ]); then
    cd $(dirname $(readlink $0))
fi

SSL_PARAMETERS=""
if [ $MADSONIC_USE_SSL = "true" ] && [ -e "${MADSONIC_DEFAULT_KEYSTORE}" ]; then
    $SSL_PARAMETERS = -Dmadsonic.ssl.keystore=${MADSONIC_DEFAULT_KEYSTORE} -Dmadsonic.ssl.password=${MADSONIC_DEFAULT_KEYSTORE_PASSWORD}
fi

${JAVA} ${SSL_PARAMETERS} -Xms${MADSONIC_INIT_MEMORY}m -Xmx${MADSONIC_MAX_MEMORY}m \
  -Dmadsonic.home=${MADSONIC_HOME} \
  -Dmadsonic.host=${MADSONIC_HOST} \
  -Dmadsonic.port=${MADSONIC_PORT} \
  -Dmadsonic.httpsPort=${MADSONIC_HTTPS_PORT} \
  -Dmadsonic.contextPath=${MADSONIC_CONTEXT_PATH} \
  -Dmadsonic.defaultMusicFolder=${MADSONIC_DEFAULT_MUSIC_FOLDER} \
  -Dmadsonic.defaultUploadFolder=${MADSONIC_DEFAULT_UPLOAD_FOLDER} \
  -Dmadsonic.defaultPodcastFolder=${MADSONIC_DEFAULT_PODCAST_FOLDER} \
  -Dmadsonic.defaultPlaylistImportFolder=${MADSONIC_DEFAULT_PLAYLIST_IMPORT_FOLDER} \
  -Dmadsonic.defaultPlaylistExportFolder=${MADSONIC_DEFAULT_PLAYLIST_EXPORT_FOLDER} \
  -Dmadsonic.defaultPlaylistBackupFolder=${MADSONIC_DEFAULT_PLAYLIST_BACKUP_FOLDER} \
  -Dmadsonic.defaultTranscodeFolder=${MADSONIC_DEFAULT_TRANSCODE_FOLDER} \
  -Duser.timezone=${MADSONIC_DEFAULT_TIMEZONE} \
  -Dmadsonic.update=${MADSONIC_UPDATE} \
  -Dmadsonic.gzip=${MADSONIC_GZIP} \
  -Dmadsonic.proxy=${MADSONIC_PROXY} \
  -Dmadsonic.proxyType=${MADSONIC_PROXY_TYPE} \
  -Dmadsonic.proxyHost=${MADSONIC_PROXY_HOST} \
  -Dmadsonic.proxyPort=${MADSONIC_PROXY_PORT} \
  -Dmadsonic.db="${MADSONIC_DB}" \
  -Djava.awt.headless=true \
  -jar madsonic-booter.jar > ${LOG} 2>&1 &

# Write pid to pidfile if it is defined.
if [ $MADSONIC_PIDFILE ]; then
    echo $! > ${MADSONIC_PIDFILE}
fi

if [ $quiet = 0 ]; then
    echo Started Madsonic [PID $!, ${LOG}]
fi

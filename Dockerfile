###########################################################
# Dockerfile that builds a Mordhau Gameserver
###########################################################
FROM cm2network/steamcmd
LABEL maintainer="walentinlamonos@gmail.com"

# Run Steamcmd and install Mordhau
RUN set -x \
  && ./home/steam/steamcmd/steamcmd.sh \
		+login anonymous \
		+force_install_dir /home/steam/mordhau-dedicated \
		+app_update 629800 validate \
		+quit \
	&& { \
		echo '@ShutdownOnFailedCommand 1'; \
		echo '@NoPromptForPassword 1'; \
		echo 'login anonymous'; \
		echo 'force_install_dir /home/steam/mordhau-dedicated/'; \
		echo 'app_update 629800'; \
		echo 'quit'; \
  } > /home/steam/mordhau-dedicated/csgo_update.txt \
  && cd /home/steam/mordhau-dedicated/csgo \
  && wget -qO- https://raw.githubusercontent.com/CM2Walki/CSGO/master/etc/cfg.tar.gz | tar xf -

ENV SRCDS_FPSMAX=300 SRCDS_TICKRATE=128 SRCDS_PORT=27015 SRCDS_TV_PORT=27020 SRCDS_MAXPLAYERS=14 SRCDS_TOKEN=0 SRCDS_RCONPW="changeme" SRCDS_PW="changeme"

VOLUME /home/steam/csgo-dedicated

# Set Entrypoint; Technically 2 steps: 1. Update server, 2. Start server
ENTRYPOINT ./home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/csgo-dedicated +app_update 629800 +quit && \
		./home/steam/csgo-dedicated/srcds_run -game csgo -console -autoupdate -steam_dir /home/steam/steamcmd/ -steamcmd_script /home/steam/csgo-dedicated/csgo_update.txt -usercon +fps_max $SRCDS_FPSMAX -tickrate $SRCDS_TICKRATE -port $SRCDS_PORT -tv_port $SRCDS_TV_PORT -maxplayers_override $SRCDS_MAXPLAYERS +game_type 0 +game_mode 1 +mapgroup mg_active +map de_dust2 +sv_setsteamaccount $SRCDS_TOKEN +rcon_password $SRCDS_RCONPW +sv_password $SRCDS_PW +sv_region $SRCDS_REGION

# Expose ports
EXPOSE 27015 7777 7778

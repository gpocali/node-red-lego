FROM nodered/node-red:latest

USER root

RUN apk add --no-cache lego ca-certificates dcron sudo tzdata

COPY ./client.sh /bin/client.sh
RUN chmod 775 /bin/client.sh
RUN chown node-red:root /bin/client.sh

COPY ./lego /etc/cron.d/lego
RUN chmod 600 /etc/cron.d/lego

## Copied from parent Dockerfile for launch

# Env variables
ENV NODE_RED_VERSION=$NODE_RED_VERSION \
    NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules \
    FLOWS=/data/flows.json

# ENV NODE_RED_ENABLE_SAFE_MODE=true    # Uncomment to enable safe start mode (flows not running)
# ENV NODE_RED_ENABLE_PROJECTS=true     # Uncomment to enable projects option

# Expose the listening port of node-red
EXPOSE 1880

# Add a healthcheck (default every 30 secs)
HEALTHCHECK CMD node /healthcheck.js

ENTRYPOINT ["/bin/client.sh", "firstStart"]

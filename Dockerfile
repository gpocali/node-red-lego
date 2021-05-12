FROM nodered/node-red:latest

CMD apk add lego ca-certificates

COPY ./client.sh /bin/client.sh
CMD chmod 775 /bin/client.sh
CMD chown node-red:root /bin/client.sh

COPY ./lego /etc/crontabs/lego
CMD chmod 600 /etc/crontabs/lego

# EXPOSE PORT FOR LEGO CHALLENGE
EXPOSE 1881

## Copied from parent Dockerfile for launch
USER node-red

# Env variables
#ENV NODE_RED_VERSION=$NODE_RED_VERSION \
#    NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules \
#    FLOWS=flows.json

# ENV NODE_RED_ENABLE_SAFE_MODE=true    # Uncomment to enable safe start mode (flows not running)
# ENV NODE_RED_ENABLE_PROJECTS=true     # Uncomment to enable projects option

# Expose the listening port of node-red
EXPOSE 1880

# Add a healthcheck (default every 30 secs)
#HEALTHCHECK CMD node /healthcheck.js

ENTRYPOINT ["/bin/client.sh", "&&", "npm", "--no-update-notifier", "--no-fund", "start", "--cache", "/data/.npm", "--", "--userDir", "/data"]

# ------------------------------------------------------
# Heavily based on https://github.com/mind-doc/hubot
# ------------------------------------------------------

FROM node:alpine
LABEL maintainer="rafael@skyle.net"

# Install hubot 3.x dependencies
RUN apk update && apk upgrade \
  && apk add redis jq \
  && npm install -g yo generator-hubot@next \
  && rm -rf /var/cache/apk/*

# Create hubot user with privileges
RUN addgroup -g 501 hubot \
  && adduser -D -h /bot -u 501 -G hubot hubot
ENV HOME /bot
WORKDIR /bot
RUN chown -R hubot:hubot .
USER hubot

# Install hubot
ENV HUBOT_NAME bot
ENV HUBOT_ADAPTER gitter2
ARG HUBOT_OWNER="Bot <bot@localhost>"
ARG HUBOT_DESCRIPTION="Beep beep boop!"
RUN yo hubot --adapter=gitter2 --owner="$HUBOT_OWNER" --name="$HUBOT_NAME" --description="$HUBOT_DESCRIPTION" --defaults
# Set up extra external scripts (what we consider "essentials")
COPY external-scripts.json ./
RUN npm install --save $(jq -c -r '.[]' external-scripts.json | tr '\n' ' ')

EXPOSE 80

# Set up mandatory environment variables defaults
ENTRYPOINT ["/bin/sh", "-c", "bin/hubot --name $HUBOT_NAME --adapter $HUBOT_ADAPTER"]

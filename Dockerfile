#===========
#Build Stage
#===========
FROM bitwalker/alpine-elixir-phoenix:latest as build

#Copy the source folder into the Docker image
COPY . .

ENV SECRET_KEY_BASE=1234

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    export SECRET_KEY_BASE=1234 && \
    rm -Rf _build && \
    mix do deps.get, \
    deps.compile && \
    mix release

RUN mkdir /export

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="todo" && \
    RELEASE_DIR=`ls -d _build/prod/rel/todo/releases/*/` && \
    tar -xf "$RELEASE_DIR/./$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
# FROM pentacent/alpine-erlang-base:latest

#Set environment variables and expose port
EXPOSE 4000
ENV REPLACE_OS_VARS=true \
    PORT=4000

#Change user
# USER default

#Copy and extract .tar.gz Release file from the previous stage
# COPY --from=build /export/ .
# COPY /export/ .

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex \
    HOME=/opt/app

RUN mix local.hex --force && \
    mix local.rebar --force

RUN ls /opt
RUN ls /opt/app

#Set default entrypoint and command
CMD mix do ecto.create, ecto.migrate, phx.server

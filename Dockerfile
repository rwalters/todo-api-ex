FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod SECRET_KEY_BASE=1234 PGPORT=5432

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD . .

# Run frontend build, compile, and digest assets
RUN cd - && \
    mix do compile, phx.digest

USER default

CMD ["mix", "phx.server"]

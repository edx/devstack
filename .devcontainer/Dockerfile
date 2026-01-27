FROM mcr.microsoft.com/devcontainers/universal:latest

# Fix: remove legacy Yarn apt repo that can break apt-get update with EXPKEYSIG

RUN rm -f /etc/apt/sources.list.d/yarn.list \
        /etc/apt/sources.list.d/yarn*.list \
&& apt-get update

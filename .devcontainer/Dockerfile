FROM mcr.microsoft.com/devcontainers/cpp:debian-12

WORKDIR /app
RUN sudo apt install ninja-build -y
# RUN ["sudo", "wget", "-P", "/app", "https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip"]
# RUN ["sudo", "wget", "-P", "/app", "https://github.com/clangd/clangd/releases/download/17.0.3/clangd-linux-17.0.3.zip"]
RUN sudo wget -P /app https://github.com/clangd/clangd/releases/download/17.0.3/clangd-linux-17.0.3.zip \
  && sudo unzip /app/clangd-linux-17.0.3.zip -d /app

RUN sudo wget -P /app https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip \
  && sudo unzip /app/ninja-linux.zip  -d /app \
  && sudo cp /app/ninja /usr/bin

RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && sudo dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb


RUN sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-6.0

RUN sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-6.0



ENV PATH=$PATH:/app
ENV PATH="$PATH:/app/clangd_17.0.3/bin"
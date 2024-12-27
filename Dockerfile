FROM dart:stable AS build

# Install yt-dlp and ffmpeg
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ffmpeg \
    && pip3 install yt-dlp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Resolve app dependencies
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and create Tools directory
COPY . .
RUN mkdir -p bin/Tools \
    && which yt-dlp > bin/Tools/yt-dlp.exe \
    && which ffmpeg > bin/Tools/ffmpeg.exe \
    && chmod +x bin/Tools/yt-dlp.exe \
    && chmod +x bin/Tools/ffmpeg.exe

# AOT compile app
RUN dart compile exe bin/main.dart -o bin/server

# Build minimal serving image
FROM debian:stable-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ffmpeg \
    && pip3 install yt-dlp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled server and tools
WORKDIR /app
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/bin/Tools /app/bin/Tools

# Start server
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
FROM nginx:1.27-alpine

LABEL org.opencontainers.image.source="https://github.com/radityobw/langkah-kecil" \
      org.opencontainers.image.title="Langkah Kecil" \
      org.opencontainers.image.description="Game Edukatif Inklusif untuk Anak Berkebutuhan Khusus (Godot 4.5 Web Edition)" \
      org.opencontainers.image.licenses="CC-BY-NC-4.0"

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web/ /usr/share/nginx/html/

EXPOSE 80

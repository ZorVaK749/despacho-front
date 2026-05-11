# ETAPA 1: Construcción (Build)
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ETAPA 2: Producción (Servidor Nginx)
FROM nginx:1.25-alpine

# Creamos el usuario seguro
RUN addgroup -g 1001 appuser && adduser -u 1001 -G appuser -s /bin/sh -D appuser

# Copiamos la web
COPY --from=build /app/dist /usr/share/nginx/html

# Copiamos la nueva configuración (pisando la general)
COPY nginx.conf /etc/nginx/nginx.conf

# Damos permisos esenciales
RUN chown -R appuser:appuser /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

# Exponemos el nuevo puerto permitido
EXPOSE 80

USER appuser
CMD ["nginx", "-g", "daemon off;"]
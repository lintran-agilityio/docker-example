FROM base:latest
WORKDIR /usr/src
EXPOSE 3000

FROM node:18 AS dev
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev
USER node
# COPY package*.json ./
COPY . .
CMD npm run dev

FROM base as prod
# run ts-node-dev to reload
# RUN npm install -g ts-node-dev typescript
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

USER node
COPY . .
EXPOSE 3002
CMD node src/index.js

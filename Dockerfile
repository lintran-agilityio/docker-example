# Stage 1: build
FROM node:18 AS build
WORKDIR /usr/src
COPY package*.json ./
RUN npm ci --include=dev
EXPOSE 3000
COPY . .
RUN npm run build 

# FROM node:18 AS dev
# RUN --mount=type=bind,source=package.json,target=package.json \
#     --mount=type=bind,source=package-lock.json,target=package-lock.json \
#     --mount=type=cache,target=/root/.npm \
#     npm ci --include=dev
# USER node
# # COPY package*.json ./
# COPY . .
# CMD npm run dev

# Stage 2: test
FROM build AS test
# RUN npm test
CMD ["npm", "test"]

# Stage 2: prod
FROM node:20-alpine AS prod
WORKDIR /usr/src
COPY --from=build /usr/src/dist ./dist
COPY package*.json ./
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

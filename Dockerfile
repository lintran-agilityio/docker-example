# # Stage 1: build
# FROM node:20-alpine AS build
# WORKDIR /usr/src
# COPY package*.json ./
# RUN npm ci --include=dev
# EXPOSE 3000
# COPY . .
# RUN npm run build 

# # FROM node:18 AS dev
# # RUN --mount=type=bind,source=package.json,target=package.json \
# #     --mount=type=bind,source=package-lock.json,target=package-lock.json \
# #     --mount=type=cache,target=/root/.npm \
# #     npm ci --include=dev
# # USER node
# # # COPY package*.json ./
# # COPY . .
# # CMD npm run dev

# # Stage 2: test
# FROM build AS test
# # RUN npm test
# CMD ["npm", "test"]

# # Stage 2: prod
# FROM node:20-alpine AS prod
# WORKDIR /usr/src
# COPY --from=build /usr/src/dist ./dist
# COPY package*.json ./
# # run ts-node-dev to reload
# # RUN npm install -g ts-node-dev typescript
# RUN --mount=type=bind,source=package.json,target=package.json \
#     --mount=type=bind,source=package-lock.json,target=package-lock.json \
#     --mount=type=cache,target=/root/.npm \
#     npm ci --omit=dev

# USER node
# COPY . .
# EXPOSE 3002
# CMD node src/index.js


# Stage 1: Build
FROM node:18 AS build
WORKDIR /app

# Copy package.json và package-lock.json
COPY package*.json ./

# Cài tất cả dependencies (bao gồm devDependencies để có typescript, tsc)
RUN npm install

# Copy toàn bộ source code
COPY . .

# Build project (sẽ chạy "tsc" từ script build)
RUN npm run build

# Stage 2: Test
FROM build AS test
CMD [ "npm", "test" ]

# Stage 3: Runtime
FROM node:18
WORKDIR /app

# Copy package.json và package-lock.json để install lại dependencies production
COPY package*.json ./

# Chỉ cài dependencies production
RUN npm install --only=production

# Copy file build từ stage 1
COPY --from=build /app/dist ./dist

# Run app
CMD ["node", "src/index.js"]
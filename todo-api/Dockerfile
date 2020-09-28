# Build API
# This Dockerfile is very inefficient.  Convert this to a multi-stage docker build with a node12 container used as runtime.
# If done correctly the final image should be < 300 MB.
FROM node:12 as build
WORKDIR /app
COPY ./package.json ./
RUN npm install
COPY . .
RUN npm run build

# remove development dependencies
RUN npm prune --production

# Considered leaving out node-prune but wanted the image to be under 100mb 

# install node-prune (https://github.com/tj/node-prune)
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin

# run node prune
RUN /usr/local/bin/node-prune

#FROM build
FROM node:12-alpine
WORKDIR /app
COPY --from=build /app /app
CMD ["npm", "run", "start:prod"]
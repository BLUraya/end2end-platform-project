FROM node:20-alpine

ENV NODE_ENV=production

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --omit=dev

COPY server.js .

RUN chown -R node:node /usr/src/app
USER node

EXPOSE 3000

CMD ["node", "server.js"]
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY src ./src

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

CMD ["node", "src/index.js"]
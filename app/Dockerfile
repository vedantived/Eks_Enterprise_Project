FROM node:18-alpine

WORKDIR /app

# Install AWS CLI     ## Containers must include required tools  ## Containers must include required tools
RUN apk add --no-cache aws-cli
COPY package*.json ./

RUN npm install --production

COPY src ./src

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

CMD ["node", "src/index.js"]
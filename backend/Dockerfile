FROM node:latest

ARG BUILD_NUM
ENV BUILD_NUM=${BUILD_NUM}

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 3000

CMD [ "npm", "run", "dev" ]

FROM node:18

# create app directory
WORKDIR /usr/src/app

# copy package.json
COPY package*.json ./

# install dependencies
RUN npm install

# copy source code
COPY . .

# expose port 8000
EXPOSE 8000

# start command
CMD ["npm", "start"]

FROM bucharestgold/centos7-s2i-nodejs

ONBUILD COPY package.json /opt/app-root/src
ONBUILD COPY . /opt/app-root/src

# Install the app
ONBUILD RUN npm -s install

# Run it
CMD ["/bin/bash", "-c", "npm run -d $NPM_RUN" ]

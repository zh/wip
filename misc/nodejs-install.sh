sudo apt-get update
sudo apt-get install git-core build-essential libssl-dev
cd /var/tmp
git clone http://github.com/ry/node.git
cd node
./configure
make
sudo make install
curl http://npmjs.org/install.sh |sudo sh
cd /var/tmp
git clone git://github.com/Marak/hellonode.git
cd hellonode
nohup node server.js

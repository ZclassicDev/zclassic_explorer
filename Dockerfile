# * I ran this with 3GB Swap, 100GB files *
# https://digitizor.com/create-swap-file-ubuntu-linux/
# TODO check if this change is needed - https://github.com/zcash/zcash/pull/2545/commits/4272a1e2b1e19d66a196eea8cb9b1a2a50fba439

# TODO Docker/AMI base - BASE=EC2 AMI

# Git Repos
sudo yum install -y git

mkdir Z
cd Z

git clone https://github.com/ch4ot1c/insight-ui-zclassic
git clone https://github.com/ch4ot1c/insight-api-zclassic


# EC2 Node / NVM

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 6.11.5
node -e "console.log('Running Node.js ' + process.version)"

### Install Build Tools ###

npm install -g node-gyp bower grunt

# compilers
sudo yum install -y gcc gcc-c++ patch

# libsodium: download, compile, install, remove intermediate files
V_SODIUM=1.0.16
curl https://download.libsodium.org/libsodium/releases/libsodium-${V_SODIUM}.tar.gz | tar -xz
cd libsodium-${V_SODIUM}
./configure && make && sudo make install
cd ../ && rm -rf libsodium-${V_SODIUM}

# zmq
V_ZMQ=4.1.6
wget https://github.com/zeromq/libzmq/releases/download/v${V_ZMQ}/zeromq-${V_ZMQ}.tar.gz
tar xfz zeromq-${V_ZMQ}.tar.gz && rm zeromq-${V_ZMQ}.tar.gz
cd zeromq-${V_ZMQ}
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
./configure
make
sudo make check && make install && sudo ldconfig
cd ../ && rm -rf zeromq-${V_ZMQ}

# make sure zmq lib can be found
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# remove compilers
sudo yum remove -y gcc-c++ gcc

### END Install Build Tools ###

### Zclassic daemon setup ###

git clone https://github.com/johandjoz/zclassic-addressindexing.git
cd zclassic-addressindexing
git checkout v1.0.4-bitcore-zclassic

./zcutil/fetch-params.sh
# Be sure you have 3GB Swap and plenty (>10GB) of HDD space before continuing!
./zcutil/build.sh -j$(nproc)


### Zclassic Explorer Setup ###

cd ../zclassic-explorer

# install bitcore
npm install str4d/bitcore-node-zcash

# create bitcore node
./node_modules/bitcore-node-zcash/bin/bitcore-node create zclassic-explorer
cd zclassic-explorer

# install patched insight api/ui (branched and patched from https://github.com/str4d/zcash)
./node_modules/bitcore-node-zcash/bin/bitcore-node install johandjoz/insight-api-zclassic johandjoz/insight-ui-zclassic

# create bitcore config file for bitcore and zcashd/zclassicd
cat << EOF > bitcore-node.json
{
  "network": "mainnet",
  "port": 80,
  "services": [
    "bitcoind",
    "insight-api-zcash",
    "insight-ui-zcash",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "spawn": {
        "datadir": "./data",
        "exec": "$HOME/Z/zclassic-addressindexing/src/zcashd"
      }
    },
     "insight-ui-zclassic": {
      "apiPrefix": "api"
    },
    "insight-api-zclassic": {
      "routePrefix": "api"
    }
  }
}
EOF

# create zcash.conf
cat << EOF > data/zcash.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:8332
zmqpubhashblock=tcp://127.0.0.1:8332
rpcallowip=127.0.0.1
rpcuser=bitcoin
rpcpassword=local321
uacomment=bitcore
showmetrics=1
maxconnections=1000
addnode=149.56.129.104
addnode=51.254.132.145
addnode=139.99.100.70
addnode=50.112.137.36          # First # https://zcl-explorer.com/insight/status
addnode=188.166.136.203        # Second # https://eu1.zcl-explorer.com/insight/status  ## EU Server located in London
addnode=159.89.198.93          # Third # https://as1.zcl-explorer.com/insight/status  ## Asia Server located in Singapore
EOF

echo "Start the block explorer, open in your browser http://server_ip"
echo "If this does not work and gives an error due to port 80, you can change the port or run with escalated priviliges"

echo "To Run:"
echo "./node_modules/bitcore-node-zcash/bin/bitcore-node start"



# * Leftovers *
#echo "Run the following line as one line of commands to start the block explorer"
#echo "nvm use v4; cd zclassic-explorer; ./node_modules/bitcore-node-zcash/bin/bitcore-node start"


#npm install -g bitcore-node@latest
#bower install
#grunt compile


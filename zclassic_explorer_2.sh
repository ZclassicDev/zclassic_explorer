#!/bin/bash


WHO=$(whoami)

# install npm v4
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm install v4

# install ZeroMQ libraries
sudo apt-get -y install libzmq3-dev

# install bitcore (branched and patched from https://github.com/z-classic/bitcore-node-zclassic.git)
npm install z-classic/bitcore-node-zclassic

# create bitcore node
./node_modules/bitcore-node-zlassic/bin/bitcore-node create zclassic-explorer
cd zclassic-explorer

# install patched insight api/ui (branched and patched from https://github.com/z-classic/insight-api-zclassic & https://github.com/z-classic/insight-ui-zclassic)
../node_modules/bitcore-node-zclassic/bin/bitcore-node install z-classic/insight-api-zclassic z-classic/insight-ui-zclassic

# create bitcore config file for bitcore and zcashd/zclassicd
cat << EOF > bitcore-node.json
{
  "network": "mainnet",
  "port": 3001,
  "services": [
    "bitcoind",
    "insight-api-zcash",
    "insight-ui-zcash",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "spawn": {
        "datadir": "~/.zclassic",
        "exec": "~/zclassic/src/zcashd"
      }
    },
     "insight-ui-zclassic": {
      "apiPrefix": "api",
      "routePrefix": ""

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

echo "Start the block explorer, open in your browser http://server_ip:3001"
echo "Run the following line as one line of commands to start the block explorer"
echo "nvm use v4; cd zclassic-explorer; ./node_modules/bitcore-node-zlassic/bin/bitcore-node start"

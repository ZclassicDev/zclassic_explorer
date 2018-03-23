# zclassic_explorer

Getting Started - Tested on Ubuntu and Debian (server) - zcl-explorer.com

Setup using zclassic daemon v1.0.10-1-03eafd6 or newer.
Will not work on older zcashd/zclassic daemon versions due to
different port numbers.

```
git clone https://github.com/ZclassicDev/zclassic_explorer.git
cd zclassic_explorer
```

```
./zclassic_explorer_1.sh
```


Logout (you need to relogin to get bash variables for NVM).
```
./zclassic_explorer_2.sh
```

Check if you are using the new Zclassic RPC port (8023) in:
`/zclassic-explorer/node_modules/bitcore-node-zcash/lib/services/bitcoind.js` line 491.

Open http://server_ip:3001 in browser.

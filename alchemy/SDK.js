import { Network, Alchemy } from 'alchemy-sdk';

// Optional Config object, but defaults to demo api-key and eth-mainnet.
const settings = {
  apiKey: 'demo', // Replace with your Alchemy API Key.
  network: Network.ETH_MAINNET, // Replace with your network.
};

const alchemy = new Alchemy(settings);

// get the latest block
// const latestBlock = alchemy.core.getBlockNumber();
alchemy.core.getBlockNumber().then(console.log);

// get all the NFTs owned by an address
const nfts = alchemy.nft.getNftsForOwner('tiffanyyang.eth');

console.log(nfts);

alchemy.ws.on(
  {
    method: 'alchemy_pendingTransactions'
  },
  res => console.log(res)
);
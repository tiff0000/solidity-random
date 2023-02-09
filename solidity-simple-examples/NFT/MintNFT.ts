import React, { useState, useEffect } from "react";
import { useEthers } from "./ethers-provider";
import abi from "./NFT.json";
import { ethers } from "ethers";

const NFTMint = () => {
  const [contract, setContract] = useState<ethers.Contract>();
  const [tokenId, setTokenId] = useState("");
  const [mintResult, setMintResult] = useState("");
  const provider = useEthers();

  useEffect(() => {
    if (provider) {
      const contractInstance = new ethers.Contract("CONTRACT_ADDRESS", abi, provider);
      setContract(contractInstance);
    }
  }, [provider]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!contract) return;

    try {
      const result = await contract.mint(tokenId);
      setMintResult(`Token minted with transaction hash: ${result.hash}`);
    } catch (error) {
      setMintResult(`Error: ${error.message}`);
    }
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input type="text" value={tokenId} onChange={e => setTokenId(e.target.value)} />
        <button type="submit">Mint</button>
      </form>
      <p>{mintResult}</p>
    </div>
  );
};

export default NFTMint;

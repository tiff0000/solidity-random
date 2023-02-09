pragma solidity ^0.9.0;

contract NFT {
    // The token name
    string public name = "My NFT";

    // The token symbol
    string public symbol = "MNF";

    // The token ID
    uint256 public tokenId;

    // An array to store the token owners
    mapping(uint256 => address) public owners;

    // Event to notify when a token is minted
    event Mint(uint256 indexed tokenId, address owner);

    // The constructor sets the initial owner of the contract
    constructor() public {
        owners[tokenId] = msg.sender;
    }

    // The function to mint a new token
    function mint(uint256 _tokenId) public {
        require(
            msg.sender == owners[0],
            "Only the contract owner can mint new tokens."
        );
        owners[_tokenId] = msg.sender;
        tokenId = _tokenId;
        emit Mint(_tokenId, msg.sender);
    }

    // The function to transfer a token
    function transfer(address _to, uint256 _tokenId) public {
        require(
            msg.sender == owners[_tokenId],
            "Only the token owner can transfer the token."
        );
        owners[_tokenId] = _to;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";

contract MyToken is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    uint256 public time;
    uint256 public time_at_excution;
    Counters.Counter private _tokenIdCounter;
    mapping (uint256 => uint256) locked_coin;
    mapping (uint256 => uint256) locked_time;
    mapping (uint256 => bool) lockable;

    constructor() ERC721("Stake Card", "CARD") {}

    function safeMint( string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // function unlock_coin(uint256 nft_id){
        
    // }

    function Stake_Mint (string memory uri, uint256 _time) public {
      uint256 tokenId = _tokenIdCounter.current();
      _tokenIdCounter.increment();
      _safeMint(msg.sender,tokenId);
      _setTokenURI(tokenId,uri);
      time  = _time;
    }
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}

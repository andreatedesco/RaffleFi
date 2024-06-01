// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721, ERC721URIStorage, Ownable {
    uint256 public currentSupply;
    string private _contractUri;

    constructor(string memory contractUri_, string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable(_msgSender()) {
        _contractUri = contractUri_;
    }

    /**
     * @dev See {ERC721-_safeMint}.
     * @dev See {ERC721-_setTokenURI}.
     */
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = currentSupply++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @dev See {ERC721-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Returns the contract-level URI.
     */
    function contractURI() external view returns (string memory) {
        return _contractUri;
    }

    /**
     * @dev See {ERC721-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
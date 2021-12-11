// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract KataNFT is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    string baseURI;
    string baseExt = ".json";

    uint256 public maxSupply = 10000;
    uint256 public price = 0.04 ether;
    uint256 public maxMintAmount = 20;
    uint256 public mintSupply;

    constructor() ERC721("Katana Inu NFT", "KataNFT") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(uint256 Amount) external payable whenNotPaused {
        require(Amount >= 0, "KataNFT: token amount is zero");
        require(balanceOf(msg.sender) + Amount <= maxMintAmount, "KataNFT: exceeds max mint limit");
        require(price * Amount == msg.value, "KataNFT: invalid eth amount");
        require(mintSupply + Amount < maxSupply, "KataNFT: excceds max mint supply");

        mintSupply = mintSupply + Amount;


        for (uint256 i = 0; i < Amount; i++) {
            safeMint(msg.sender);
        }
    }

    function mint(address to) external onlyOwner {
        safeMint(to);
    }

    function safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();
        require (tokenId < maxSupply, "KataNFT: exceeds max supply");

        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
        
    function tokenURI(uint256 tokenId) public view override returns(string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExt))
            : "";
    }

    function withdraw() external onlyOwner {
        uint256 _balance = address(this).balance;
        payable(msg.sender).transfer(_balance);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setMaxsupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setMaxMintAmount(uint256 _maxMintAmount) external onlyOwner {
        maxMintAmount = _maxMintAmount;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setBaseExt(string memory _baseExt) external onlyOwner {
        baseExt = _baseExt;
    }
}
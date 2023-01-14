//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7; 

import "./node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./node_modules/@openzeppe lin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "./FNFToken.sol";
import "./node_modules/hardhat/console.sol";

contract FractionalNFTZ is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable,IERC721Receiver {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct _fnft{
        uint256 tokenId;
        address fractionalToken;
    }

    mapping(uint256 => _fnft) public FNFT;

    constructor() ERC721("FractionalNFT", "FNFT") payable{}

    function safeMint(address to) public onlyOwner {
        _safeMint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //is the caller of this function the owner of the NFT?
    modifier isNFTOwner(uint256 _tokenURI) {
        require(msg.sender == ownerOf(_tokenURI));
        _;
    }
function transferFNFToken(
        address _to, 
        uint256 _tokenURI, 
        uint256 _amount) 
        onlyOwner()
        public
      //  private
        //isNFTOwner(_tokenURI)
    {
        FNFToken _fnftoken = FNFToken(FNFT[_tokenURI].fractionalToken);
        _fnftoken.transfer(_to, _amount);

    }

    function mint(
        address _to,
        string memory tokenURI_, 
        uint256 _totalFractionalTokens
    ) external  {
        _safeMint(_to, _tokenIdCounter.current());
        _setTokenURI(_tokenIdCounter.current(), tokenURI_);

        //Create a ERC20 Token Contract for this newly minted NFT
        FNFToken _fnftoken = new FNFToken();                                      //initialize
        _fnftoken.mint(_to, _totalFractionalTokens * 1000000000000000000);   //now mint the fractional tokens and send it to the owner of this NFT           
        console.log("To", _to);
        _fnft memory fnft;                                                          //constructor
        fnft.tokenId = _tokenIdCounter.current();                           
        fnft.fractionalToken = address(_fnftoken);
        FNFT[_tokenIdCounter.current()]  = fnft;                                    //bind the fractional token address to this NFT token just minted
        _tokenIdCounter.increment();
    }

        function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }


}
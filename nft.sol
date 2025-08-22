// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol";

contract OnChainNFT is ERC721 {
    using Strings for uint256;

    uint256 private _nextTokenId;

    string[] private colors = [
        "#3c8aff",
        "#ffffff",
        "#eef0f3",
        "#b8a581",
        "#ffd12f",
        "#dee1e7",
        "#b1b7c3",
        "#66c800",
        "#b6f569",
        "#717886",
        "#5b616e",
        "#fc401f",
        "#fea8cd",
        "#32353d",
        "#0a0b0d"];

    uint256 public constant MAX_SUPPLY = 333;
    mapping(address => uint256) private _mintsPerWallet;

    string public backgroundColor = "#0000ff";

    constructor() ERC721("OnChainNFT", "ONFT") {
        _transferOwnership(msg.sender);
    }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }

    function mint() public {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        require(_mintsPerWallet[msg.sender] < 3, "Max mints per wallet reached");

        _mintsPerWallet[msg.sender]++;
        _safeMint(msg.sender, _nextTokenId);
        _nextTokenId++;
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function generateSVG(uint256 tokenId) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(block.timestamp, msg.sender, tokenId)));
        string memory color = colors[rand % colors.length];
        uint256 svgIndex = rand % 3;

        return getSVG(svgIndex, color);
    }

    function getSVG(uint256 svgIndex, string memory color) internal pure returns (string memory) {
        if (svgIndex == 0) {
            // Rectangle
            return string(abi.encodePacked(
                '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">',
                '<rect width="100%" height="100%" fill="',
                color,
                '" />',
                '</svg>'
            ));
        } else if (svgIndex == 1) {
            // Circle
            return string(abi.encodePacked(
                '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">',
                '<circle cx="100" cy="100" r="100" fill="',
                color,
                '" />',
                '</svg>'
            ));
        } else {
            // Star
            return string(abi.encodePacked(
                '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">',
                '<polygon points="100,10 40,198 190,78 10,78 160,198" style="fill:',
                color,
                ';" />',
                '</svg>'
            ));
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory name = string(abi.encodePacked("OnChain NFT #", tokenId.toString()));
        string memory description = "An example of an on-chain SVG NFT.";
        string memory image = Base64.encode(bytes(generateSVG(tokenId)));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name,
                        '", "description": "',
                        description,
                        '", "image": "data:image/svg+xml;base64,',
                        image,
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}

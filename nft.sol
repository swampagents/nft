// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 *
 *
    Base Ticker Club
    https://BaseTickerClub.com

    NFT Contract Features:
    Fully onchain NFT collection with limited custom tickers, stored on Base.
    Mint function allows custom tickers of 2-6 characters limited to 11 mints per ticker.
    Max of 3,333 NFTs generated onchain in collection.
 */


// --- OpenZeppelin Contracts ---

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: modified @openzeppelin/contracts/access/Ownable.sol
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/Base64.sol
library Base64 {
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(encodedLen);
        bytes memory table = bytes(_TABLE);
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            for {} lt(dataPtr, endPtr) {} {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }
            switch mod(mload(data), 3)
            case 1 { mstore8(sub(resultPtr, 2), 0x3d) mstore8(sub(resultPtr, 1), 0x3d) }
            case 2 { mstore8(sub(resultPtr, 1), 0x3d) }
        }
        return string(result);
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/Address.sol
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {}
}

// File: @openzeppelin/contracts/interfaces/IERC2981.sol
interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);
}

// File: @openzeppelin/contracts/token/common/ERC2981.sol
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }
    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];
        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }
        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / _feeDenominator();
        return (royalty.receiver, royaltyAmount);
    }
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");
        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");
        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }
}

// --- Main Contract ---

contract BaseTickersNFT is ERC721, ERC2981, Ownable {
    using Strings for uint256;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    uint256 private _nextTokenId;

    uint256 public constant MAX_SUPPLY = 3333;
    uint256 public constant MINT_PRICE = 0.0021 ether;

    string[] private colors = [
        "#FFD12F", "#0A0B0D", "#66C800", "#B1B7C3", "#B8A581", "#FC401F", "#FEA8CD", "#EEF0F3", "#B6F569", "#FFFFFF", "#3C8AFF"
    ];

    string[] private colorNames = [
        "Yellow", "Black", "Green", "Gray 30", "Tan", "Red", "Pink", "Gray 10", "Lime", "White", "Cerulean"
    ];

    struct NFTData {
        string ticker;
        string hexcode;
        string color;
    }

    mapping(uint256 => NFTData) public tokenData;
    mapping(string => uint256) public mintsPerTicker;
    mapping(string => string) private characterPaths;

    constructor() ERC721("Base Ticker Club", "TICKER") {
        _setDefaultRoyalty(_msgSender(), 500); // 5%
        _setupCharacterPaths();
    }

    function mint(string memory customText) public payable {
        uint256 textLength = bytes(customText).length;
        require(textLength >= 2 && textLength <= 6, "Ticker must be 2-6 characters");
        require(isAlpha(customText), "Ticker must only contain letters");
        
        // Convert to uppercase for consistency
        string memory upperCaseText = toUpperCase(customText);
        
        require(mintsPerTicker[upperCaseText] < 11, "All colors for this ticker have been minted");
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        require(msg.value == MINT_PRICE, "Incorrect mint price");

        string memory assignedHexcode = colors[mintsPerTicker[upperCaseText]];
        string memory assignedColorName = colorNames[mintsPerTicker[upperCaseText]];
        
        _safeMint(msg.sender, _nextTokenId);
        tokenData[_nextTokenId] = NFTData(upperCaseText, assignedHexcode, assignedColorName);
        
        mintsPerTicker[upperCaseText]++;
        _nextTokenId++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        NFTData memory data = tokenData[tokenId];
        string memory image = Base64.encode(bytes(generateSVG(data)));
        
        // Extract first letter of ticker
        string memory firstLetter = string(abi.encodePacked(bytes(data.ticker)[0]));
        
        string memory attributes = string(abi.encodePacked(
            '{"trait_type":"Ticker","value":"', data.ticker, '"},',
            '{"trait_type":"Color","value":"', data.color, '"},',
            '{"trait_type":"Hexcode","value":"', data.hexcode, '"},',
            '{"trait_type":"First Letter","value":"', firstLetter, '"}'
        ));

        string memory json = string(abi.encodePacked(
            '{"name":"', data.ticker, ' #', (mintsPerTicker[data.ticker]).toString(), '",',
            '"description":"Fully onchain NFT collection with limited custom tickers, stored on Base.",',
            '"image":"data:image/svg+xml;base64,', image, '",',
            '"attributes":[', attributes, ']}'
        ));

        return string(abi.encodePacked(_baseURI(), Base64.encode(bytes(json))));
    }

    function getCharacterWidth(string memory char) internal pure returns (uint) {
        if (bytes(char)[0] == 'I') {
            return 32;
        }
        return 50;
    }

    function generateSVG(NFTData memory data) internal view returns (string memory) {
        string memory fullText = string(abi.encodePacked('$', data.ticker));
        string memory svg = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">';
        svg = string(abi.encodePacked(svg, '<rect width="100%" height="100%" fill="#0000FF"/>'));
        
        // Add basemark logo
        svg = string(abi.encodePacked(svg, '<g transform="translate(200, 400) scale(0.08)">'));
        svg = string(abi.encodePacked(svg, '<path fill="#FFFFFF" d="M616.78,120.78c-3.1-1.52-7.12-1.52-15.18-1.52h-250.64c-8.06,0-12.08,0-15.18,1.52-2.97,1.46-5.36,3.86-6.82,6.83-1.52,3.1-1.52,7.14-1.52,15.21v251.05c0,8.07,0,12.1,1.52,15.21,1.45,2.97,3.85,5.37,6.82,6.83,3.1,1.52,7.13,1.52,15.18,1.52h250.64c8.06,0,12.08,0,15.18-1.52,2.97-1.46,5.37-3.86,6.82-6.83,1.52-3.1,1.52-7.14,1.52-15.21v-251.05c0-8.07,0-12.1-1.52-15.21-1.45-2.97-3.85-5.37-6.82-6.83Z M944.22,120.78c-3.1-1.52-7.13-1.52-15.18-1.52h-250.64c-8.06,0-12.08,0-15.18,1.52-2.97,1.46-5.36,3.86-6.82,6.83-1.52,3.1-1.52,7.14-1.52,15.21v251.05c0,8.07,0,12.1,1.52,15.21,1.46,2.97,3.85,5.37,6.82,6.83,3.1,1.52,7.12,1.52,15.18,1.52h250.64c8.06,0,12.08,0,15.18-1.52,2.96-1.46,5.36-3.86,6.82-6.83,1.52-3.1,1.52-7.14,1.52-15.21v-251.05c0-8.07,0-12.1-1.52-15.21-1.45-2.97-3.85-5.37-6.82-6.83Z M1278.48,127.61c-1.46-2.97-3.85-5.37-6.82-6.83-3.1-1.52-7.12-1.52-15.18-1.52h-250.64c-8.06,0-12.08,0-15.18,1.52-2.97,1.46-5.36,3.86-6.82,6.83-1.52,3.1-1.52,7.14-1.52,15.21v251.05c0,8.07,0,12.1,1.52,15.21,1.45,2.97,3.85,5.37,6.82,6.83,3.1,1.52,7.13,1.52,15.18,1.52h250.64c8.06,0,12.08,0,15.18-1.52,2.97-1.46,5.36-3.86,6.82-6.83,1.52-3.1,1.52-7.14,1.52-15.21v-251.05c0-8.07,0-12.1-1.52-15.21Z M289.34,120.78c-3.1-1.52-7.13-1.52-15.18-1.52h-131.57c-8.05,0-12.08,0-15.18-1.52-2.97-1.46-5.36,3.86-6.82-6.83-1.52-3.1-1.52-7.14-1.52-15.21V23.55c0-8.07,0-12.1-1.52-15.21-1.45-2.97-3.85-5.37-6.82-6.83-3.1-1.52-7.13-1.52-15.18-1.52H23.52c-8.06,0-12.08,0-15.18,1.52-2.97,1.46-5.36,3.86-6.82,6.83-1.52,3.1-1.52,7.14-1.52,15.21v370.32c0,8.07,0,12.1,1.52,15.21,1.45,2.97,3.85,5.37,6.82,6.83,3.1,1.52,7.13,1.52,15.18,1.52h250.64c8.05,0,12.08,0,15.18-1.52,2.97-1.46,5.37-3.86,6.82-6.83,1.52-3.1,1.52-7.14,1.52-15.21v-251.05c0-8.07,0-12.1-1.52-15.21-1.45-2.97-3.85-5.37-6.82-6.83Z"/>'));
        svg = string(abi.encodePacked(svg, '</g>'));

        // Add centered text
        string memory textGroup = '<g transform="translate(0, 20)">';
        uint totalWidth = 0;
        uint[] memory charWidths = new uint[](bytes(fullText).length);

        for (uint i = 0; i < bytes(fullText).length; i++) {
            string memory char = string(abi.encodePacked(bytes(fullText)[i]));
            uint charWidth = getCharacterWidth(char);
            charWidths[i] = charWidth;
            totalWidth += charWidth;
        }

        uint startX = (500 - totalWidth) / 2;
        uint currentX = startX;

        for (uint i = 0; i < bytes(fullText).length; i++) {
            string memory char = string(abi.encodePacked(bytes(fullText)[i]));
            string memory pathData = characterPaths[char];

            if (bytes(char)[0] == 'I') {
                currentX -= 9;
            }

            textGroup = string(abi.encodePacked(textGroup, '<g transform="translate(', currentX.toString(), ', 190) scale(3.5)">'));
            textGroup = string(abi.encodePacked(textGroup, '<path fill="', data.hexcode, '" d="', pathData, '"/>'));
            textGroup = string(abi.encodePacked(textGroup, '</g>'));

            if (bytes(char)[0] == 'I') {
                currentX += 9;
            }

            currentX += charWidths[i];
        }
        
        textGroup = string(abi.encodePacked(textGroup, '</g>'));
        svg = string(abi.encodePacked(svg, textGroup));
        svg = string(abi.encodePacked(svg, '</svg>'));
        return svg;
    }

    function isAlpha(string memory str) internal pure returns (bool) {
        bytes memory b = bytes(str);
        for (uint i = 0; i < b.length; i++) {
            // Check if character is A-Z or a-z
            if (!((b[i] >= 0x41 && b[i] <= 0x5A) || (b[i] >= 0x61 && b[i] <= 0x7A))) {
                return false;
            }
        }
        return true;
    }

    function toUpperCase(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bUpper = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // If lowercase letter (a-z), convert to uppercase
            if (bStr[i] >= 0x61 && bStr[i] <= 0x7A) {
                bUpper[i] = bytes1(uint8(bStr[i]) - 32);
            } else {
                bUpper[i] = bStr[i];
            }
        }
        return string(bUpper);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }

    function _setupCharacterPaths() internal {
        // SVG path data for Doto-Bold.ttf
        characterPaths["$"] = "m 5.7748539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.0800001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["A"] = "m 5.7748539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["B"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.08,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 3.2348539,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.08,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["C"] = "m 3.2348539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["D"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.08,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 3.2348539,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 3.2348539,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["E"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["F"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["G"] = "m 3.2348539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.61999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["H"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["I"] = "m 3.2348539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["J"] = "m 5.7748539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.5400001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.61999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.08,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["K"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.61999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.07999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.61999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["L"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["M"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.0800001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["N"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.6200001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.0800001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.61999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["O"] = "m 3.2348539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["P"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["Q"] = "m 3.2348539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.0800001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,2.539999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["R"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.07999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 7.61999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["S"] = "m 3.2348539,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 3.2348539,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["T"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.0800001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["U"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["V"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 3.2348539,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.08,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -5.08,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["W"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,9.5154056 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.0800001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z M 0.69485399,12.055406 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.07999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.0800001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["X"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.61999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["Y"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -10.16000001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 10.16000001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -7.6200001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 5.08,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
        characterPaths["Z"] = "m 0.69485399,1.8954057 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.5400001,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8541999 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 7.0008057 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.5399999 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542004 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 V 9.5408056 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.54,2.5400004 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m -2.53999991,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.8542 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.8542 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 0,2.54 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 H 2.549054 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.53999991,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.54,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542001 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z m 2.5400001,0 v 0 q -0.0254,0 -0.0254,0 0,0 0,0.0254 v 1.854199 q 0,0.0254 0,0.0254 0,0 0.0254,0 h 1.8542 q 0.0254,0 0.0254,0 0,0 0,-0.0254 v -1.854199 q 0,-0.0254 0,-0.0254 0,0 -0.0254,0 z";
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BloodCampNFT contract
 * @author Mansi
 * @notice Contract to deploy and manage BloodCampNFTs
 */

contract BloodCampNFT is ERC721, Ownable {
    /**Errors */
    error BloodCampNFT__URINonExistentToken();
    error BloodCampNFT__NonExistentToken();
    error BloodCampNFT__UserAlreadyExists();
    error BloodCampNFT__NameEmpty();
    error BloodCampNFT__UserDoesNotExist();

    /**State Variables */
    uint256 private _tokenIdCounter;
    mapping(uint256 => string) private _tokenURIs; // Stores metadata URIs

    /**
     * @dev Constructor to initialize the contract
     * @notice Initializes the contract with the name and symbol of the NFT
     */
    constructor() ERC721("BloodCampNFT", "BCNFT") Ownable(msg.sender) {}

    /**
     * @dev Function to mint a NFT upon successful blood donation
     * @param to Address of the recipient
     * @param uri Metadata URI of the NFT
     * @return tokenId of the minted NFT
     */

    function mint(
        address to,
        string memory uri
    ) public onlyOwner returns (uint256) {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    /**
     * @dev Function to check if a token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Function to set the metadata URI of a token
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    /**
     * @dev Function to get the metadata URI of a token
     * @param tokenId Token ID to get the URI for
     * @return string Metadata URI of the token
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Function to set the metadata URI of a token
     */
    function setTokenURI(uint256 tokenId, string memory newTokenURI) public {
        _setTokenURI(tokenId, newTokenURI);
    }

    /**State Variables */
    struct UserInfo {
        string name;
        address userAddress;
    }

    BloodCampNFT public bloodCampNFT = BloodCampNFT(0xAF514448B349AB2a21F9A27D3f9C448Ceedd067f);

    mapping(address => UserInfo) private users;

    event UserCreated(address indexed user, string name);

    // constructor(address _bloodCampNFTAddress) {
    //     bloodCampNFT = BloodCampNFT(_bloodCampNFTAddress);
    // }

    modifier userDoesNotExist(address _user) {
        require(bytes(users[_user].name).length == 0, "User already exists");
        _;
    }

    function createUser(string memory _name) public userDoesNotExist(msg.sender) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        users[msg.sender] = UserInfo({
            name: _name,
            userAddress: msg.sender
        });
        emit UserCreated(msg.sender, _name);
    }

    function getUser(address _user) public view returns (string memory, address) {
        require(bytes(users[_user].name).length > 0, "User does not exist");
        return (users[_user].name, users[_user].userAddress);
    }

    function getOwnedNFTs(address _user) public view returns (uint256[] memory) {
        uint256 maxIterations = 1000;
        uint256[] memory tempOwned = new uint256[](maxIterations);
        uint256 count = 0;

        for (uint256 tokenId = 1; tokenId <= maxIterations; tokenId++) {
            try bloodCampNFT.ownerOf(tokenId) returns (address owner) {
                if (owner == _user) {
                    tempOwned[count] = tokenId;
                    count++;
                }
            } catch {
                break;
            }
        }

        uint256[] memory ownedTokens = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            ownedTokens[i] = tempOwned[i];
        }
        string[] memory uri = new string[](count);
        for (uint256 i = 0; i < count; i++) {
            uri[i] = bloodCampNFT.tokenURI(ownedTokens[i]);
        }
        
        return ownedTokens;
    }
}

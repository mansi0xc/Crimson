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

/**
 * @title BloodCamp contract
 * @author Mansi
 * @notice Contract to deploy and manage BloodCamps
 */

contract BloodCamp {
    /**Errors */
    error BloodCamp__CampDoesNotExist();
    error BloodCamp__CampAlreadyExists();
    error BloodCamp__CampNotOwner();

    /**Type Declarations */
    struct Camp {
        uint256 id;
        string name;
        string organizer;
        string city;
        address owner;
        string lat;
        string long;
    }

    enum BloodType {
        O_POS, //0
        O_NEG, //1
        A_POS, //2
        A_NEG, //3
        B_POS, //4
        B_NEG, //5
        AB_POS, //6
        AB_NEG //7
    }

    struct vial {
        string id;
        string donor;
        BloodType bloodType;
        string camp;
        string date;
        string status;
    }

    struct Hospital {
        uint256 hid;
        string name;
        string city;
        address owner;
    }

    /**State Variables */
    uint256[] public campIds;
    mapping(uint256 => Camp) private camps;
    mapping(uint256 => Hospital) private hospitals;
    mapping(uint256 => mapping(BloodType => uint256)) private campInventory;
    mapping(uint256 => mapping(BloodType => mapping(string => vial))) private hospitalInventory;
    mapping(uint256 => address[]) private registeredUsers;
    mapping(uint256 => address[]) private donatedUsers;

    BloodCampNFT public bloodCampNFT;

    modifier onlyCampOwner(uint256 _id) {
        require(
            camps[_id].owner == msg.sender,
            "Only the camp owner can modify this camp"
        );
        _;
    }

    modifier campExists(uint256 _id) {
        require(camps[_id].id != 0, "Camp does not exist");
        _;
    }

    event CampCreated(
        uint256 indexed id,
        string name,
        string organizer,
        string city,
        address owner
    );
    event InventoryUpdated(
        uint256 indexed id,
        BloodType bloodType
    );
    event UserRegistered(uint256 indexed id, address user);
    event UserDonated(uint256 indexed id, address user);
    event NFTIssued(
        uint256 indexed campId,
        address indexed to,
        uint256 tokenId,
        string uri
    );

    constructor() {
        bloodCampNFT = new BloodCampNFT();
    }

    /**
     * @dev Function to create a new blood camp
     */
    function createCamp(
        uint256 _id,
        string memory _name,
        string memory _organizer,
        string memory _city,
        string memory _lat,
        string memory _long
    ) public {
        require(camps[_id].id == 0, "Camp ID already exists");

        camps[_id] = Camp({
            id: _id,
            name: _name,
            organizer: _organizer,
            city: _city,
            owner: msg.sender,
            lat: _lat,
            long: _long
        });

        campIds.push(_id);
        emit CampCreated(_id, _name, _organizer, _city, msg.sender);
    }

    function createHospital(
        uint256 _id,
        string memory _name,
        string memory _city
    ) public {
        require(hospitals[_id].id == 0, "Hospital ID already exists");

        hospitals[_id] = Hospital({
            hid: _id,
            name: _name,
            city: _city,
            owner: msg.sender
        });

        hospitalIds.push(_id);
        emit HospitalRegistered(_id, _name, _city, msg.sender);
    }

    function updateInventory(
        uint256 _id,
        string memory _vid,
        BloodType _bloodType,
        string memory _donor,
        string memory _date,
        string memory _camp
    ) public onlyCampOwner(_id) campExists(_id) {
        campInventory[_id][_bloodType] += 1;
        hospitalInventory[_id][_bloodType][_vid] = vial({
            id: _vid,
            donor: _donor,
            bloodType: _bloodType,
            camp: _camp,
            date: _date,
            status: "In Camp"
        });
        emit InventoryUpdated(_id, _bloodType);
    }

    function transferVialToHospital(
        uint256 _id,
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public onlyCampOwner(_id) campExists(_id) {
        campInventory[_id][_bloodType] -= 1;
        hospitalInventory[_hospitalId][_bloodType][_vid].status = "In Hospital";
    }

    function vialUsed(
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public {
        hospitalInventory[_hospitalId][_bloodType][_vid].status = "Used";
    }
    
    function addRegisteredUser(
        uint256 _id,
        address _user
    ) public onlyCampOwner(_id) campExists(_id) {
        registeredUsers[_id].push(_user);
        emit UserRegistered(_id, _user);
    }

    function addDonatedUser(
        uint256 _id,
        address _user
    ) public onlyCampOwner(_id) campExists(_id) {
        donatedUsers[_id].push(_user);
        emit UserDonated(_id, _user);
    }

    function issueNFT(
        uint256 _id,
        address _to,
        string memory _uri
    ) public onlyCampOwner(_id) campExists(_id) {
        // Mint an NFT with a custom metadata URI.
        uint256 tokenId = bloodCampNFT.mint(_to, _uri);
        emit NFTIssued(_id, _to, tokenId, _uri);
    }

    /*
    *Getter Functions 
    */

    function getCamp(
        uint256 _id
    ) public view campExists(_id) returns (Camp memory) {
        return camps[_id];
    }

    function getAllCamps() public view returns (Camp[] memory) {
        Camp[] memory allCamps = new Camp[](campIds.length);
        for (uint256 i = 0; i < campIds.length; i++) {
            allCamps[i] = camps[campIds[i]];
        }
        return allCamps;
    }

    function getCampInventory(
        uint256 _id,
        BloodType _bloodType
    ) public view campExists(_id) returns (uint256) {
        return campInventory[_id][_bloodType];
    }

    function getHospitalInventory(
        uint256 _id,
        BloodType _bloodType)

    function getRegisteredUsers(
        uint256 _id
    ) public view campExists(_id) returns (address[] memory) {
        return registeredUsers[_id];
    }

    function getDonatedUsers(
        uint256 _id
    ) public view campExists(_id) returns (address[] memory) {
        return donatedUsers[_id];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BloodCampNFT} from "./BloodCampNFT.sol";
 
contract BloodCamp {
    /**Errors */
    error BloodCamp__CampDoesNotExist();
    error BloodCamp__CampAlreadyExists();
    error BloodCamp__CampNotOwner();
    error BloodCamp__HospitalDoesNotExist();
    error BloodCamp__HospitalAlreadyExists();
    error BloodCamp__HospitalNotOwner();
    error BloodCamp__InsufficientInventory();
    error BloodCamp__VialNotFound();
    error BloodCamp__InvalidOperation();

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

    enum VialStatus {
        IN_CAMP,
        IN_HOSPITAL,
        USED,
        EXPIRED
    }

    struct Vial {
        string vid;
        string donor;
        BloodType bloodType;
        string camp;
        string date;
        VialStatus status;
        uint256 timestamp; // When the vial was created/updated
    }

    struct Hospital {
        uint256 hid;
        string name;
        string city;
        address owner;
    }

    /**State Variables */
    uint256[] public campIds;
    uint256[] public hospitalIds;
    mapping(uint256 => Camp) private camps;
    mapping(uint256 => Hospital) private hospitals;
    mapping(uint256 => mapping(BloodType => uint256)) private campInventory;
    mapping(uint256 => mapping(BloodType => mapping(string => Vial))) private vialRegistry;
    
    // Track vial IDs by hospital and blood type
    mapping(uint256 => mapping(BloodType => string[])) private hospitalVialIds;
    mapping(uint256 => mapping(string => bool)) private vialExists;
    
    mapping(uint256 => address[]) private registeredUsers;
    mapping(uint256 => address[]) private donatedUsers;

    BloodCampNFT public bloodCampNFT;

    modifier onlyCampOwner(uint256 _id) {
        if (camps[_id].owner != msg.sender) {
            revert BloodCamp__CampNotOwner();
        }
        _;
    }

    modifier onlyHospitalOwner(uint256 _id) {
        if (hospitals[_id].owner != msg.sender) {
            revert BloodCamp__HospitalNotOwner();
        }
        _;
    }

    modifier campExists(uint256 _id) {
        if (camps[_id].id == 0) {
            revert BloodCamp__CampDoesNotExist();
        }
        _;
    }

    modifier hospitalExists(uint256 _id) {
        if (hospitals[_id].hid == 0) {
            revert BloodCamp__HospitalDoesNotExist();
        }
        _;
    }

    modifier vialExistsModifier(string memory _vid) {
        if (!vialExists[0][_vid]) {
            revert BloodCamp__VialNotFound();
        }
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
        BloodType bloodType,
        string vialId
    );
    event VialTransferred(
        uint256 indexed fromCampId,
        uint256 indexed toHospitalId,
        BloodType bloodType,
        string vialId
    );
    event VialStatusChanged(
        uint256 indexed entityId,
        string vialId,
        VialStatus status
    );
    event UserRegistered(uint256 indexed id, address user);
    event UserDonated(uint256 indexed id, address user);
    event NFTIssued(
        uint256 indexed campId,
        address indexed to,
        uint256 tokenId,
        string uri
    );
    event HospitalRegistered(
        uint256 indexed id,
        string name,
        string city,
        address owner
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
        if (camps[_id].id != 0) {
            revert BloodCamp__CampAlreadyExists();
        }

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
        uint256 _hid,
        string memory _name,
        string memory _city
    ) public {
        if (hospitals[_hid].hid != 0) {
            revert BloodCamp__HospitalAlreadyExists();
        }

        hospitals[_hid] = Hospital({
            hid: _hid,
            name: _name,
            city: _city,
            owner: msg.sender
        });

        hospitalIds.push(_hid);
        emit HospitalRegistered(_hid, _name, _city, msg.sender);
    }

    function updateInventory(
        uint256 _id,
        string memory _vid,
        BloodType _bloodType,
        string memory _donor,
        string memory _date,
        string memory _camp
    ) public onlyCampOwner(_id) campExists(_id) {
        // Check that vial ID is unique
        if (vialExists[0][_vid]) {
            revert BloodCamp__InvalidOperation();
        }

        campInventory[_id][_bloodType] += 1;
        vialRegistry[_id][_bloodType][_vid] = Vial({
            vid: _vid,
            donor: _donor,
            bloodType: _bloodType,
            camp: _camp,
            date: _date,
            status: VialStatus.IN_CAMP,
            timestamp: block.timestamp
        });
        
        // Mark that this vial now exists
        vialExists[0][_vid] = true;
        
        emit InventoryUpdated(_id, _bloodType, _vid);
    }

    function transferVialToHospital(
        uint256 _id,
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public onlyCampOwner(_id) campExists(_id) hospitalExists(_hospitalId) vialExistsModifier(_vid) {
        // Check if there's enough inventory
        if (campInventory[_id][_bloodType] == 0) {
            revert BloodCamp__InsufficientInventory();
        }
        
        // Verify the vial is in the camp and has correct status
        Vial storage vial = vialRegistry[_id][_bloodType][_vid];
        if (vial.status != VialStatus.IN_CAMP) {
            revert BloodCamp__InvalidOperation();
        }
        
        // Update inventory counts
        campInventory[_id][_bloodType] -= 1;
        
        // Update vial status
        vialRegistry[_id][_bloodType][_vid].status = VialStatus.IN_HOSPITAL;
        vialRegistry[_id][_bloodType][_vid].timestamp = block.timestamp;
        
        // Add vial ID to the hospital's tracking array
        hospitalVialIds[_hospitalId][_bloodType].push(_vid);
        
        emit VialTransferred(_id, _hospitalId, _bloodType, _vid);
        emit VialStatusChanged(_hospitalId, _vid, VialStatus.IN_HOSPITAL);
    }

    function vialUsed(
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public onlyHospitalOwner(_hospitalId) hospitalExists(_hospitalId) vialExistsModifier(_vid) {
        // Verify the vial is in the hospital
        Vial storage vial = vialRegistry[_hospitalId][_bloodType][_vid];
        if (vial.status != VialStatus.IN_HOSPITAL) {
            revert BloodCamp__InvalidOperation();
        }
        
        vialRegistry[_hospitalId][_bloodType][_vid].status = VialStatus.USED;
        vialRegistry[_hospitalId][_bloodType][_vid].timestamp = block.timestamp;
        
        emit VialStatusChanged(_hospitalId, _vid, VialStatus.USED);
    }
    
    function markVialExpired(
        uint256 _entityId,  // Can be camp or hospital ID
        BloodType _bloodType,
        string memory _vid
    ) public vialExistsModifier(_vid) {
        Vial storage vial = vialRegistry[_entityId][_bloodType][_vid];
        bool isAuthorized = false;
        
        // Check if sender is authorized (either camp owner or hospital owner)
        if (vial.status == VialStatus.IN_CAMP && camps[_entityId].owner == msg.sender) {
            isAuthorized = true;
        } else if (vial.status == VialStatus.IN_HOSPITAL && hospitals[_entityId].owner == msg.sender) {
            isAuthorized = true;
        }
        
        if (!isAuthorized) {
            revert BloodCamp__InvalidOperation();
        }
        
        vialRegistry[_entityId][_bloodType][_vid].status = VialStatus.EXPIRED;
        vialRegistry[_entityId][_bloodType][_vid].timestamp = block.timestamp;
        
        // If in camp, update inventory
        if (vial.status == VialStatus.IN_CAMP) {
            campInventory[_entityId][_bloodType] -= 1;
        }
        
        emit VialStatusChanged(_entityId, _vid, VialStatus.EXPIRED);
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
    * Helper Functions 
    */
    
    function getBloodTypeString(BloodType _bloodType) public pure returns (string memory) {
        if (_bloodType == BloodType.O_POS) return "O+";
        if (_bloodType == BloodType.O_NEG) return "O-";
        if (_bloodType == BloodType.A_POS) return "A+";
        if (_bloodType == BloodType.A_NEG) return "A-";
        if (_bloodType == BloodType.B_POS) return "B+";
        if (_bloodType == BloodType.B_NEG) return "B-";
        if (_bloodType == BloodType.AB_POS) return "AB+";
        if (_bloodType == BloodType.AB_NEG) return "AB-";
        
        revert("Invalid blood type");
    }
    
    function getVialStatusString(VialStatus _status) public pure returns (string memory) {
        if (_status == VialStatus.IN_CAMP) return "In Camp";
        if (_status == VialStatus.IN_HOSPITAL) return "In Hospital";
        if (_status == VialStatus.USED) return "Used";
        if (_status == VialStatus.EXPIRED) return "Expired";
        
        revert("Invalid vial status");
    }

    /*
    * Getter Functions 
    */

    function getCamp(
        uint256 _id
    ) public view campExists(_id) returns (Camp memory) {
        return camps[_id];
    }

    function getHospital(
        uint256 _id
    ) public view hospitalExists(_id) returns (Hospital memory) {
        return hospitals[_id];
    }

    function getAllCamps() public view returns (Camp[] memory) {
        Camp[] memory allCamps = new Camp[](campIds.length);
        for (uint256 i = 0; i < campIds.length; i++) {
            allCamps[i] = camps[campIds[i]];
        }
        return allCamps;
    }

    function getAllHospitals() public view returns (Hospital[] memory) {
        Hospital[] memory allHospitals = new Hospital[](hospitalIds.length);
        for (uint256 i = 0; i < hospitalIds.length; i++) {
            allHospitals[i] = hospitals[hospitalIds[i]];
        }
        return allHospitals;
    }

    function getCampInventory(
        uint256 _id,
        BloodType _bloodType
    ) public view campExists(_id) returns (uint256) {
        return campInventory[_id][_bloodType];
    }

    function getVial(
        uint256 _entityId,
        BloodType _bloodType,
        string memory _vid
    ) public view vialExistsModifier(_vid) returns (Vial memory) {
        return vialRegistry[_entityId][_bloodType][_vid];
    }

    function getHospitalInventory(
        uint256 _id,
        BloodType _bloodType
    ) public view hospitalExists(_id) returns (Vial[] memory) {
        string[] memory vialIds = hospitalVialIds[_id][_bloodType];
        Vial[] memory result = new Vial[](vialIds.length);
        
        for (uint256 i = 0; i < vialIds.length; i++) {
            result[i] = vialRegistry[_id][_bloodType][vialIds[i]];
        }
        return result;
    }

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
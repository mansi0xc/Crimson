// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Creation} from "./CampHospitals.sol";
import {BloodCampNFT} from "./BloodCampNFT.sol";
import {Donation} from "./Donation.sol";

contract VialRegistration is Creation, Donation {
    /**Errors */
    // error BloodCamp__CampDoesNotExist();
    // error BloodCamp__CampAlreadyExists();
    error BloodCamp__CampNotOwner();
    // error BloodCamp__HospitalDoesNotExist();
    // error BloodCamp__HospitalAlreadyExists();
    error BloodCamp__HospitalNotOwner();
    error BloodCamp__InsufficientInventory();
    error BloodCamp__VialNotFound();
    error BloodCamp__InvalidOperation();

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

    mapping(uint256 => mapping(BloodType => uint256)) private campInventory;
    mapping(uint256 => mapping(BloodType => mapping(string => Vial))) private vialRegistry;
    
    // Track vial IDs by hospital and blood type
    mapping(uint256 => mapping(BloodType => string[])) private hospitalVialIds;
    mapping(uint256 => mapping(string => bool)) private vialExists;

    modifier vialExistsModifier(string memory _vid) {
        if (!vialExists[0][_vid]) {
            revert BloodCamp__VialNotFound();
        }
        _;
    }

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
}
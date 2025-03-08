// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Creation contract
 * @notice Contract to create and manage blood donation camps and hospitals
 */

contract Creation {
    /**Errors */
    error BloodCamp__CampDoesNotExist();
    error BloodCamp__CampAlreadyExists();
    // error BloodCamp__CampNotOwner();
    error BloodCamp__HospitalDoesNotExist();
    error BloodCamp__HospitalAlreadyExists();
    // error BloodCamp__HospitalNotOwner();

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

    struct Hospital {
        uint256 hid;
        string name;
        string city;
        address owner;
    }

    /**State Variables */
    uint256[] public campIds;
    uint256[] public hospitalIds;
    mapping(uint256 => Camp) internal camps;
    mapping(uint256 => Hospital) internal hospitals;

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

    event CampCreated(
        uint256 indexed id,
        string name,
        string organizer,
        string city,
        address owner
    );

    event HospitalRegistered(
        uint256 indexed id,
        string name,
        string city,
        address owner
    );

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
}
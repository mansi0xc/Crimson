// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Creation} from "./CampHospitals.sol";
import {BloodCampNFT} from "./BloodCampNFT.sol";

/**
 * @title Donation contract
 * @author Mansi
 * @notice Contract to manage blood donation and NFT minting
 */

contract Donation is Creation {
    /**Errors */
    //error BloodCamp__CampDoesNotExist();
    //error BloodCamp__CampAlreadyExists();
    error BloodCamp__CampNotOwner();
    //error BloodCamp__HospitalDoesNotExist();
    //error BloodCamp__HospitalAlreadyExists();
    error BloodCamp__HospitalNotOwner();

    /**Type Declarations */
    // enum BloodType {
    //     O_POS, //0
    //     O_NEG, //1
    //     A_POS, //2
    //     A_NEG, //3
    //     B_POS, //4
    //     B_NEG, //5
    //     AB_POS, //6
    //     AB_NEG //7
    // }

    mapping(uint256 => address[]) private donatedUsers;

    BloodCampNFT public bloodCampNFT;
    Creation public creation;

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

    //event UserRegistered(uint256 indexed id, address user);
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

    /**
     * Getter Functions
     */

    function getDonatedUsers(
        uint256 _id
    ) public view campExists(_id) returns (address[] memory) {
        return donatedUsers[_id];
    }
}

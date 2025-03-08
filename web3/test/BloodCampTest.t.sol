// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BloodCamp.sol";

contract BloodCampTest is Test {
    BloodCamp public bloodCamp;
    BloodCampNFT public bloodCampNFT;
    
    address owner = address(1);
    address user1 = address(2);
    address user2 = address(3);
    address hospitalOwner = address(4);

    // Blood types enum
    BloodCamp.BloodType constant O_POS = BloodCamp.BloodType.O_POS;
    BloodCamp.BloodType constant O_NEG = BloodCamp.BloodType.O_NEG;
    BloodCamp.BloodType constant A_POS = BloodCamp.BloodType.A_POS;
    BloodCamp.BloodType constant A_NEG = BloodCamp.BloodType.A_NEG;

    function setUp() public {
        vm.startPrank(owner);
        bloodCamp = new BloodCamp();
        address nftAddress = address(bloodCamp.bloodCampNFT());
        bloodCampNFT = BloodCampNFT(nftAddress);
        vm.stopPrank();
    }

    function testCreateCamp() public {
        vm.startPrank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");
        vm.stopPrank();

        BloodCamp.Camp memory camp = bloodCamp.getCamp(1);
        assertEq(camp.id, 1);
        assertEq(camp.name, "Red Cross Camp");
        assertEq(camp.organizer, "Red Cross");
        assertEq(camp.city, "New York");
        assertEq(camp.owner, owner);
        assertEq(camp.lat, "40.7128");
        assertEq(camp.long, "-74.0060");
    }

    function testFailCreateDuplicateCamp() public {
        vm.startPrank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");
        bloodCamp.createCamp(1, "Another Camp", "Another Org", "Boston", "42.3601", "-71.0589");
        vm.stopPrank();
    }

    function testGetAllCamps() public {
        vm.startPrank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");
        bloodCamp.createCamp(2, "Blood Drive", "City Hospital", "Chicago", "41.8781", "-87.6298");
        vm.stopPrank();

        BloodCamp.Camp[] memory camps = bloodCamp.getAllCamps();
        assertEq(camps.length, 2);
        assertEq(camps[0].name, "Red Cross Camp");
        assertEq(camps[1].name, "Blood Drive");
    }

    function testCreateHospital() public {
        vm.prank(hospitalOwner);
        bloodCamp.createHospital(1, "City Hospital", "New York");

        // Verify the hospital was created by checking the hospitalIds array
        assertEq(bloodCamp.hospitalIds(0), 1);
    }

    function testFailCreateDuplicateHospital() public {
        vm.startPrank(hospitalOwner);
        bloodCamp.createHospital(1, "City Hospital", "New York");
        bloodCamp.createHospital(1, "Another Hospital", "Boston");
        vm.stopPrank();
    }

    function testRegisterAndDonateUsers() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Register a user
        vm.prank(owner);
        bloodCamp.addRegisteredUser(1, user1);
        
        // Check if user is registered
        address[] memory registeredUsers = bloodCamp.getRegisteredUsers(1);
        assertEq(registeredUsers.length, 1);
        assertEq(registeredUsers[0], user1);

        // Mark user as donated
        vm.prank(owner);
        bloodCamp.addDonatedUser(1, user1);
        
        // Check if user is marked as donated
        address[] memory donatedUsers = bloodCamp.getDonatedUsers(1);
        assertEq(donatedUsers.length, 1);
        assertEq(donatedUsers[0], user1);
    }

    function testFailAddRegisteredUserNonOwner() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Try to register a user from non-owner account
        vm.prank(user2);
        bloodCamp.addRegisteredUser(1, user1);
    }

    function testUpdateInventory() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Add blood vial to inventory
        vm.prank(owner);
        bloodCamp.updateInventory(
            1,                          // camp id
            "VIAL001",                  // vial id
            O_POS,                      // blood type
            "John Doe",                 // donor name
            "2025-03-08",               // date
            "Red Cross Camp"            // camp name
        );

        // Check if inventory was updated
        uint256 campInventory = bloodCamp.getCampInventory(1, O_POS);
        assertEq(campInventory, 1);
    }

    function testFailUpdateInventoryNonOwner() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Try to update inventory from non-owner account
        vm.prank(user1);
        bloodCamp.updateInventory(
            1,                          // camp id
            "VIAL001",                  // vial id
            O_POS,                      // blood type
            "John Doe",                 // donor name
            "2025-03-08",               // date
            "Red Cross Camp"            // camp name
        );
    }

    function testTransferVialToHospital() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Create a hospital
        vm.prank(hospitalOwner);
        bloodCamp.createHospital(1, "City Hospital", "New York");

        // Add blood vial to inventory
        vm.prank(owner);
        bloodCamp.updateInventory(
            1,                          // camp id
            "VIAL001",                  // vial id
            O_POS,                      // blood type
            "John Doe",                 // donor name
            "2025-03-08",               // date
            "Red Cross Camp"            // camp name
        );

        // Transfer vial to hospital
        vm.prank(owner);
        bloodCamp.transferVialToHospital(1, 1, O_POS, "VIAL001");

        // Check if camp inventory was updated
        uint256 campInventory = bloodCamp.getCampInventory(1, O_POS);
        assertEq(campInventory, 0);

        // Check if hospital inventory was updated
        BloodCamp.vial[] memory hospitalInventory = bloodCamp.getHospitalInventory(1, O_POS);
        assertEq(hospitalInventory.length, 1);
        assertEq(hospitalInventory[0].vid, "VIAL001");
        assertEq(hospitalInventory[0].status, "In Hospital");
    }

    function testVialUsed() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Create a hospital
        vm.prank(hospitalOwner);
        bloodCamp.createHospital(1, "City Hospital", "New York");

        // Add blood vial to inventory
        vm.prank(owner);
        bloodCamp.updateInventory(
            1,                          // camp id
            "VIAL001",                  // vial id
            O_POS,                      // blood type
            "John Doe",                 // donor name
            "2025-03-08",               // date
            "Red Cross Camp"            // camp name
        );

        // Transfer vial to hospital
        vm.prank(owner);
        bloodCamp.transferVialToHospital(1, 1, O_POS, "VIAL001");

        // Mark vial as used
        vm.prank(hospitalOwner);
        bloodCamp.vialUsed(1, O_POS, "VIAL001");

        // Check if vial status was updated
        BloodCamp.vial[] memory hospitalInventory = bloodCamp.getHospitalInventory(1, O_POS);
        assertEq(hospitalInventory[0].status, "Used");
    }

    function testIssueNFT() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Issue NFT
        string memory tokenURI = "ipfs://QmExample";
        vm.prank(owner);
        bloodCamp.issueNFT(1, user1, tokenURI);

        // Check if NFT was minted
        assertEq(bloodCampNFT.ownerOf(1), user1);
        assertEq(bloodCampNFT.tokenURI(1), tokenURI);
    }

    function testMultipleBloodTypes() public {
        // First create a camp
        vm.prank(owner);
        bloodCamp.createCamp(1, "Red Cross Camp", "Red Cross", "New York", "40.7128", "-74.0060");

        // Create a hospital
        vm.prank(hospitalOwner);
        bloodCamp.createHospital(1, "City Hospital", "New York");

        // Add different blood types to inventory
        vm.startPrank(owner);
        // O Positive
        bloodCamp.updateInventory(1, "VIAL001", O_POS, "John Doe", "2025-03-08", "Red Cross Camp");
        // O Negative
        bloodCamp.updateInventory(1, "VIAL002", O_NEG, "Jane Smith", "2025-03-08", "Red Cross Camp");
        // A Positive
        bloodCamp.updateInventory(1, "VIAL003", A_POS, "Bob Jones", "2025-03-08", "Red Cross Camp");
        // A Negative
        bloodCamp.updateInventory(1, "VIAL004", A_NEG, "Alice Brown", "2025-03-08", "Red Cross Camp");
        vm.stopPrank();

        // Check inventories
        assertEq(bloodCamp.getCampInventory(1, O_POS), 1);
        assertEq(bloodCamp.getCampInventory(1, O_NEG), 1);
        assertEq(bloodCamp.getCampInventory(1, A_POS), 1);
        assertEq(bloodCamp.getCampInventory(1, A_NEG), 1);

        // Transfer vials to hospital
        vm.startPrank(owner);
        bloodCamp.transferVialToHospital(1, 1, O_POS, "VIAL001");
        bloodCamp.transferVialToHospital(1, 1, O_NEG, "VIAL002");
        bloodCamp.transferVialToHospital(1, 1, A_POS, "VIAL003");
        vm.stopPrank();

        // Check hospital inventories
        BloodCamp.vial[] memory oposInventory = bloodCamp.getHospitalInventory(1, O_POS);
        BloodCamp.vial[] memory onegInventory = bloodCamp.getHospitalInventory(1, O_NEG);
        BloodCamp.vial[] memory aposInventory = bloodCamp.getHospitalInventory(1, A_POS);
        BloodCamp.vial[] memory anegInventory = bloodCamp.getHospitalInventory(1, A_NEG);

        assertEq(oposInventory.length, 1);
        assertEq(onegInventory.length, 1);
        assertEq(aposInventory.length, 1);
        assertEq(anegInventory.length, 0); // A- wasn't transferred

        // Check camp inventories again (should be reduced)
        assertEq(bloodCamp.getCampInventory(1, O_POS), 0);
        assertEq(bloodCamp.getCampInventory(1, O_NEG), 0);
        assertEq(bloodCamp.getCampInventory(1, A_POS), 0);
        assertEq(bloodCamp.getCampInventory(1, A_NEG), 1); // A- remains
    }
}

contract BloodCampNFTStandaloneTest is Test {
    BloodCampNFT public bloodCampNFT;
    
    address owner = address(1);
    address user1 = address(2);
    address user2 = address(3);

    function setUp() public {
        vm.startPrank(owner);
        bloodCampNFT = new BloodCampNFT();
        vm.stopPrank();
    }

    function testNFTDeployment() public {
        assertEq(bloodCampNFT.name(), "BloodCampNFT");
        assertEq(bloodCampNFT.symbol(), "BCNFT");
        assertEq(bloodCampNFT.owner(), owner);
    }

    function testMintNFT() public {
        vm.prank(owner);
        uint256 tokenId = bloodCampNFT.mint(user1, "ipfs://QmExample");
        
        assertEq(tokenId, 1);
        assertEq(bloodCampNFT.ownerOf(1), user1);
        assertEq(bloodCampNFT.tokenURI(1), "ipfs://QmExample");
    }

    function testFailMintNFTNonOwner() public {
        vm.prank(user1);
        bloodCampNFT.mint(user2, "ipfs://QmExample");
    }

    function testSetTokenURI() public {
        vm.startPrank(owner);
        uint256 tokenId = bloodCampNFT.mint(user1, "ipfs://QmOriginal");
        bloodCampNFT.setTokenURI(tokenId, "ipfs://QmUpdated");
        vm.stopPrank();
        
        assertEq(bloodCampNFT.tokenURI(tokenId), "ipfs://QmUpdated");
    }

    function testFailTokenURINonExistent() public {
        bloodCampNFT.tokenURI(999);
    }

    function testCreateUser() public {
        vm.prank(user1);
        bloodCampNFT.createUser("John Doe");
        
        (string memory name, address userAddress) = bloodCampNFT.getUser(user1);
        assertEq(name, "John Doe");
        assertEq(userAddress, user1);
    }

    function testFailCreateUserEmptyName() public {
        vm.prank(user1);
        bloodCampNFT.createUser("");
    }

    function testFailCreateUserDuplicate() public {
        vm.startPrank(user1);
        bloodCampNFT.createUser("John Doe");
        bloodCampNFT.createUser("Another Name");
        vm.stopPrank();
    }

}
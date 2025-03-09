// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Creation} from "./CampHospitals.sol";
import {Donation} from "./Donation.sol";
import {VialRegistration} from "./VialRegistration.sol";

contract VialStatus is Creation, Donation, VialRegistration {
    /**Errors */
    error VialStatus__InsufficientInventory();
    // error VialStatus__VialNotFound();
    error VialStatus__InvalidOperation();
    error VialStatus__ApproverAlreadyExists();
    error VialStatus__ApproverDoesNotExist();
    error VialStatus__NotApprover();
    error VialStatus__AlreadyApproved();
    error VialStatus__InsufficientApprovals();
    error VialStatus__TooManyApprovers();

    // Constants
    uint256 private constant REQUIRED_APPROVALS = 7;
    uint256 private constant MAX_APPROVERS = 10;

    // Multi-signature approvers management
    mapping(uint256 => address[]) private hospitalApprovers;
    
    // Keep track of approvals for each vial status update request
    struct StatusUpdateRequest {
        uint256 entityId;
        BloodType bloodType;
        string vialId;
        VialStatus newStatus;
        uint256 approvalCount;
        mapping(address => bool) approvals;
        bool executed;
    }
    
    uint256 private requestCount;
    mapping(uint256 => StatusUpdateRequest) private updateRequests;

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
    event ApproverAdded(uint256 indexed hospitalId, address approver);
    event ApproverRemoved(uint256 indexed hospitalId, address approver);
    event StatusUpdateRequested(
        uint256 indexed requestId,
        uint256 entityId,
        string vialId,
        VialStatus newStatus
    );
    event StatusUpdateApproved(
        uint256 indexed requestId,
        address approver,
        uint256 currentApprovals
    );
    event StatusUpdateExecuted(uint256 indexed requestId);

    modifier onlyApprover(uint256 _hospitalId) {
        bool isApprover = false;
        for (uint256 i = 0; i < hospitalApprovers[_hospitalId].length; i++) {
            if (hospitalApprovers[_hospitalId][i] == msg.sender) {
                isApprover = true;
                break;
            }
        }
        if (!isApprover) {
            revert VialStatus__NotApprover();
        }
        _;
    }

    function addHospitalApprover(uint256 _hospitalId, address _approver) 
        public 
        onlyHospitalOwner(_hospitalId) 
        hospitalExists(_hospitalId) 
    {
        // Check if the approver is already registered
        for (uint256 i = 0; i < hospitalApprovers[_hospitalId].length; i++) {
            if (hospitalApprovers[_hospitalId][i] == _approver) {
                revert VialStatus__ApproverAlreadyExists();
            }
        }
        
        // Check if we have reached the maximum number of approvers
        if (hospitalApprovers[_hospitalId].length >= MAX_APPROVERS) {
            revert VialStatus__TooManyApprovers();
        }
        
        hospitalApprovers[_hospitalId].push(_approver);
        emit ApproverAdded(_hospitalId, _approver);
    }
    
    function removeHospitalApprover(uint256 _hospitalId, address _approver)
        public
        onlyHospitalOwner(_hospitalId)
        hospitalExists(_hospitalId)
    {
        bool found = false;
        uint256 approverIndex;
        
        for (uint256 i = 0; i < hospitalApprovers[_hospitalId].length; i++) {
            if (hospitalApprovers[_hospitalId][i] == _approver) {
                found = true;
                approverIndex = i;
                break;
            }
        }
        
        if (!found) {
            revert VialStatus__ApproverDoesNotExist();
        }
        
        // Remove approver by swapping with the last element and then removing the last element
        uint256 lastIndex = hospitalApprovers[_hospitalId].length - 1;
        if (approverIndex != lastIndex) {
            hospitalApprovers[_hospitalId][approverIndex] = hospitalApprovers[_hospitalId][lastIndex];
        }
        hospitalApprovers[_hospitalId].pop();
        
        emit ApproverRemoved(_hospitalId, _approver);
    }
    
    function getHospitalApprovers(uint256 _hospitalId) 
        public 
        view 
        hospitalExists(_hospitalId)
        returns (address[] memory) 
    {
        return hospitalApprovers[_hospitalId];
    }

    function transferVialToHospital(
        uint256 _id,
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public onlyCampOwner(_id) campExists(_id) hospitalExists(_hospitalId) vialExistsModifier(_vid) {
        // Check if there's enough inventory
        if (campInventory[_id][_bloodType] == 0) {
            revert VialStatus__InsufficientInventory();
        }
        
        // Verify the vial is in the camp and has correct status
        Vial storage vial = vialRegistry[_id][_bloodType][_vid];
        if (vial.status != VialStatus.IN_CAMP) {
            revert VialStatus__InvalidOperation();
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

    // Request status update function - creates the request that needs 5 approvals
    function requestStatusUpdate(
        uint256 _entityId,
        BloodType _bloodType,
        string memory _vid,
        VialStatus _newStatus
    ) public hospitalExists(_entityId) vialExistsModifier(_vid) onlyApprover(_entityId) {
        // Verify the vial exists and is accessible
        // Vial storage vial = vialRegistry[_entityId][_bloodType][_vid];
        
        // Create a unique request ID
        uint256 requestId = requestCount++;
        
        // Initialize the request
        StatusUpdateRequest storage request = updateRequests[requestId];
        request.entityId = _entityId;
        request.bloodType = _bloodType;
        request.vialId = _vid;
        request.newStatus = _newStatus;
        request.approvalCount = 1; // First approval from the requester
        request.approvals[msg.sender] = true;
        request.executed = false;
        
        emit StatusUpdateRequested(requestId, _entityId, _vid, _newStatus);
        emit StatusUpdateApproved(requestId, msg.sender, 1);
        
        // Execute immediately if only one approval is required (for testing purposes)
        if (REQUIRED_APPROVALS == 1) {
            executeStatusUpdate(requestId);
        }
    }
    
    // Approve a status update request
    function approveStatusUpdate(uint256 _requestId) 
        public 
        onlyApprover(updateRequests[_requestId].entityId) 
    {
        StatusUpdateRequest storage request = updateRequests[_requestId];
        
        // Check if the request exists and hasn't been executed yet
        if (request.executed) {
            revert VialStatus__InvalidOperation();
        }
        
        // Check if the approver has already approved
        if (request.approvals[msg.sender]) {
            revert VialStatus__AlreadyApproved();
        }
        
        // Record the approval
        request.approvals[msg.sender] = true;
        request.approvalCount += 1;
        
        emit StatusUpdateApproved(_requestId, msg.sender, request.approvalCount);
        
        // Execute the request if we have enough approvals
        if (request.approvalCount >= REQUIRED_APPROVALS) {
            executeStatusUpdate(_requestId);
        }
    }
    
    // Internal function to execute a status update after receiving sufficient approvals
    function executeStatusUpdate(uint256 _requestId) internal {
        StatusUpdateRequest storage request = updateRequests[_requestId];
        
        // Prevent re-execution
        if (request.executed) {
            revert VialStatus__InvalidOperation();
        }
        
        // Verify sufficient approvals
        if (request.approvalCount < REQUIRED_APPROVALS) {
            revert VialStatus__InsufficientApprovals();
        }
        
        // Mark as executed
        request.executed = true;
        
        // Get the vial
        Vial storage vial = vialRegistry[request.entityId][request.bloodType][request.vialId];
        
        // Perform specific status update logic
        if (request.newStatus == VialStatus.IN_TEST_LAB) {
            // Only vials in hospital can go to test lab
            if (vial.status != VialStatus.IN_HOSPITAL) {
                revert VialStatus__InvalidOperation();
            }
        } else if (request.newStatus == VialStatus.USED) {
            // Only vials in hospital or test lab can be marked as used
            if (vial.status != VialStatus.IN_HOSPITAL && vial.status != VialStatus.IN_TEST_LAB) {
                revert VialStatus__InvalidOperation();
            }
        } else if (request.newStatus == VialStatus.EXPIRED) {
            // Any vial can be marked as expired
        } else if (request.newStatus == VialStatus.IN_HOSPITAL) {
            // Only vials in test lab can return to hospital
            if (vial.status != VialStatus.IN_TEST_LAB) {
                revert VialStatus__InvalidOperation();
            }
        } else {
            // IN_CAMP status should not be set through this function
            revert VialStatus__InvalidOperation();
        }
        
        // Update status
        vial.status = request.newStatus;
        vial.timestamp = block.timestamp;
        
        // If marking as expired while in camp, update inventory
        if (request.newStatus == VialStatus.EXPIRED && vial.status == VialStatus.IN_CAMP) {
            campInventory[request.entityId][request.bloodType] -= 1;
        }
        
        emit VialStatusChanged(request.entityId, request.vialId, request.newStatus);
        emit StatusUpdateExecuted(_requestId);
    }
    
    // Legacy function - now uses the multi-sig pattern
    function vialUsed(
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public onlyHospitalOwner(_hospitalId) hospitalExists(_hospitalId) vialExistsModifier(_vid) {
        // This function is now for backward compatibility only
        // The hospital owner can initiate the process, but it still needs approvals
        
        // Check if there are enough approvers
        if (hospitalApprovers[_hospitalId].length < REQUIRED_APPROVALS) {
            revert VialStatus__InsufficientApprovals();
        }
        
        // Initialize a status update request
        requestStatusUpdate(_hospitalId, _bloodType, _vid, VialStatus.USED);
    }
    
    // Legacy function - now uses the multi-sig pattern
    function markVialExpired(
        uint256 _entityId,
        BloodType _bloodType,
        string memory _vid
    ) public vialExistsModifier(_vid) {
        // Determine if this is for a camp or hospital
        Vial storage vial = vialRegistry[_entityId][_bloodType][_vid];
        bool isCamp = vial.status == VialStatus.IN_CAMP;
        
        if (isCamp) {
            // For camps, maintain backward compatibility
            if (camps[_entityId].owner != msg.sender) {
                revert VialStatus__InvalidOperation();
            }
            
            vialRegistry[_entityId][_bloodType][_vid].status = VialStatus.EXPIRED;
            vialRegistry[_entityId][_bloodType][_vid].timestamp = block.timestamp;
            
            // Update inventory
            campInventory[_entityId][_bloodType] -= 1;
            
            emit VialStatusChanged(_entityId, _vid, VialStatus.EXPIRED);
        } else {
            // For hospitals, use the multi-sig process
            // Check if there are enough approvers
            if (hospitalApprovers[_entityId].length < REQUIRED_APPROVALS) {
                revert VialStatus__InsufficientApprovals();
            }
            
            // Hospital owner can initiate, but need additional approvals
            if (hospitals[_entityId].owner != msg.sender) {
                revert VialStatus__InvalidOperation();
            }
            
            requestStatusUpdate(_entityId, _bloodType, _vid, VialStatus.EXPIRED);
        }
    }
    
    // New function specifically for test lab status
    function sendVialToTestLab(
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public onlyHospitalOwner(_hospitalId) hospitalExists(_hospitalId) vialExistsModifier(_vid) {
        // Check if there are enough approvers
        if (hospitalApprovers[_hospitalId].length < REQUIRED_APPROVALS) {
            revert VialStatus__InsufficientApprovals();
        }
        
        // Initialize a status update request
        requestStatusUpdate(_hospitalId, _bloodType, _vid, VialStatus.IN_TEST_LAB);
    }
    
    // Return vial from test lab to hospital
    function returnVialFromTestLab(
        uint256 _hospitalId,
        BloodType _bloodType,
        string memory _vid
    ) public onlyHospitalOwner(_hospitalId) hospitalExists(_hospitalId) vialExistsModifier(_vid) {
        // Check if there are enough approvers
        if (hospitalApprovers[_hospitalId].length < REQUIRED_APPROVALS) {
            revert VialStatus__InsufficientApprovals();
        }
        
        // Initialize a status update request
        requestStatusUpdate(_hospitalId, _bloodType, _vid, VialStatus.IN_HOSPITAL);
    }
    
    // Function to check status of a request
    function getRequestStatus(uint256 _requestId) 
        public 
        view 
        returns (
            uint256 entityId,
            string memory vialId,
            VialStatus newStatus,
            uint256 approvalCount,
            bool executed
        ) 
    {
        StatusUpdateRequest storage request = updateRequests[_requestId];
        return (
            request.entityId,
            request.vialId,
            request.newStatus,
            request.approvalCount,
            request.executed
        );
    }
    
    // Function to check if an address has approved a request
    function hasApproved(uint256 _requestId, address _approver) 
        public 
        view 
        returns (bool) 
    {
        return updateRequests[_requestId].approvals[_approver];
    }
}
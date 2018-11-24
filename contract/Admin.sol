pragma solidity 0.4.25;


contract AdminRole {

    mapping (address => bool) adminGroup;
    
    constructor () public {
        adminGroup[msg.sender] = true;
    }
    
    modifier onlyAdmin() {
        require(
            isAdmin(msg.sender),
            "The caller is not Admin"
        );
        _;
    }

    
    function addAdmin(address addr) external onlyAdmin {
        adminGroup[addr] = true;
    } 
    
    function delAdmin(address addr) external onlyAdmin {
        adminGroup[addr] = false;
    }

    function isAdmin(address addr) public view returns(bool) {
        return adminGroup[addr];
    } 
}


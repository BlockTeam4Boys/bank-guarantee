pragma solidity ^0.4.24;
contract BankData {
    // should be guarantor's address
    // only owner has a access
    address owner = msg.sender;
    
    // true if user in whitelist
    // false if not
    mapping(address => bool) whitelist;
    
    // TODO: CHANGE IT
    // maximum possible value in currency (rubbles for example)
    uint maxSum = 20000;
    
    // security check
    // only guarantor can get access
    // copy from https://solidity.readthedocs.io/en/latest/common-patterns.html#restricting-access
    modifier onlyBy(address account) {
        require(
            msg.sender == account,
            "Well, you are not guarantor."
        );
        _;
    }
    
    // change owner
    // be careful with that function, only the new address will be guarantor
    function changeOwner(address newOwner) external onlyBy(owner) {
        owner = newOwner;
    }
    
    // input user in whitelist
    function addOneAddress(address user) external onlyBy(owner) {
        whitelist[user] = true;
    }
    
    function addManyAddreses(address[] users) external onlyBy(owner) {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
    }
    
    function checkAddress(address user) external view onlyBy(owner) returns(bool) {
        return whitelist[user];
    }
    
    function deleteAddress(address user) external onlyBy(owner){
        whitelist[user] = false;
    }
}

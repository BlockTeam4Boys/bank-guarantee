pragma solidity ^0.4.24;

contract Whitelist {
    // should be guarantor's address
    // only owner has a access
    address owner = msg.sender;
    
    // true if user in whitelist
    // false if not
    mapping(address => bool) private whitelist;
    
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
    event Complete();
    
    // input user in whitelist
    function addOneAddress(address user) external onlyBy(owner) {
        whitelist[user] = true;
        emit Complete();
    }
    
    function addManyAddreses(address[] users) external onlyBy(owner) {
        for (uint i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
        emit Complete();
    }
    
    function checkAddress(address user) external view returns(bool) {
        return whitelist[user];
    }
    
    function deleteAddress(address user) external onlyBy(owner){
        whitelist[user] = false;
        emit Complete();
    }
}
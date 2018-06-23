pragma solidity ^0.4.24;
contract BankData {
    
    address public owner = msg.sender;
    
    mapping(address => bool) whitelist;
    
    modifier onlyBy(address _account) {
        require(
            msg.sender == _account,
            "Sender not authorized."
        );
        _;
    }
    
    function changeOwner(address _newOwner) public onlyBy(owner) {
        owner = _newOwner;
    }
    
    event Check(address membe, bool check );
    
    function addAddress(address member) public onlyBy(owner) {
        whitelist[member] = true;
    }
    
    function addAddreses(address member) public {
    // To be written
    }
    
    function checkAddress(address member) public view returns(bool) {
        emit Check(member, whitelist[member]);
        return whitelist[member];
    }
    
    function deleteAddress(address member) public {
        whitelist[member] = false;
    }
}

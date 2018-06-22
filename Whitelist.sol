pragma solidity ^0.4.0;
contract Whitelist {
    
    mapping(address => bool) w1;

    event Check(
        address member,
        bool check
    );
    
    function addAddressw1(address member) public {
        w1[member] = true;
    }

     function checkAddressw1(address member) public returns(bool) {
        emit Check(member, w1[member]);
        return w1[member];
    }
    
    function deleteAddressw1(address member) public {
        w1[member] = false;
    }
}
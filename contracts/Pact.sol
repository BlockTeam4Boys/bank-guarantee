pragma solidity ^0.4.18;

contract Pact {
    
    address bank;
    uint pact_id;
    
    mapping (uint => Pacts) pacts;
    
    struct Pacts {
        uint256 beneficiary;
        uint256 principal;
        uint256 money;
        uint256 date;
        uint256 time;
        bool    ended;
    }

     event NewPact(
        uint256 beneficiary,
        uint256 principal,
        uint256 money,
        uint256 date,
        uint256 time
    );
    
    event CompletePact(
        uint256 beneficiary,
        uint256 principal,
        uint256 money
    );
    
    event NoSuchPact(
        uint id
    );
    
    function completeContract(uint id) public {
        if(msg.sender != bank) {
            return;
        }
        if(id > pact_id) {
            NoSuchPact(id);
            return;
        }
            
        pacts[id].ended = true;
    }
    
    function createpact(uint256 _benefeciary, uint256 _principal, uint256 _money,uint256 _time) public {
        if(msg.sender != bank) {
            return;
        }
        pacts[pact_id].beneficiary = _benefeciary;
        pacts[pact_id].principal = _principal;
        pacts[pact_id].money = _money;
        pacts[pact_id].date = now;
        pacts[pact_id].time = now + _time * 1 days;
        pact_id++;
        NewPact(_benefeciary, _principal, _money, now, _time);
    }
    
    function getData(uint id) public constant returns(uint256, uint256, uint256,uint256, uint256) {
        if(msg.sender != bank) {
            return;
        }
        if(id > pact_id) {
            NoSuchPact(id);
            return;
        }
        return (pacts[id].beneficiary, pacts[id].principal, pacts[id].money, pacts[id].date, pacts[id].time);
    }
    
    function Pact() public {
        bank = msg.sender;
        pact_id = 0;
    }
    
}

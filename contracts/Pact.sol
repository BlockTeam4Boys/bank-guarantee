pragma solidity ^0.4.21;

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
    
    function completeContract(uint id) public {
        if(msg.sender != bank) {
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
    }
    
    function getData(uint id) public constant returns(uint256[]) {
        if(msg.sender != bank) {
            return;
        }
        uint256[] memory data = new uint256[](5);
        data[0] = pacts[id].beneficiary;
        data[1] = pacts[id].principal;
        data[2] = pacts[id].money;
        data[3] = pacts[id].date;
        data[4] = pacts[id].time;
        return data;
    }
    
    function Pact() public {
        bank = msg.sender;
        pact_id = 0;
    }
    
}

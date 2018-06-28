pragma solidity ^0.4.20;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BankGuarantee {
    // should be guarantor's address
    // only owner has a access
    address public owner = msg.sender;
    
    uint pact_id = 0;

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
    
    modifier onlyWhitelistUser() {
        require (
            // TODO: check with BankData
            true == true,
            "Well, you are not from whitelist."
        );
        _;
    }
    
    // change owner
    // be careful with that function, only the new address will be guarantor
    function changeOwner(address newOwner) public onlyBy(owner) {
        owner = newOwner;
    }

    mapping (uint => Pacts) pacts;
    
    struct Pacts {
        address beneficiary;
        address principal;
        uint256 money;
        uint256 date;
        uint256 time;
        bool    accept;
        bool    ended;
    }
  
    function createpacbytPrincipal(address _beneficiary, uint256 _money, uint256 _time) public onlyWhitelistUser() {
        pacts[pact_id].principal = msg.sender;
        pacts[pact_id].beneficiary = _beneficiary;
        pacts[pact_id].money = _money;
        // check that now equals real now time
        pacts[pact_id].date = now;
        pacts[pact_id].time = _time;
        pact_id++;
    }
    function acceptcontractbyBeneficiary(address _principal, uint256 _money, uint256 _time, uint _pact_id) public onlyWhitelistUser() {
        if (( pacts[_pact_id].principal == _principal) && (pacts[_pact_id].beneficiary == msg.sender) && (pacts[_pact_id].money == _money) && (pacts[_pact_id].time == _time)) {
            pacts[_pact_id].accept = true;     
        }
    }
    function getData(uint id) public view onlyBy(owner) returns(address, address, uint256,uint256, uint256, bool) {
        return (pacts[id].beneficiary, pacts[id].principal, pacts[id].money, pacts[id].date, pacts[id].time, pacts[id].ended);
    }
    
    function completeContract(uint id) public onlyBy(owner) {
        pacts[id].ended = true;
    }
    
    //TIMER-->>
    event LogConstructorInitiated(string nextStep); // for testing -->>
    event LogCallback(uint time);
    event LogNewOraclizeQuery(string description); // <<--for testing
    
    function __callback(bytes32 myid, string result) { 
        if (msg.sender != oraclize_cbAddress()) revert();
        //LogCallback(now); // test 
        if (pacts[pact_id - 1].time - now > 0) {
            createTimer(); // again if remain time
        } else {
            completeContract(pact_id - 1);
        }   
    }
    
    function createTimer() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            //LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            if (pacts[pact_id - 1].time - pacts[pact_id - 1].date > 60 days) { // max period
                //LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(60 days,"URL", ""); // check at max time
            } else {
                //LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(pacts[pact_id].time - pacts[pact_id].date,"URL", ""); // check at time
            }
        }
    }
    //<<--TIMER
}

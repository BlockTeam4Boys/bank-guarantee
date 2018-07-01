pragma solidity ^0.4.20;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BankGuarantee is usingOraclize {
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
    HeapNode[] public heap;

    struct HeapNode {
        uint256 time; // key
        uint id; // value
    }

    function add(uint256 time, uint id) public {
        HeapNode memory node = HeapNode(time, id);
        heap.push(node);
        
        uint i = heap.length - 1;
        uint parent = (i - 1) / 2;
        
        while (i > 0 && heap[parent].time < heap[i].time) {
            HeapNode memory temp = heap[i];
            heap[i].time = heap[parent].time;
            heap[i].id = heap[parent].id;
            heap[parent].time = temp.time;
            heap[parent].id = temp.id;

            i = parent;
            parent = (i - 1) / 2;
        }
    }
    
  

    function getMax() public {
        
        heap[0].time = heap[heap.length - 1].time;
        heap[0].id = heap[heap.length - 1].id;
        delete heap[heap.length - 1];
        heap.length--;
        heapify(0);
    }
    
    function heapify(uint i) private {
        uint leftChild;
        uint rightChild;
        uint largestChild;

        while(true) {
            leftChild = (2 * i) + 1;
            rightChild = 2 * i + 2;
            largestChild = i;

            if (leftChild < heap.length && heap[leftChild].time > heap[largestChild].time) {
                largestChild = leftChild;
            }
            if (rightChild < heap.length && heap[rightChild].time > heap[largestChild].time) {
                largestChild = rightChild;
            }
            if (largestChild == i) {
                break;
            }

            HeapNode temp;
            temp.time = heap[i].time;
            temp.id = heap[i].id;
            
            heap[i].id = heap[largestChild].id;
            heap[i].time = heap[largestChild].time;
            heap[largestChild].time = temp.time;
            heap[largestChild].id = temp.id;
            i = largestChild;
        }
    }
    
    struct Pacts {
        uint    id;
        address beneficiary;
        address principal;
        uint256 money;
        uint256 date;
        uint256 time;
        bool    accept;
        bool    ended;
    }
    
    function createPactByPrincipal(address _beneficiary, uint256 _money, uint256 _time) public onlyWhitelistUser() returns (uint) {
        pacts[pact_id].principal = msg.sender;
        pacts[pact_id].beneficiary = _beneficiary;
        pacts[pact_id].money = _money;
        pacts[pact_id].date = now;
        pacts[pact_id].time = _time;
        pact_id++;
        return pact_id - 1;
    }
    
    function acceptContractByBeneficiary(address _principal, uint256 _money, uint256 _time, uint _pact_id) public onlyWhitelistUser() {
        if (( pacts[_pact_id].principal == _principal) && (pacts[_pact_id].beneficiary == msg.sender) && (pacts[_pact_id].money == _money) && (pacts[_pact_id].time == _time)) {
            pacts[_pact_id].accept = true;     
            add(_time, _pact_id);
        }
    }
    
    function getData(uint id) public view onlyBy(owner) returns(address, address, uint256,uint256, uint256, bool) {
        return (pacts[id].beneficiary, pacts[id].principal, pacts[id].money, pacts[id].date, pacts[id].time, pacts[id].ended);
    }
    
    function completeContract(uint id) public onlyBy(owner) {
        pacts[id].ended = true;
    }

    function() public payable {}

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

    function createTimer() public {
        
        if (oraclize_getPrice("URL") > address(this).balance ) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            if (pacts[pact_id - 1].time - pacts[pact_id - 1].date > 60 days) { // max period
                emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(60 days,"URL", ""); // check at max time
            } else {
                emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(pacts[pact_id].time - pacts[pact_id].date,"URL", ""); // check at time
            }
        }
    }
    //<<--TIMER
}

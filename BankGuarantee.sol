pragma solidity ^0.4.20;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BankGuarantee is usingOraclize {
    // should be guarantor's address
    // only owner has a access
    address public owner = msg.sender;
    // global variable for the identification of pacts
    uint private pact_id = 0;
    uint maxValue = 20000; // guarantees limit. in your prefer currency

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
    
    // whitelist check
    // only whitelisted user can get access
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
    
    // the main data structures for contract
    // think about change to T[]
    mapping (uint => Pacts) private pacts;
    HeapNode[] private heap;
    bool private lock = false;
    
    struct HeapNode {
        uint end_time; // key
        uint id; // value
    }
    
    struct Pacts {
        uint    id;
        address principal;
        address beneficiary; 
        uint    money;
        uint    start_time; // when pacts is start
        uint    end_time;   // when pacts is end
        bool    accept;
        bool    ended;
    }
    
    function createPactByPrincipal(address _beneficiary, uint _money, uint _end_time) public onlyWhitelistUser() returns (uint) {
        require(_money <= maxValue, "Cash limit exceeded.");
        uint id = pact_id++;
        pacts[id].principal = msg.sender;
        pacts[id].beneficiary = _beneficiary;
        pacts[id].money = _money;
        pacts[id].end_time = _end_time;
        return id;
    }
    
    function acceptContractByBeneficiary(address _principal, uint _money, uint _end_time, uint _pact_id) public onlyWhitelistUser() returns(bool) {
        if (lock == true) return false;
        require(_end_time > now, "end_time cannot be less than now. It is impossible.");
        lock = true;
        uint id = pact_id;
        if ((pacts[id].principal == _principal) && (pacts[id].beneficiary == msg.sender) && (pacts[id].money == _money) && (pacts[id].end_time == _end_time)) {
            pacts[id].accept = true;   
            pacts[id].start_time = now;
            add(_end_time - pacts[id].start_time, id);
        }
        lock = false;
        return true;
    }
    
    function getData(uint id) public view returns(address, address, uint, uint, uint, bool, bool) {
        return (pacts[id].beneficiary, pacts[id].principal, pacts[id].money, pacts[id].start_time, pacts[id].end_time, pacts[id].accept, pacts[id].ended);
    }
    
    function completeContract(uint id) public {
        pacts[id].ended = true;
    }

    // simple classical heap implementation
    // HEAP-->>
    function add(uint end_time, uint id) private {
        heap.push(HeapNode(end_time, id));
        
        uint i = heap.length - 1;
        uint parent = (i - 1) / 2;
        
        while (i > 0 && heap[parent].end_time < heap[i].end_time) {
            HeapNode memory temp = heap[i];
            heap[i] = heap[parent];
            heap[parent] = temp;
            i = parent;
            parent = (i - 1) / 2;
        }
    }
    
    function getMax() private returns (uint end_time, uint id) {
        HeapNode memory result = heap[0];
        heap[0] = heap[heap.length - 1];
        delete heap[heap.length - 1];
        heap.length--;
        
        heapify(0);
        return (result.end_time, result.id);
    }
    
    function heapify(uint i) private {
        uint leftChild;
        uint rightChild;
        uint largestChild;

        while(true) {
            leftChild = (2 * i) + 1;
            rightChild = 2 * i + 2;
            largestChild = i;

            if (leftChild < heap.length && heap[leftChild].end_time > heap[largestChild].end_time) {
                largestChild = leftChild;
            }
            if (rightChild < heap.length && heap[rightChild].end_time > heap[largestChild].end_time) {
                largestChild = rightChild;
            }
            if (largestChild == i) break;

            HeapNode memory temp = heap[i];
            
            heap[i] = heap[largestChild];
            heap[largestChild] = temp;
            i = largestChild;
        }
    }
    //<<--HEAP
    
    // it requires some eth for work
    // this is fallback function
    function() public payable {}

    //end_timeR-->>
    event LogConstructorInitiated(string nextStep); // for testing -->>
    event LogCallback(uint end_time);
    event LogNewOraclizeQuery(string description); // <<--for testing
    
    function __callback(bytes32 myid, string result) { 
        if (msg.sender != oraclize_cbAddress()) revert();
        //LogCallback(now); // test 
        if (pacts[pact_id - 1].end_time - now > 0) {
            createend_timer(); // again if remain end_time
        } else {
            completeContract(pact_id - 1);
        }   
    }

    function createend_timer() public returns(bool) {
        if (oraclize_getPrice("URL") > address(this).balance ) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            if (!lock) return false;
            lock = true;
            uint end_time;
            uint id;
            (end_time, id) = getMax();
            lock = false;
            
            if (end_time > 60 days) { // max period
                emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(60 days,"URL", ""); // check at max end_time
            } else {
                emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(end_time, "URL", ""); // check at end_time
            }
        }
    }
    //<<--end_timeR
}

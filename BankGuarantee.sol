// oraclize works with version which less than 0.4.20
pragma solidity ^0.4.20;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

// interface for work with Whitelist contract
contract Whitelist {
    // we need only one function for reading
    function checkAddress(address user) external view returns(bool);
}

contract BankGuarantee is usingOraclize {
    // TODO: put here address which you get when deploy Whitelist.sol
    address whitelist_address = 0x8c5F6A77b1602FdD19731bcbf1a62A0f1d267a5F;
    Whitelist whitelist = Whitelist(whitelist_address);
    
    function changeWhitelist(address _whitelist_address) public onlyBy(owner) {
        whitelist = Whitelist(_whitelist_address);
    }
    
    // should be guarantor's address
    // only owner has a access
    address public owner = msg.sender;
    // global variable for the identification of pacts
    uint private pact_id = 0;
    
    // TODO: CHANGE IT
    // guarantees limit. In your prefer currency
    uint maxValue = 20000;

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
    modifier onlyWhitelistUser(address candidate) {
        require (
            whitelist.checkAddress(candidate),
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
    mapping (uint => Pacts) private pacts;
    HeapNode[] private heap;
    bool private lock = false;
    
    struct HeapNode {
        uint end_time;  // key
        uint id;        // value
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
    
    function createPactByPrincipal(address _beneficiary, uint _money, uint _end_time) public onlyWhitelistUser(msg.sender) returns (uint) {
        require(_money <= maxValue, "Cash limit exceeded.");
        require(_end_time > now, "end_time cannot be less than now. It is impossible.");
        
        uint id = pact_id++;
        pacts[id].principal = msg.sender;
        pacts[id].beneficiary = _beneficiary;
        pacts[id].money = _money;
        pacts[id].end_time = _end_time;
        return id;
    }
    
    function acceptContractByBeneficiary(address _principal, uint _money, uint _end_time, uint _pact_id) public onlyWhitelistUser(msg.sender) returns(bool) {
        if (lock == true) return false;
        lock = true;
        
        if ((pacts[_pact_id].principal == _principal) && (pacts[_pact_id].beneficiary == msg.sender) && (pacts[_pact_id].money == _money) && (pacts[_pact_id].end_time == _end_time)) {
            pacts[_pact_id].accept = true;   
            pacts[_pact_id].start_time = now;
            add(_end_time - pacts[_pact_id].start_time, _pact_id);
        }
        lock = false;
        create_timer();
        return true;
    }
    
    function getData(uint id) public view returns(address, address, uint, uint, uint, bool, bool) {
        return (pacts[id].beneficiary, pacts[id].principal, pacts[id].money, pacts[id].start_time, pacts[id].end_time, pacts[id].accept, pacts[id].ended);
    }
    
    function completeContract(uint id) public onlyWhitelistUser(msg.sender) {
        // TODO
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

    //TIMER-->>
    uint timerCount = 0;
    
    event LogCallback(uint end_time);
    event LogNewOraclizeQuery(string description); // <<--for testing
    
    function __callback(bytes32 myid, string result) { 
        if (msg.sender != oraclize_cbAddress()) revert();
        while (lock) {
            // NOP
            // lock == true is not such a long time

        }
        
        lock = true;
        uint end_time;
        uint id;
        (end_time, id) = getMax();
        lock = false;
        
        if (pacts[id].end_time <= now) {
             pacts[id].ended = true;
        }
        timerCount--;
        if (timerCount == 0) create_timer();
    }

    function create_timer() public {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            timerCount++;
            while (lock) {
                // NOP
                // lock == true is not such a long time
            }
            lock = true;
            uint end_time = heap[0].end_time;
            lock = false;
            
            if (end_time - now > 60 days) { // max period
                emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(60 days,"URL", ""); // check at max end_time
            } else {
                emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
                oraclize_query(end_time, "URL", ""); // check at end_time
            }
        }
    }
    //<<--TIMER
}

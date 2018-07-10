var address = '0x049b922ae2019fde11d72d205cda8cba8deb9f24';

var ABI = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "users",
				"type": "address[]"
			}
		],
		"name": "addManyAddreses",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "user",
				"type": "address"
			}
		],
		"name": "checkAddress",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "user",
				"type": "address"
			}
		],
		"name": "deleteAddress",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "user",
				"type": "address"
			}
		],
		"name": "addOneAddress",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "Complete",
		"type": "event"
	}
];
var contractBank = web3.eth.contract(ABI);
var whitelist = contractBank.at(address);

$("#buttonAddOne").click(function() {
	whitelist.addOneAddress($("#UserAddressAdd").val(), function(error, result){
		if (!error) {
			$("#loader").show();
		}
	})
});

$("#buttonDeleteOne").click(function() {
        whitelist.deleteAddress($("#UserAddressDelete").val(), function(error, result){
		if (!error) {
			$("#loader").show();
		}
	})
});

$("#buttonCheck").click(function() {
	whitelist.checkAddress($("#UserAddressCheck").val(), function(error, result){
		if(!error) {
			$("#CheckResult").val(result ? 'true' : 'false');
                }
	})
});

var eventComplete= whitelist.Complete();
eventComplete.watch(function(error, result){
	if (!error) {
                $("#loader").hide();
	} else {
                $("#loader").hide();
	}
});
var address = '0x2cdceb043bf4307b2a5bdd1e2f73cf92bf5f3214';
var ABI = [
	{
		"constant": true,
		"inputs": [
			{
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "getData",
		"outputs": [
			{
				"name": "",
				"type": "address"
			},
			{
				"name": "",
				"type": "address"
			},
			{
				"name": "",
				"type": "uint256"
			},
			{
				"name": "",
				"type": "uint256"
			},
			{
				"name": "",
				"type": "uint256"
			},
			{
				"name": "",
				"type": "bool"
			},
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
				"name": "myid",
				"type": "bytes32"
			},
			{
				"name": "result",
				"type": "string"
			}
		],
		"name": "__callback",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "myid",
				"type": "bytes32"
			},
			{
				"name": "result",
				"type": "string"
			},
			{
				"name": "proof",
				"type": "bytes"
			}
		],
		"name": "__callback",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_principal",
				"type": "address"
			},
			{
				"name": "_money",
				"type": "uint256"
			},
			{
				"name": "_end_time",
				"type": "uint256"
			},
			{
				"name": "_pact_id",
				"type": "uint256"
			}
		],
		"name": "acceptContractByBeneficiary",
		"outputs": [
			{
				"name": "",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "completeContract",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"name": "",
				"type": "address"
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
				"name": "id",
				"type": "uint256"
			},
			{
				"name": "newMoney",
				"type": "uint256"
			}
		],
		"name": "changePact",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_beneficiary",
				"type": "address"
			},
			{
				"name": "_money",
				"type": "uint256"
			},
			{
				"name": "_end_time",
				"type": "uint256"
			}
		],
		"name": "createPactByPrincipal",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "id",
				"type": "uint256"
			},
			{
				"name": "payment",
				"type": "uint256"
			}
		],
		"name": "acceptPayment",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "minT",
				"type": "uint256"
			}
		],
		"name": "create_timer",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"payable": true,
		"stateMutability": "payable",
		"type": "fallback"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "Create",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "isAccept",
				"type": "bool"
			}
		],
		"name": "Accept",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "Complete",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "end_time",
				"type": "uint256"
			}
		],
		"name": "LogCallback",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "description",
				"type": "string"
			}
		],
		"name": "LogNewOraclizeQuery",
		"type": "event"
	}
];
	var contract = web3.eth.contract(ABI);
	var guarantor = contract.at(address);
	
$("#buttonCreate").click(function() {
	var sectime = new Date($("#timeCreate").val()).getTime() ;
    	sectime /= 1000;
      	guarantor.createPactByPrincipal($("#B_nameCreate").val(), $("#moneyCreate").val(), sectime, function(error, result){
		if (!error) {
			$("#loader").show();
		}
	})
});


$("#buttonAccept").click(function() {
	var sectime = new Date($("#timeAccept").val()).getTime() ;
    	sectime /= 1000;
       	guarantor.acceptContractByBeneficiary($("#P_nameAccept").val(), $("#moneyAccept").val(), sectime, $("#pactidAccept").val(), function(error, result){ 
		if (!error) {
			$("#loader").show();
		}
	})
});

$("#buttonComplete").click(function() {
	guarantor.completeContract($("#IDcomplete").val(), function(error, result){ 
		if (!error) {
			$("#loader").show();
		}
	})
});

$("#buttonChange").click(function() {
	guarantor.changePact($("#changeID").val(),  $("#NewMoney").val(), function(error, result){ 
		if (!error) {
			$("#loader").show();
		}
	})
});

$("#buttonAcceptPaid").click(function() {
	guarantor.acceptPayment($("#IDaccept").val(),  $("#moneyAcceptPaid").val(), function(error, result){ 
		if (!error) {
			$("#loader").show();
		}
	})
});

$("#buttonGet").click(function() {
	guarantor.getData($("#getdataid").val(),function(error,result){
		if(!error) {
			$("#Benefeciary").html(result[0]);
			$("#Principal").html(result[1]);
			$("#Money").html(result[2] + ' руб');
			$("#AcceptMoney").html(result[3] + ' руб');
			var newd = new Date(result[4] * 1000);
			var newDate = newd.getDate() + '/' + (newd.getMonth()+1) + '/' + newd.getFullYear();			
			$("#Time").html(newDate);
			$("#isAccepted").html(result[5] ? 'true' : 'false');	
			$("#isComplete").html(result[6] ? 'true' : 'false');	
		}
	})
});

var eventCreate = guarantor.Create();

eventCreate.watch(function(error, result){
	if (!error) {
            	$("#pactsid").val(result.args.id.toNumber());
                $("#loader").hide();
       	} else {
                $("#loader").hide();
	}
});

var eventAccept = guarantor.Accept();

eventAccept.watch(function(error, result){
	if (!error) {
           	$("#isAccept").val(result.args.isAccept);
            	$("#loader").hide();
	} else {
                $("#loader").hide();
	}
});

var eventComplete= guarantor.Complete();

eventComplete.watch(function(error, result){
	if (!error) {
                $("#loader").hide();
	} else {
		$("#loader").hide();
	}
});
pragma solidity ^0.4.12;

contract SmartPatreon { 

    //declaring variables
    bytes32 public name;
    uint public singleDonationAmount; 
    uint public monthlyDonationAmount;
    address public creator;
    uint contractNumber;
    uint monthlyCounter = 9; //we're starting on October, the 10th month, which is the 9th index in an 11 index array
    uint leapYearCounter = 1583020800;
    uint constant leapYearCycle = 126230400;//this number is 4 years plus a day, and it is reoccurring on a consistent basis
    uint contractBalance = this.balance;

    //accounting stuff, seed data
    uint[13] public ledger;
    
    uint constant allPatreonsEver = 0; // 10
    uint constant patreonsNow = 1;  // also 10 currently
    uint constant patreonsFinished = 2; // 0
    uint constant patreonsCancelled = 3; //0
    
    uint constant totalDonationsEver = 4; //this value is in months, so 120 for ten people/year
    uint constant monthlyDonationsAvailable = 5; //113
    uint constant totalDonationsWithdrawn = 6; //7
    uint constant totalDonationsCancelled = 7; //0 
    
    uint constant totalEtherEver = 8; // 10 lol
    uint constant totalEtherNow = 9;  // ~8.5 ETH
    uint constant totalEtherWithdrawn = 10; // ~1.5 ETH
    uint constant totalEtherCancelled = 11; //0
    
    uint constant monthlyDonation = 12; // 0.083, but do I need this constant? 

    //modifiers 
    modifier onlyPatreons 
        if (msg.sender == creator) 
            revert(); 
            _;
    }

    modifier onlyCreator { 
        if (msg.sender != creator) 
            revert(); 
            _; 
    }

    //events for front-end calls
    event LOG_SingleDonation(uint donationAmount, address donor);
    event LOG_Withdraw(uint emptyBalance);
    event LOG_creatorAddressAndSender(address factoryAddress, address creator);
    event LOG_ShowAllMonthlyDonationsOneUser(uint totalDonationStart, uint totalRemaining, uint monthsRemaining, uint paymentPerMonth, address donor);
    event LOG_FullLedger(uint allPatreonsEver, uint patreonsNow, uint patreonsFinished, uint patreonsCancelled, uint totalDonationsEver, uint monthlyDonationsAvailable, uint totalDonationsWithdrawn, uint totalDonationsCancelled, uint totalEtherEver, uint totalEtherNow, uint totalEtherWithdrawn, uint totalEtherCancelled, uint monthlyDonation);
    event LOG_ContractBalance(uint contractBalance);

    struct donationData {
        address donor;
        uint totalDonationStart;
        uint totalRemaining;
        uint monthsRemaining;
        uint paymentPerMonth;
    }

    donationData[] public donors;

    mapping (address => uint[]) public donationID; //one address could submit multiple yearly donations if they want. Would have to add donationID into here to differentiate donations from the same address
    
    mapping (address => donationData) public patreonDonations; //This could be useful for quick lookup of donations for cancellation purposes. Keep for now

    // constructor function
    function smartPatreon(bytes32 _name, uint _contractNumber) payable {
        contractNumber = _contractNumber;
        PatreonFactory pf = PatreonFactory(msg.sender); // need to create smart contract factory function
        name = _name;
        creator = pf.getOriginalCreator(contractNumber); //need to get the original creator's address (not the contract address) for setting their limits and approval withdrawals
        LOG_creatorAddressAndSender(msg.sender, creator);
    }

    function setOneTimeContribution(uint setAmountInWei) onlyCreator  returns(uint){
        singleDonationAmount = setAmountInWei;
        return singleDonationAmount;
    }

    function setMonthlyContribution(uint setMonthlyInWei) onlyCreator  returns(uint) {
        monthlyDonationAmount = setMonthlyInWei; //you can have the front end display it in ether, but it will be sent in wei and converted on the front end
        return monthlyDonationAmount;
    }

    function oneTimeContribution() payable onlyPatreons returns(uint){
        if (msg.value != singleDonationAmount) revert(); 
            //this.balance = this.balance + msg.value;
        
          //  msg.sender.send()       
        LOG_SingleDonation(this.balance, msg.sender);       
        return this.balance;
    }

    function monthlyContribution() {

    }


}
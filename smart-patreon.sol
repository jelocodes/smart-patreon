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
    modifier onlyPatreons {
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

    // Change so monthly contribution takes a single value, which just gets multiplied by 12, instead of using msg.value directly. For now they enter two values.

    //the only place where ledger has permanent things added to it
    function monthlyContribution(int _monthlyDonation) payable onlyPatreons returns(uint) {
        
        if (msg.value != monthlyDonationAmount) revert();
        
        donationData memory pd = patreonDonations[msg.sender];
        
        pd.donor = msg.sender;
        pd.totalDonationStart = msg.value;
        pd.totalRemaining = msg.value;
        pd.monthsRemaining = 12;
        pd.paymentPerMonth = _monthlyDonation;
        
        donors.push(pd);
        
        ledger[monthlyDonation] = _monthlyDonation; //right now 0.083. but it could be changed, if I let users pick months. but it gets more difficult. 
        
        ledger[allPatreonsEver] += 1;
        ledger[patreonsNow] += 1;
        ledger[totalDonationsEver] += 12;
        ledger[monthlyDonationsAvailable] += 12;
        ledger[totalEtherEver] += 1;
        ledger[totalEtherNow] += 1;

        
        LOG_ShowAllMonthlyDonations ( pd.totalDonationStart,  pd.totalRemaining,  pd.monthsRemaining,  pd.paymentPerMonth,  msg.sender);        

    }

    //best way to do monthly payments. either A) get the person to put 12 months up front, and then the ohter guy can withdraw every month, and they can cancel whenever they want :)

    //or they just allow for their account to be on a recurring billing contract mapping for everyone. then the owner can PING that part of the contract and I will go in and take money from the people

    //really what would be nice would be to have a function constructor for ethereum 

    //submit a year long contirubtion take the base time that it was sent out  from the block. add the average of 365/12 or something better ! (first day?)
    //have a counter that goes up. after one month is up, add that, and then allow the owner to accept that amount. and he can't take out more! only once per month
    //makes me feel this should be on the first day of the month. the user does a single donation, with a recurring one later
    //there is some some of mapping that shows how much each user has. that user can withdraw that much from the contract 
    //might be able to remove the yearly thing if we can get the incrementor working

    //would have to say creator withdrawfromContract to be unique. maybe best way to do this would be to make oneTimecontribution a direct donation to the guy.
    //and the contract only deal with monthly contribution 

    /*
     uint secondsInOneMonth31 = 2678400; // aug, oct dec, jan, mar, may, july
     uint secondsInOneMonth30 = 2592000; //sept, nov, april, june
     uint secondsInOneMonth28 = 2419200; // feb
     uint secondsInOneMonth29 = 2505600; // feb 29 2020
     //2678400
     
    // i am going to do on the first of every month for one year, because that makes sense to people 
    
    uint augustFirst2017 = 1501545600; //31
    uint septemberFirst2017 = 1504224000; //30
    uint octoberFirst2017 = 1506816000; //31
    uint novemberFirst2017 = 1509494400; //30
    uint decemberFirst2017 = 1512086400; //31
    uint januaryFirst2018 = 1514764800; //31
    uint februaryFirst2018 = 1517443200; //28-29
    uint marchFirst2018 = 1519862400; //31
    uint aprilFirst2018 = 1522540800; //30
    uint mayFirst2018 = 1525132800; //31
    uint juneFirst2018 = 1527811200; //30
    uint julyFirst2018 = 1530403200; //31
    
    if (now > augustFirst2017) {
        
    }
    
    */    
    
    //ledger here removes things so they can't ever get completed 
    //remember, the patreons TECHNICALLY already submitted their whole year. this function only allows them to claim back some of it 

    function patreonCancelMonthly() {
        
        //can easily call this one, because the address that calls it can only reference its own struct. 
        
    }
    
    
        //update the internal ledger's 5 accounts
    function bookKeeping(uint8 _from, uint8 _to, uint _amount) internal {
        ledger[_from] -= int(_amount);
        ledger[_to] += int(_amount);
    }
    
    function checkIfPatreonsAreDoneDonating () internal returns (uint _patreonsDone) {
        
        uint patreonsDone;
        
        for (uint x = 0; x<donors.length; x++) {
            donors[x].totalRemaining -= donors[x].paymentPerMonth;
            donors[x].monthsRemaining -= 1;
            
            if (donors[x].monthsRemaining == 0){
                patreonsDone++;
            }
        }
        
        return patreonsDone;
        
        
    }
    
    //ledger here has things moved from being completed
    function creatorWithdrawMonthly() onlyCreator { //right now people only contribute for a 12 month term. I GUESS the user 
        
        //march 31 2020 = 1583020800
        //march 31 20201 = 1614556800
        //march 31 2024 = 1709251200
        
        //july 1st 2017, to test one month withdrawl = 1498867200;
        
        uint dynamicFirstOfMonth = 1498867200; //starts on August 1st, 2017
        
        uint secondsInOneMonth31 = 2678400; // aug, oct dec, jan, mar, may, july
        uint secondsInOneMonth30 = 2592000; //sept, nov, april, june
        uint secondsInOneMonth28 = 2419200; // feb
        uint secondsInOneMonth29 = 2505600; // feb 29 2020
        

        if (now > dynamicFirstOfMonth) { //accoridng to this, if guy is two months behind, he can only withdraw one at a time. will need to do 2 transactions
            //math to withdraw all money
            
            uint amountToWithdraw = ledger[patreonsNow]*ledger[monthlyDonation];
            
            ledger[monthlyDonationsAvailable] -= ledger[patreonsNow]; //if there were 5 patreons, 5 monthly donations were withdrawn! so minus that
            ledger[totalDonationsWithdrawn] += ledger[patreonsNow]; 
            
            ledger[totalEtherNow] -= amountToWithdraw;
            ledger[totalEtherWithdrawn] += amountToWithdraw;

            uint patreonsCompleted = checkIfPatreonsAreDoneDonating();
            
            ledger[patreonsNow] -= patreonsCompleted;
            ledger[patreonsFinished] += patreonsCompleted;
            
            creator.transfer(amountToWithdraw);
            
            
            
            //change dynamicFirstOfMonth, with math. then increment 
            if (monthlyCounter == 7 || monthlyCounter ==  9 || monthlyCounter == 11 || monthlyCounter == 0 || monthlyCounter == 2 || monthlyCounter == 4 || monthlyCounter == 6){
                dynamicFirstOfMonth += secondsInOneMonth31;
                
                if (monthlyCounter == 11) {
                    monthlyCounter = 0;
                } else {
                    monthlyCounter++;
                }
                
                } else if (monthlyCounter == 8 || monthlyCounter == 10 || monthlyCounter == 3 || monthlyCounter == 5) {
                dynamicFirstOfMonth += secondsInOneMonth30;
                monthlyCounter++;
                } else {
                    if (now > leapYearCounter){
                        uint leapYearCycle = 126230400;//this number is 4 years plus a day, and it reoccuring on a consistent basis
                        dynamicFirstOfMonth = dynamicFirstOfMonth + secondsInOneMonth29;
                        leapYearCounter += leapYearCycle;
                        monthlyCounter++;
                    } else {
                        dynamicFirstOfMonth += secondsInOneMonth28;
                        monthlyCounter++;
                    }
                }
            }       
        
    }

}

contract PatreonFactory {
    bytes32[] names;
    address[] newContracts;
    address[] originalCreators;
    
    address factoryAddress = this;
    
    event LOG_NewContractAddress (address theNewcontract, address theContractCreator);

    function createContract (bytes32 name) returns(address, bytes32, uint, address) {
        uint contractNumber = newContracts.length;
        originalCreators.push(msg.sender);
        address newContract = new SmartPatreon(name, contractNumber);
        newContracts.push(newContract);
        names.push(name);
        LOG_NewContractAddress (newContract, msg.sender);
        return (newContract, name, contractNumber, msg.sender);
    } 

    function getName(uint i) constant returns(bytes32 contractName) {
        return names[i];
    }
    function getcontractAddressAtIndex(uint i) constant returns(address contractAddress) {
        return newContracts[i];
    }
    
    function getOriginalCreator(uint i) constant returns (address originalCreator) {
        return originalCreators[i];
    }
}


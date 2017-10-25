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

}
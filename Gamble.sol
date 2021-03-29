pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";

//SPDX-License-Identifier: UNLICENSED

contract Gamble {
    
    using SafeERC20 for IERC20;
    
    struct Bet {
        uint blockNumber;
        uint amount;
        uint choice;
    }
    
    mapping (address => Bet) public bets;
    
    uint public constant PERCENT_FEE = 5;
    uint public constant MAX_BET_AMOUNT_PERCENT = 10;
    uint public BANK_ROLL;
    
    address public owner;
    IERC20 public ziotAddress;
    
    constructor() {
        owner = msg.sender;
        ziotAddress = IERC20(0x728912fe2AD8f2962E164Bfa21Fd3B231e3eeB75);
        BANK_ROLL = 0;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // admin function
    function withdrawFunds(uint _amount, address _withdrawAddress) external onlyOwner returns(bool) {
        ziotAddress.safeTransferFrom(address(this), _withdrawAddress, _amount);
        return true;
    }
    
    // admin function
    function initializeBankroll() public onlyOwner {
        BANK_ROLL = ziotAddress.balanceOf(address(this));
    }
    
    function gamble(uint256 _amount, uint _userChoice) external returns(bool) {
        uint maxBetAmount = (BANK_ROLL * MAX_BET_AMOUNT_PERCENT)/100;
        require(_amount > 0, "Cannot bet 0 ziots.");
        require(bets[msg.sender].blockNumber == 0, "Bet already pending.");
        require(_amount <= maxBetAmount, "Bet too large. Bet max 10% of balance.");
        ziotAddress.safeTransferFrom(msg.sender, address(this), _amount);
        bets[msg.sender].blockNumber = block.number;
        bets[msg.sender].choice = _userChoice;
        bets[msg.sender].amount = _amount;
        BANK_ROLL += _amount;
        return true;
    }
    
    function getWinner() external returns(string memory) {
        require(bets[msg.sender].blockNumber != 0, "No bets pending.");
        require(block.number > bets[msg.sender].blockNumber + 5, "Not enough blocks have passed.");
        if((uint256(blockhash(bets[msg.sender].blockNumber  + 5)) % 2) == bets[msg.sender].choice){
            uint amountSendBack = ((bets[msg.sender].amount*(100-PERCENT_FEE))/100)*2;
            ziotAddress.safeTransfer(msg.sender, amountSendBack);
            BANK_ROLL -= amountSendBack;
            bets[msg.sender].blockNumber = 0;
            bets[msg.sender].choice = 0;
            bets[msg.sender].amount = 0;
            return "u won u lucky cunt";
        } else {
            bets[msg.sender].blockNumber = 0;
            bets[msg.sender].choice = 0;
            bets[msg.sender].amount = 0;
            return "u lost u dumb loser";
        }
        
    }
    
}

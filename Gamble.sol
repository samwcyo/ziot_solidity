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
    
    uint public MAX_BET_AMOUNT_PERCENT;
    uint public PERCENT_FEE;
    uint public BANK_ROLL;
    bool public IS_OPEN;
    
    address public owner;
    IERC20 public ziotAddress;
    
    function updateSettings(uint _maxBetAmountPercent, uint _percentFee, bool _isOpen) public onlyOwner returns(bool) {
        require(_maxBetAmountPercent > 1 && _maxBetAmountPercent < 100 && _percentFee > 1 && _percentFee < 100);
        MAX_BET_AMOUNT_PERCENT = _maxBetAmountPercent;
        PERCENT_FEE = _percentFee;
        IS_OPEN = _isOpen;
        return true;
    }
    
    constructor() {
        owner = msg.sender;
        ziotAddress = IERC20(0xfB22cED41B1267dA411F68c879f4Defd0bD4796a);
        MAX_BET_AMOUNT_PERCENT = 25;
        PERCENT_FEE = 10;
        BANK_ROLL = 0;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function withdrawFunds(uint _amount, address _withdrawAddress) external onlyOwner returns(bool) {
        ziotAddress.safeTransfer(_withdrawAddress, _amount);
        BANK_ROLL -= _amount;
        return true;
    }
    
    function initializeBankroll() public onlyOwner {
        BANK_ROLL = ziotAddress.balanceOf(address(this));
        IS_OPEN = true;
    }
    
    function gamble(uint256 _amount, uint _userChoice) external returns(bool) {
        uint maxBetAmount = (BANK_ROLL * MAX_BET_AMOUNT_PERCENT)/100;
        require(_amount > 0);
        require(_userChoice == 0 || _userChoice == 1);
        require(IS_OPEN == true);
        require(bets[msg.sender].blockNumber == 0);
        require(_amount <= maxBetAmount);
        ziotAddress.safeTransferFrom(msg.sender, address(this), _amount);
        bets[msg.sender].blockNumber = block.number;
        bets[msg.sender].choice = _userChoice;
        bets[msg.sender].amount = _amount;
        BANK_ROLL += _amount;
        return true;
    }
    
    function getWinner() external returns(bool) {
        require(bets[msg.sender].blockNumber != 0, "No bets pending.");
        require(IS_OPEN == true);
        require(block.number > bets[msg.sender].blockNumber + 5, "Not enough blocks have passed.");
        if(block.number < bets[msg.sender].blockNumber + 250){
            if((uint256(blockhash(bets[msg.sender].blockNumber  + 5)) % 2) == bets[msg.sender].choice){
                uint amountSendBack = ((bets[msg.sender].amount*(100-PERCENT_FEE))/100)*2;
                ziotAddress.safeTransfer(msg.sender, amountSendBack);
                BANK_ROLL -= amountSendBack;
                bets[msg.sender].blockNumber = 0;
                bets[msg.sender].choice = 0;
                bets[msg.sender].amount = 0;
                return true;
            } else {
                bets[msg.sender].blockNumber = 0;
                bets[msg.sender].choice = 0;
                bets[msg.sender].amount = 0;
                return false;
            }
        } else {
            bets[msg.sender].blockNumber = 0;
            bets[msg.sender].choice = 0;
            bets[msg.sender].amount = 0;
            return false;
        }
    }
    
}

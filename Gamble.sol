
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";

//SPDX-License-Identifier: UNLICENSED

contract Gamble {
    
    mapping (address => uint) public userBlockNumber; 
    mapping (address => uint) public userChoice;
    mapping (address => uint) public userBetAmount;

    using SafeERC20 for IERC20;
    
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
        require(userBlockNumber[msg.sender] == 0, "Bet already pending.");
        require(_amount <= maxBetAmount, "Bet too large. Bet max 10% of balance.");
        ziotAddress.safeTransferFrom(msg.sender, address(this), _amount);
        userBlockNumber[msg.sender] = block.number;
        userChoice[msg.sender] = _userChoice;
        userBetAmount[msg.sender] = _amount;
        BANK_ROLL += _amount;
        return true;
    }
    
    function getWinner() external returns(string memory) {
        require(userBlockNumber[msg.sender] != 0, "No bets pending.");
        require(block.number > userBlockNumber[msg.sender] + 5, "Not enough blocks have passed.");
        if((uint256(blockhash(userBlockNumber[msg.sender]  + 5)) % 2) == userChoice[msg.sender]){
            uint amountSendBack = ((userBetAmount[msg.sender]*(100-PERCENT_FEE))/100)*2;
            ziotAddress.safeTransfer(msg.sender, amountSendBack);
            BANK_ROLL -= amountSendBack;
            userBlockNumber[msg.sender] = 0;
            userChoice[msg.sender] = 0;
            userBetAmount[msg.sender] = 0;
            return "won, very sad";
        } else {
            userBlockNumber[msg.sender] = 0;
            userChoice[msg.sender] = 0;
            userBetAmount[msg.sender] = 0;
            return "lost, very sad";
        }
        
    }
    
}

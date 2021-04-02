//SPDX-License-Identifier: propietary

pragma solidity ^0.8.0;

contract Game {
    
    uint nonce;
    uint sodaIndex;
    
    constructor() {
        sodaIndex = 0;
        nonce = block.timestamp;
        purchaseSodapop(1, "heck");
        toggleCarbonate(0);
    }
    
    struct Sodapop {
        address owner;
        uint class;
        uint carbonation;
        uint sodaAmount;
        bool isCarbonating;
    }
    
    struct Owner {
        string name;
        uint[] owns;
    }
    
    mapping (uint => Sodapop) public sodapops;
    mapping (address => Owner) public owners;
 
    function purchaseSodapop(uint _class, string memory _name) public returns (bool){
        sodapops[sodaIndex].owner = msg.sender;
        sodapops[sodaIndex].class = _class;
        sodapops[sodaIndex].carbonation = generateRandomNumber(100);
        sodapops[sodaIndex].sodaAmount = 100;
        owners[msg.sender].name = _name;
        owners[msg.sender].owns.push(sodaIndex);
        sodaIndex++;
        return true;
    }
    
    function toggleCarbonate(uint _sodaId) public returns (bool){
        require(checkIfOwnedSodapop(msg.sender, _sodaId));
        sodapops[_sodaId].isCarbonating = !sodapops[_sodaId].isCarbonating;
        return true;
    }
    
    function sodaPvp(uint _victimId, uint _attackerId) public returns (uint){
        require(checkIfOwnedSodapop(msg.sender, _attackerId));
        require(!checkIfOwnedSodapop(msg.sender, _victimId));
        require(sodapops[_attackerId].isCarbonating == true && sodapops[_victimId].isCarbonating == true);
        uint attackerDamage = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % sodapops[_attackerId].carbonation; nonce++;
        uint victimDamage = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % sodapops[_victimId].carbonation; nonce++;
        if(attackerDamage > victimDamage){
            return 0;
        } else {
            if(attackerDamage == victimDamage){
                return 2;
            }
            return 1;
        }
    }
    
    function getOwnedSodapops(uint _id) public view returns(uint){
        return owners[msg.sender].owns[_id];
    }
    
    function checkIfOwnedSodapop(address _owner, uint _id) public view returns(bool isOwned){
        for (uint i=0; i<owners[_owner].owns.length; i++){
            if(owners[_owner].owns[i] == _id){
                return true;
            }
        }
    }
 
    function generateRandomNumber(uint _max) public returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % _max;
        nonce++;
        return randomnumber;
    }
 
}

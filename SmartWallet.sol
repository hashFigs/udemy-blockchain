//SPDX-License-Identifier: MIT

/*
1) OK -The wallet has one owner
2) OK- The wallet should be able to receive funds, no matter what
3) It is possible for the owner to spend funds on any kind of address, no matter if its a so-called Externally Owned Account (EOA - with a private key), or a Contract Address.
4) It should be possible to allow certain people to spend up to a certain amount of funds.
5) It should be possible to set the owner to a different address by a minimum of 3 out of 5 guardians, in case funds are lost.

*/

pragma solidity 0.8.15;

contract SmartWallet {

    address payable owner;
    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowedToSend;

    mapping(address => bool) public guardians; 
    address payable nextOwner;
    uint guardianResetCount;
    uint public constant minConfirmationsForNewOwner = 3;



    constructor() {
        owner = payable(msg.sender);
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    } 

    function setGuardian(address _guardian, bool _isGuardian){
        
        require( msg.sender == owner, "You are not the owner, NOT ALLOWED  aborting");
        
        guardians[_guardian] = _isGuardian;

    }
    

    function proposeNewOwner(address payable _newOwner){
        require( guardians[msg.sender], "You are not a owner, NOT ALLOWED  aborting");

    }


    function setAllowance(address _for, uint _amount) public {
        require( msg.sender == owner, "You are not the owner, NOT ALLOWED  aborting");
        
        allowance[_for] = _ammount;

        if (_amount > 0) {
            isAllowedToSend[_for] = true;
        }else{
            isAllowedToSend[_for] = false;
        }
    } 
    function payExternal(address payable _to, uint _amount, bytes memory _payload) public returns (bytes memory){
        
        if (msg.sender !=owner ){
            require(isAllowedToSend[msg.sender], "You are not the owner, aborting");
            require(allowance[msg.sender] > _amount, "You are trying to send too much founds, aborting");

            allowance[msg.sender] -= _amount;
        } 
        
        (bool success, bytes memory returnData) = _to.call{value: _amount}(_payload);
        require(success, "Transaction failed, aborting");
        return returnData;
    }

    receive() external payable {}
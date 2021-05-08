pragma solidity ^0.8.0;

import 'node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'node_modules/openzeppelin-solidity/contracts/access/Ownable.sol';

contract MyToken is ERC20, Ownable {
 constructor() ERC20("KepCoin", "KEP"){
    _mint(msg.sender, 100000000000000000000);
  }
   function mint(address to, uint256 value) public onlyOwner returns (bool){
  _mint(to, value); 
 }
 function burn(address to, uint256 value) public onlyOwner returns (bool){
  _burn(to, value); 
 }

}
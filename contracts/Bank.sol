pragma solidity ^0.8.0;

import "./MyToken.sol";
import "node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";


contract Bank{
    using SafeMath for uint;
    using SafeMath for uint256;

    struct DepositType{
        uint256 depositTime;
        uint256 percentage;
    }
    struct DepositInfo{
        uint256 endTime;
        uint256 sum;
        uint256 percentage;
    }
    

    DepositType[] d;

    MyToken token;
    mapping (address => DepositInfo[]) private deposits;

    uint256 creditPercentage = 1000;

    function openDeposit(uint256 amount, uint256 depositTypeId) public payable{
        d.push(DepositType(15778463, 300));
        d.push(DepositType(31556926, 600));
        DepositType[] storage depositType = d;
        require(depositType[depositTypeId].percentage > 0, "Can`t find deposit with this type id");
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender].push(DepositInfo(block.timestamp.add(depositType[depositTypeId].depositTime),
         amount, depositType[depositTypeId].percentage));
    }

    function withdrawDeposit(uint256 depositId) public{
        require(deposits[msg.sender][depositId].endTime > block.timestamp, "You can`t withdraw your deposit");
        token.transfer(msg.sender,
         deposits[msg.sender][depositId].sum.
         mul(deposits[msg.sender][depositId].percentage.div(10000)));
        delete deposits[msg.sender][depositId];
    }

    function getMyBalance() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

}
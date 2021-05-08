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
        uint256 startTime;
        uint256 endTime;
        uint256 sum;
        DepositType depositType;
    }
    
    DepositType[2] depositType = [DepositType(15778463, 300), DepositType(31556926, 600)];
    MyToken token;
    mapping (address => DepositInfo[]) private deposits;

    function openDeposit(uint256 amount, uint256 depositTypeId) public payable{
        if(depositType[depositTypeId].percentage > 0){
            token.transfer(msg.sender, amount);
            deposits[msg.sender].push(DepositInfo(block.timestamp, block.timestamp.add(depositType[depositTypeId].depositTime), amount, depositType[depositTypeId]));
        }
    }

    function withdrawDeposit(uint256 depositId) public payable{
        if(deposits[msg.sender][depositId].sum > 0 && deposits[msg.sender][depositId].endTime > block.timestamp){
            token.transfer(msg.sender, deposits[msg.sender][depositId].sum.mul(deposits[msg.sender][depositId].depositType.percentage.div(10000)));
        }
    }
}
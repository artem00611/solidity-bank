pragma solidity ^0.8.0;

import "./MyToken.sol";
import "node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import 'node_modules/openzeppelin-solidity/contracts/access/Ownable.sol';

contract Bank is Ownable{
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
    
    struct CreditInfo{
        uint256 startTime;
        uint256 amount;
        uint256 percentage;
    }
    DepositType[] d;

    MyToken token;
    uint256 monthSeconds = 86400;
    uint256 ammountCreditPay;
    mapping (address => DepositInfo[]) private deposits;
    mapping (address => CreditInfo) private credits;
    mapping (address => bool) private whitelist;
    uint256 creditPercentage;

    constructor(){
        d.push(DepositType(15778463, 300));
        d.push(DepositType(31556926, 600));
        creditPercentage = 1000;
    }

    function addNewDepositType(uint256 time, uint256 percentage) public onlyOwner{
        d.push(DepositType(time, percentage));
    }

    function changeCreditPercentage(uint256 changedPercentage) public onlyOwner{
        creditPercentage = changedPercentage;
    }

    function openDeposit(uint256 amount, uint256 depositTypeId) public payable{
        DepositType[] storage depositType = d;
        require(depositType[depositTypeId].percentage > 0, "Can`t find deposit with this type id");
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender].push(DepositInfo(block.timestamp.add(depositType[depositTypeId].depositTime),
         amount, depositType[depositTypeId].percentage));
    }

    function withdrawDeposit(uint256 depositId) public{
        require(deposits[msg.sender][depositId].endTime > block.timestamp, "You can`t withdraw your deposit");
        token.transfer(msg.sender,
         deposits[msg.sender][depositId].sum
         .mul(deposits[msg.sender][depositId].percentage
         .div(10000)));
        delete deposits[msg.sender][depositId];
    }

    function getCredit(uint256 ammountCredit) public{
        require(whitelist[msg.sender], "You don`t have permission to take credit!");
        require(credits[msg.sender].amount > 0, "You already have credit!");
        credits[msg.sender] = (CreditInfo(block.timestamp, ammountCredit, creditPercentage));
        token.transfer(msg.sender, ammountCredit);
    }

    function changeAccountCreditPermission(address account, bool creditPermission) public onlyOwner{
        whitelist[account] = creditPermission;
    }

    function payOffCredit() public payable{
        require(credits[msg.sender].amount > 0, "You don`t have credit!");
        ammountCreditPay = (credits[msg.sender].amount
        .mul(creditPercentage
        .mul((block.timestamp
        .sub(credits[msg.sender].startTime))
        .div(monthSeconds))
        .div(10000)))
        .add(credits[msg.sender].amount);
        require(ammountCreditPay > token.balanceOf(msg.sender), "You don`t have enough KepCoins to pay off credit!");
        token.transferFrom(msg.sender, address(this), ammountCreditPay);
        delete credits[msg.sender];
    }
}
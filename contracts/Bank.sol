pragma solidity ^0.8.0;

import "./MyToken.sol";
import "node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import 'node_modules/openzeppelin-solidity/contracts/access/Ownable.sol';

contract Bank is Ownable{
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

    DepositType[] depositType;

    MyToken token;
    mapping (address => DepositInfo[]) private deposits;
    mapping (address => CreditInfo) private credits;
    mapping (address => bool) private whitelist;
    uint256 creditPercentage;
    uint256 accuraccy = 1000000000000000000;

    constructor(){
        depositType.push(DepositType(15778463, 3 * accuraccy));
        depositType.push(DepositType(31556926, 6 * accuraccy));
        creditPercentage = 10 * accuraccy;
    }

    function getTokensFromContract(uint256 amount) public onlyOwner{
        token.transfer(msg.sender, amount);
    }

    function addNewDepositType(uint256 time, uint256 percentage) public onlyOwner{
        depositType.push(DepositType(time, percentage));
    }

    function deleteDepositType(uint256 depositTypeId) public onlyOwner{
        delete depositType[depositTypeId];
        token.decimals();
    }

    function changeCreditPercentage(uint256 changedPercentage) public onlyOwner{
        creditPercentage = changedPercentage;
    }

    function openDeposit(uint256 amount, uint256 depositTypeId) public{
        require(depositType[depositTypeId].percentage > 0, "Can`t find deposit with this type id");
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender].push(DepositInfo(block.timestamp.add(depositType[depositTypeId].depositTime), amount, depositType[depositTypeId].percentage));
    }

    function withdrawDeposit(uint256 depositId) public{
        require(deposits[msg.sender][depositId].endTime > block.timestamp, "You can`t withdraw your deposit");
        uint256 depositAmmount = deposits[msg.sender][depositId].sum
         .mul(deposits[msg.sender][depositId].percentage
         .div(accuraccy));
        token.transfer(msg.sender, depositAmmount);
        delete deposits[msg.sender][depositId];
    }

    function getCredit(uint256 amountCredit) public{
        require(whitelist[msg.sender], "You don`t have permission to take credit!");
        require(credits[msg.sender].amount > 0, "You already have credit!");
        require(amountCredit > 0, "You can`t get credit equal to zero!");
        credits[msg.sender] = (CreditInfo(block.timestamp, amountCredit, creditPercentage));
        token.transfer(msg.sender, amountCredit);
    }

    function changeAccountCreditPermission(address account, bool creditPermission) public onlyOwner{
        whitelist[account] = creditPermission;
    }

    function payOffCredit() public{
        uint256 amountCreditPay;
        uint256 monthSeconds = 86400;
        require(credits[msg.sender].amount > 0, "You don`t have credit!");

        amountCreditPay = credits[msg.sender].amount
        .add((credits[msg.sender].amount
        .mul(creditPercentage)
        .div(accuraccy))
        .mul((block.timestamp - credits[msg.sender].startTime)
        .mul(accuraccy))
        .div(monthSeconds))
        .div(accuraccy);
        require(amountCreditPay > token.balanceOf(msg.sender), "You don`t have enough KepCoins to pay off credit!");
        token.transferFrom(msg.sender, address(this), amountCreditPay);
        delete credits[msg.sender];
    }
}
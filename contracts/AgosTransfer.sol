// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IGToken {
	function transferFrom(
		address from,
		address to,
		uint256 amount
	) external returns (bool);
}

contract AgosTransfer is Ownable {
	address public spending;
	address public taxReceiver;
	uint96 public withdrawTax; //1% = 100
	uint96 public depositTax;
	IGToken public agosContract;

	constructor(
		address _agosContract,
		address _spendingAddress,
		address _taxReceiverAddress,
		uint96 _withdrawTax,
		uint96 _depositTax
	) {
		agosContract = IGToken(_agosContract);
		spending = _spendingAddress;
		taxReceiver = _taxReceiverAddress;
		withdrawTax = _withdrawTax;
		depositTax = _depositTax;
	}

	function setSpending(address newSpendingAddress) external onlyOwner {
		spending = newSpendingAddress;
	}

	function setTaxReceiver(address newTaxReceiver) external onlyOwner {
		taxReceiver = newTaxReceiver;
	}

	function setWithdrawTax(uint96 newTax) external onlyOwner {
		require(newTax <= 1000, "max is 1000");
		withdrawTax = newTax;
	}

	function setDepositTax(uint96 newTax) external onlyOwner {
		require(newTax <= 1000, "max is 1000");
		depositTax = newTax;
	}

	function safeTransferAGOS(address to, uint256 value) internal {
		bool success = agosContract.transferFrom(msg.sender, to, value);
		require(success, "AGOS transfer failed");
	}

	event Deposit(address from, uint256 value);

	function depositAGOS(uint256 amount) public payable {
		require(amount > 0, "value must be greater than 0");
		uint256 withoutFeeAmount = _depositTaxPayment(amount);
		safeTransferAGOS(spending, withoutFeeAmount);
		emit Deposit(msg.sender, withoutFeeAmount);
	}

	event Withdraw(address receiver, uint256 value);

	function withdrawAGOS(address receiver, uint256 amount) public payable {
		require(amount > 0, "value must be greater than 0");
		uint256 withoutFeeAmount = _withdrawTaxPayment(amount);
		safeTransferAGOS(receiver, withoutFeeAmount);
		emit Withdraw(receiver, withoutFeeAmount);
	}

	function _depositTaxPayment(uint256 _value) internal returns (uint256) {
		uint256 feeAmount = (_value * depositTax) / 10000;
		safeTransferAGOS(taxReceiver, feeAmount);
		uint256 withoutFeeAmount = _value - feeAmount;
		return (withoutFeeAmount);
	}

	function _withdrawTaxPayment(uint256 _value) internal returns (uint256) {
		uint256 feeAmount = (_value * withdrawTax) / 10000;
		safeTransferAGOS(taxReceiver, feeAmount);
		uint256 withoutFeeAmount = _value - feeAmount;
		return (withoutFeeAmount);
	}
}

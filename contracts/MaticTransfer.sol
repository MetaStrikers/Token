// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MaticTransfer is Ownable {
	address public spending;
	address public taxReceiver;
	uint96 public withdrawTax; //1% = 100
	uint96 public depositTax;

	constructor(
		address _spendingAddress,
		address _taxReceiverAddress,
		uint96 _withdrawTax,
		uint96 _depositTax
	) {
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

	function safeTransferETH(address to, uint256 value) internal {
		(bool success, ) = to.call{value: value}(new bytes(0));
		require(success, "ETH transfer failed");
	}

	event Deposit(address from, uint256 value);

	function depositETH() public payable {
		require(msg.value > 0, "value must be greater than 0");
		uint256 withoutFeeAmount = _depositTaxPayment(msg.value);
		safeTransferETH(spending, withoutFeeAmount);
		emit Deposit(msg.sender, withoutFeeAmount);
	}

	event Withdraw(address receiver, uint256 value);

	function withdrawETH(address receiver) public payable {
		require(msg.value > 0, "value must be greater than 0");
		uint256 withoutFeeAmount = _withdrawTaxPayment(msg.value);
		safeTransferETH(receiver, withoutFeeAmount);
		emit Withdraw(receiver, withoutFeeAmount);
	}

	function _depositTaxPayment(uint256 _value) internal returns (uint256) {
		uint256 feeAmount = (_value * depositTax) / 10000;
		safeTransferETH(taxReceiver, feeAmount);
		uint256 withoutFeeAmount = _value - feeAmount;
		return (withoutFeeAmount);
	}

	function _withdrawTaxPayment(uint256 _value) internal returns (uint256) {
		uint256 feeAmount = (_value * withdrawTax) / 10000;
		safeTransferETH(taxReceiver, feeAmount);
		uint256 withoutFeeAmount = _value - feeAmount;
		return (withoutFeeAmount);
	}
}
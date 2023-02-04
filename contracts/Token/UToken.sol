// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// Learn more about the ERC20 implementation
// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/erc20
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract UToken is ERC20, Ownable, AccessControl {
	uint96 public transferFee;
	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	mapping(address => bool) public taxExemptedSenders; // 　If from address is true, the tax is exempt.
	mapping(address => bool) public taxExemptedReceivers; // If to address is true, the tax is exempt.

	constructor(
		uint256 initialSupplyToOwner,
		uint96 _transferFee,
		string memory name,
		string memory symbol
	) ERC20(name, symbol) {
		ERC20._mint(msg.sender, initialSupplyToOwner);
		transferFee = _transferFee; // 100 = 1%
		taxExemptedSenders[msg.sender] = true;
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_setupRole(MINTER_ROLE, msg.sender);
	}

	function setTransferFee(uint96 fee) public onlyOwner {
		transferFee = fee;
	}

	function setExemptedSenders(
		address exemptedSenderAddress,
		bool dutyFee
	) public onlyOwner {
		taxExemptedSenders[exemptedSenderAddress] = dutyFee;
	}

	function setExemptedReceivers(
		address exemptedReceiversAddress,
		bool dutyFee
	) public onlyOwner {
		taxExemptedReceivers[exemptedReceiversAddress] = dutyFee;
	}

	function _transfer(
		address _sender,
		address _recipient,
		uint256 _amount
	) internal override {
		if (taxExemptedSenders[_sender] || taxExemptedReceivers[_recipient]) {
			super._transfer(_sender, _recipient, _amount);
		} else {
			uint256 amoutWithoutFee = _taxPayment(_sender, _amount);
			super._transfer(_sender, _recipient, amoutWithoutFee);
		}
	}

	function _taxPayment(
		address _sender,
		uint256 _amount
	) internal returns (uint256) {
		uint256 feeAmount = (_amount * transferFee) / 10000;
		super._transfer(_sender, owner(), feeAmount);
		_amount -= feeAmount;
		return _amount;
	}

	function mintTo(
		address receiver,
		uint256 supply
	) public onlyRole(MINTER_ROLE) {
		_mint(receiver, supply);
	}

	function burn(uint256 amount) public {
		_burn(msg.sender, amount);
	}
}

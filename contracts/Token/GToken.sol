// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// Learn more about the ERC20 implementation
// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/erc20
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract GToken is Ownable, ERC20Capped {
    uint96 public transferFee; // 100 = 1%
    uint public maxFee = 1000;

    mapping(address => bool) public taxExemptedSenders; // 　If from address is true, the tax is exempt.
    mapping(address => bool) public taxExemptedReceivers; // If to address is true, the tax is exempt.

    constructor(
        address to,
        uint256 initialSupply,
        uint96 _transferFee,
		string memory name,
		string memory symbol
    ) ERC20(name, symbol) ERC20Capped(initialSupply) {
        _mint(to, initialSupply);
        transferFee = _transferFee;
        taxExemptedSenders[msg.sender] = true;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function setTransferFee(uint96 fee) public onlyOwner {
        require(fee <= maxFee, "fee is over the upper limit");
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PeaceYieldEscrow
 * @dev Gestionează distribuția de dividende ("Peace-Yield") bazată pe starea de pace verificată prin oracole.
 */
contract PeaceYieldEscrow {
    address public owner;
    bool public isPeaceActive = true;
    mapping(address => uint256) public tokenBalances;

    event PeaceStatusChanged(bool status);
    event DividendsDistributed(address indexed holder, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Doar administratorul poate apela");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Oracolul de securitate regională actualizează starea păcii
    function setPeaceStatus(bool _status) external onlyOwner {
        isPeaceActive = _status;
        emit PeaceStatusChanged(_status);
    }

    // Distribuirea randamentelor către investitori instituționali (bănci / RWA)
    function claimYield(address holder, uint256 amount) external onlyOwner {
        require(isPeaceActive, "CRITICAL: Platile sunt suspendate din cauza conflictului regional!");
        require(address(this).balance >= amount, "Fonduri insuficiente in contractul escrow");
        
        (bool success, ) = holder.call{value: amount}("");
        require(success, "Transferul a esuat");
        
        emit DividendsDistributed(holder, amount);
    }

    receive() external payable {}
}

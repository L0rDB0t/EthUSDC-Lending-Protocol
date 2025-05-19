// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

contract OracleMock {
    uint256 public ethPrice = 2000 * 1e8; // 2000 USD (8 decimales)

    function setPrice(uint256 newPrice) external {
        ethPrice = newPrice;
    }
}
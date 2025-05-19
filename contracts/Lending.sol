// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Interfaz mínima para el contrato de oráculo
interface IOracle {
    function ethPrice() external view returns (uint256);
}

contract LendingProtocol {
    IERC20 public immutable usdc;
    IOracle public immutable oracle;
    uint256 public constant MIN_COLLATERAL_RATIO = 150; // 150%

    struct Loan {
        uint256 collateralAmount;
        uint256 borrowedAmount;
    }

    mapping(address => Loan) public loans;

    constructor(address _usdc, address _oracle) {
        usdc = IERC20(_usdc);
        oracle = IOracle(_oracle);
    }

    function depositCollateralAndBorrow(uint256 collateralAmount, uint256 borrowAmount) external payable {
        require(msg.value == collateralAmount, "ETH mismatch");
        require((borrowAmount * 100) / (msg.value * getEthPrice()) <= MIN_COLLATERAL_RATIO, "Collateral ratio too low");
        
        loans[msg.sender] = Loan(msg.value, borrowAmount);
        require(usdc.transfer(msg.sender, borrowAmount), "USDC transfer failed");
    }

    function liquidate(address user) external {
        Loan memory loan = loans[user];
        uint256 collateralValue = loan.collateralAmount * getEthPrice();
        require((loan.borrowedAmount * 100) / collateralValue > MIN_COLLATERAL_RATIO, "Cannot liquidate");

        uint256 reward = (loan.collateralAmount * 10) / 100; // 10% de recompensa
        loans[user].collateralAmount = 0; // Primero actualiza el estado
        payable(msg.sender).transfer(reward); // Después transfiere
    }

    function getEthPrice() public view returns (uint256) {
        return oracle.ethPrice();
    }
}
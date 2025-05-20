// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

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
        uint256 collateralAmount; // en wei (ETH)
        uint256 borrowedAmount;   // en USDC (6 decimales)
    }

    mapping(address => Loan) public loans;

    constructor(address _usdc, address _oracle) {
        usdc = IERC20(_usdc);
        oracle = IOracle(_oracle);
    }

    function depositCollateralAndBorrow(uint256 collateralAmount, uint256 borrowAmount) external payable {
        require(msg.value == collateralAmount, "ETH mismatch");

        uint256 ethPrice = getEthPrice(); // 8 decimales
        uint256 collateralValueUsd = (collateralAmount * ethPrice) / 1e18; // en USD con 8 decimales
        require(collateralValueUsd > 0, "Collateral value is zero");

        // borrowAmount tiene 6 decimales, convertimos a 8 para comparar
        uint256 borrowAmountUsd = borrowAmount * 1e2; // de 6 a 8 decimales

        uint256 ratio = (collateralValueUsd * 100) / borrowAmountUsd;
        require(ratio >= MIN_COLLATERAL_RATIO, "Collateral ratio too low");

        loans[msg.sender] = Loan(msg.value, borrowAmount);
        require(usdc.transfer(msg.sender, borrowAmount), "USDC transfer failed");
    }

    function liquidate(address user) external {
        Loan memory loan = loans[user];
        require(loan.collateralAmount > 0, "No loan");

        uint256 ethPrice = getEthPrice(); // 8 decimales
        uint256 collateralValueUsd = (loan.collateralAmount * ethPrice) / 1e18; // en USD con 8 decimales

        uint256 borrowAmountUsd = loan.borrowedAmount * 1e2; // 6 a 8 decimales

        uint256 ratio = (collateralValueUsd * 100) / borrowAmountUsd;
        require(ratio < MIN_COLLATERAL_RATIO, "Cannot liquidate");

        uint256 reward = (loan.collateralAmount * 10) / 100; // 10% de recompensa
        uint256 seized = loan.collateralAmount;

        // Borrar el préstamo
        loans[user] = Loan(0, 0);

        // Paga la recompensa al liquidador
        payable(msg.sender).transfer(reward);

        // El resto del colateral queda para el protocolo (o puedes enviarlo a owner, o quemarlo)
        // En este ejemplo simplemente queda en el contrato.
    }

    function getEthPrice() public view returns (uint256) {
        return oracle.ethPrice();
    }
}
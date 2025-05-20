// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/Lending.sol";
import "../contracts/OracleMock.sol";

// Mock ERC20 for USDC
contract USDCMock is IERC20 {
    string public constant name = "MockUSDC";
    string public constant symbol = "USDC";
    uint8 public constant decimals = 6;
    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    function transfer(address to, uint256 value) public override returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        allowance[from][msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) public {
        balanceOf[to] += value;
        totalSupply += value;
        emit Transfer(address(0), to, value);
    }
    // NO declares de nuevo los eventos Transfer y Approval aquí,
    // ya están en la interfaz IERC20
}

contract LendingTest is Test {
    LendingProtocol lending;
    USDCMock usdc;
    OracleMock oracle;

    address user = address(0xABCD);

    function setUp() public {
        usdc = new USDCMock();
        oracle = new OracleMock();
        lending = new LendingProtocol(address(usdc), address(oracle));
        // Mint USDC to the Lending contract so it can lend out tokens
        usdc.mint(address(lending), 1_000_000 * 1e6);
    }

    function testDepositAndBorrow() public {
        uint256 collateral = 1 ether;
        uint256 borrow = 1000 * 1e6; // 1000 USDC

        vm.deal(address(this), collateral);
        lending.depositCollateralAndBorrow{value: collateral}(collateral, borrow);

        assertEq(usdc.balanceOf(address(this)), borrow);
        (uint256 storedCollateral, uint256 storedBorrow) = lending.loans(address(this));
        assertEq(storedCollateral, collateral);
        assertEq(storedBorrow, borrow);
    }

    function testLiquidate() public {
        uint256 collateral = 1 ether;
        uint256 borrow = 1000 * 1e6; // 1000 USDC, ratio inicial = 200%
        // Bajamos el precio para que la ratio baje de 150%

        vm.deal(address(this), collateral);
        lending.depositCollateralAndBorrow{value: collateral}(collateral, borrow);

        // Lower ETH price to force liquidation
        oracle.setPrice(600 * 1e8); // Baja el precio para ratio < 150%

        uint256 initialUserBalance = user.balance;
        vm.prank(user);
        lending.liquidate(address(this));

        // Loan should be cleared
        (uint256 storedCollateral, ) = lending.loans(address(this));
        assertEq(storedCollateral, 0);

        // user gets 10% ETH reward
        uint256 reward = (collateral * 10) / 100;
        assertEq(user.balance, initialUserBalance + reward);
    }

    function testLiquidateFuzz(uint256 collateral, uint256 borrow) public {
        vm.assume(collateral > 1 ether && collateral < 1000 ether);
        vm.assume(borrow > 0 && borrow < 10_000_000 * 1e6);

        // Asegúrate que el préstamo es posible con el precio inicial
        uint256 ethPrice = oracle.ethPrice(); // 2000*1e8
        uint256 collateralValueUsd = (collateral * ethPrice) / 1e18; // 8 decimales
        uint256 borrowAmountUsd = borrow * 1e2; // 6 a 8 decimales
        uint256 ratio = (collateralValueUsd * 100) / borrowAmountUsd;
        vm.assume(ratio >= 150);  // Solo prueba préstamos posibles

        vm.deal(address(this), collateral);
        lending.depositCollateralAndBorrow{value: collateral}(collateral, borrow);

        // Calcula precio para que ratio < 150%
        uint256 price = (15 * 1e17 * borrow) / collateral;
        oracle.setPrice(price);

        vm.prank(user);
        lending.liquidate(address(this));
        (uint256 storedCollateral, ) = lending.loans(address(this));
        assertEq(storedCollateral, 0);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title USDTProxyUpgradeable (UUPS)
 * @notice 可升级版本，功能与 USDTProxy_Simple 一致，新增 UUPS 升级能力。
 *         使用低级调用兼容不同 USDT 实现（EIP-20 / 2612 / DAI-Permit）。
 */
contract USDTProxyUpgradeable is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    address public usdtToken;

    // 事件（OwnableUpgradeable 已内置 OwnershipTransferred）
    event USDTDeposited(address indexed user, uint256 amount);
    event USDTWithdrawn(address indexed owner, address indexed to, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _usdtToken, address initialOwner) public initializer {
        require(_usdtToken != address(0), "USDT token address cannot be zero");
        require(initialOwner != address(0), "Owner cannot be zero");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        usdtToken = _usdtToken;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function getUSDTAddress() external view returns (address) {
        return usdtToken;
    }

    function depositUSDT(address from, uint256 amount) external {
        require(from != address(0), "From address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");

        (bool success1, bytes memory data1) = usdtToken.call(
            abi.encodeWithSignature("allowance(address,address)", from, address(this))
        );
        require(success1, "Allowance check failed");
        uint256 allowance = abi.decode(data1, (uint256));
        require(allowance >= amount, "Insufficient allowance");

        (bool success2,) = usdtToken.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, address(this), amount)
        );
        require(success2, "Transfer failed");

        emit USDTDeposited(from, amount);
    }

    function withdrawUSDT(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "To address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");

        (bool success1, bytes memory data1) = usdtToken.call(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        require(success1, "Balance check failed");
        uint256 balance = abi.decode(data1, (uint256));
        require(balance >= amount, "Insufficient balance");

        (bool success2,) = usdtToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        require(success2, "Transfer failed");

        emit USDTWithdrawn(owner(), to, amount);
    }

    function getUSDTBalance() external view returns (uint256) {
        (bool success, bytes memory data) = usdtToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        require(success, "Balance check failed");
        return abi.decode(data, (uint256));
    }

    function getUserAllowance(address user) external view returns (uint256) {
        (bool success, bytes memory data) = usdtToken.staticcall(
            abi.encodeWithSignature("allowance(address,address)", user, address(this))
        );
        require(success, "Allowance check failed");
        return abi.decode(data, (uint256));
    }

    // ============ 单笔 Permit 支持 ============
    function depositWithPermit(
        address owner_,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(owner_ != address(0), "Owner cannot be zero");
        require(amount > 0, "Amount must be > 0");

        (bool okPermit, ) = usdtToken.call(
            abi.encodeWithSignature(
                "permit(address,address,uint256,uint256,uint8,bytes32,bytes32)",
                owner_,
                address(this),
                amount,
                deadline,
                v,
                r,
                s
            )
        );
        require(okPermit, "Permit failed");

        (bool okTransfer, ) = usdtToken.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                owner_,
                address(this),
                amount
            )
        );
        require(okTransfer, "Transfer failed");

        emit USDTDeposited(owner_, amount);
    }

    function depositWithDAIPermit(
        address owner_,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(owner_ != address(0), "Owner cannot be zero");
        require(amount > 0, "Amount must be > 0");

        (bool okPermit, ) = usdtToken.call(
            abi.encodeWithSignature(
                "permit(address,address,uint256,uint256,bool,uint8,bytes32,bytes32)",
                owner_,
                address(this),
                nonce,
                expiry,
                allowed,
                v,
                r,
                s
            )
        );
        require(okPermit, "DAI permit failed");

        if (allowed) {
            (bool okTransfer, ) = usdtToken.call(
                abi.encodeWithSignature(
                    "transferFrom(address,address,uint256)",
                    owner_,
                    address(this),
                    amount
                )
            );
            require(okTransfer, "Transfer failed");
            emit USDTDeposited(owner_, amount);
        }
    }
}



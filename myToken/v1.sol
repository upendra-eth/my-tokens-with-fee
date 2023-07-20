// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20, Ownable {
    uint256 public constant MAX_TOTAL_FEE = 10 * 10**18; // Max total fee (10%)
    uint256 public transactionFeePercentage = 4; // 4% transaction fee
    uint256 public developerFeePercentage = 1; // 1% developer fee
    uint256 public marketingFeePercentage = 2; // 2% marketing fee

    address public developerAddress;
    address public marketingAddress;

    uint256 public constant VERSION = 1;

    mapping(address => bool) public feeExcluded;

    event FeeExclusion(address indexed account, bool isExcluded);

    constructor(
        string memory name,
        string memory symbol,
        address _developerAddress,
        address _marketingAddress,
        uint256 totalSupply,
        string memory _version
    ) ERC20(name, symbol) {
        require(totalSupply <= 10_000_000 * 10**18, "Total supply exceeds the maximum limit");
        _mint(msg.sender, totalSupply);
        developerAddress = _developerAddress;
        marketingAddress = _marketingAddress;
        version = _version;
    }

    function setTransactionFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= 10, "Fee percentage must be less than or equal to 10");
        transactionFeePercentage = _feePercentage;
    }

    function setDeveloperFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= 10, "Fee percentage must be less than or equal to 10");
        developerFeePercentage = _feePercentage;
    }

    function setMarketingFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= 10, "Fee percentage must be less than or equal to 10");
        marketingFeePercentage = _feePercentage;
    }

    function excludeFromFees(address account, bool isExcluded) external onlyOwner {
        feeExcluded[account] = isExcluded;
        emit FeeExclusion(account, isExcluded);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(recipient != address(0), "Invalid recipient address");

        uint256 totalFeePercentage = transactionFeePercentage + developerFeePercentage + marketingFeePercentage;
        require(totalFeePercentage <= 10, "Total fee percentage exceeds the maximum limit");

        uint256 transactionFee = 0;
        uint256 developerFee = 0;
        uint256 marketingFee = 0;

        if (!feeExcluded[_msgSender()]) {
            transactionFee = (amount * transactionFeePercentage) / 100;
            developerFee = (amount * developerFeePercentage) / 100;
            marketingFee = (amount * marketingFeePercentage) / 100;
        }

        _transfer(_msgSender(), recipient, amount - transactionFee - developerFee - marketingFee);
        _transfer(_msgSender(), developerAddress, developerFee);
        _transfer(_msgSender(), marketingAddress, marketingFee);

        return true;
    }
}


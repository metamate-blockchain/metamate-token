// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IPancakePair.sol";
import "@uniswap/v2-core/contracts/interfaces/IPancakeFactory.sol";
import "../interfaces/IPancakeRouter.sol";
import "../utils/LGEWhitelisted.sol";

contract MTMToken is Context, ERC20, Ownable, LGEWhitelisted  {
    using SafeMath for uint256;
    IPancakeRouter02 public pancakeswapV2Router;
    address public pancakeswapV2Pair;

    uint256 public sellFee = 3;
    uint256 public buyFee = 0;
    uint256 public maxAmount = 200 * 10**3 * 10**18;

    address public mktAddr = 0x6dBfCBaa184aE6AC62d02304CD18900a2796c7d9;
    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isWhitelist;

    constructor() public ERC20("MetaMate", "MTM") {
        // Pancake address testnet
        // IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(
        //     0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // );
        // Pancake address mainnet
        IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        // Create a pancakeswap pair for this new token
        address _pancakeswapV2Pair = IPancakeFactory(
            _pancakeswapV2Router.factory()
        ).createPair(address(this), _pancakeswapV2Router.WETH());
        pancakeswapV2Router = _pancakeswapV2Router;
        pancakeswapV2Pair = _pancakeswapV2Pair;

        setWhitelistAddr(address(this), true);
        setWhitelistAddr(owner(), true);
        setWhitelistAddr(mktAddr, true);

        _mint(owner(), 1000000000 * (10**18));
    }

    receive() external payable {}

    function setFee(uint256 _sellFee, uint256 _buyFee) public onlyOwner {
        require(0 <= _sellFee && _sellFee <= 10, "MTMToken: SellFee <= 10");
        require(0 <= _buyFee && _buyFee <= 10, "MTMToken: BuyFee <= 10");
        sellFee = _sellFee;
        buyFee = _buyFee;
    }

    function setMktAddress(address _wallet) external onlyOwner {
        require(_wallet != address(0), "MTMToken: Invalid Address");
        mktAddr = _wallet;
    }

    function setWhitelistAddr(address account, bool value) public onlyOwner {
        _isWhitelist[account] = value;
    }

    function isWhitelistAddr(address account) public view returns (bool) {
        return _isWhitelist[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "MTMToken: transfer from the zero address");
        require(to != address(0), "MTMToken: transfer to the zero address");
        
        _applyLGEWhitelist(from, to, amount);

        require(amount > 0, "MTMToken: amount = 0");
        if (
            amount > maxAmount &&
            to == pancakeswapV2Pair &&
            !isWhitelistAddr(from)
        ) {
            revert("MTMToken: MaxAmount");
        }

        uint256 transferFee = to == pancakeswapV2Pair
            ? sellFee
            : (from == pancakeswapV2Pair ? buyFee : 0);

        if (transferFee > 0 && from != address(this) && to != address(this)) {
            uint256 _fee = amount.mul(transferFee).div(100);
            swapTokensForEth(_fee);
            amount = amount.sub(_fee);
        }

        super._transfer(from, to, amount);
    }

    function setMaxAmount(uint256 _maxAmount) external onlyOwner {
        require(
            _maxAmount > 200 * 10**3 * 10**18,
            "MTMToken: maxAmount too small"
        );
        maxAmount = _maxAmount;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        try
            pancakeswapV2Router
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    path,
                    mktAddr,
                    block.timestamp
                )
        {} catch {}
    }
}

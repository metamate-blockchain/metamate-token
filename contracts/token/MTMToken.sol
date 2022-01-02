// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@uniswap/v2-core/contracts/interfaces/IPancakePair.sol";
import "@uniswap/v2-core/contracts/interfaces/IPancakeFactory.sol";
import "../interfaces/IPancakeRouter.sol";

abstract contract BPContract {
    function protect(
        address sender,
        address receiver,
        uint256 amount
    ) external virtual;
}

contract MTMToken is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    IPancakeRouter02 public pancakeswapV2Router;
    address public pancakeswapV2Pair;

    uint256 public sellFee = 2;
    uint256 public buyFee = 1;
    uint256 public maxAmount = 200 * 10**3 * 10**18;

    address public mktAddr = 0x0af7e6C3dCEd0f86d82229Bd316d403d78F54E07;
    uint256 public swapTokensAtAmount = 10 * 10**3 * 10**18;
    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isWhitelist;
    //Bot Protect
    BPContract public BP;
    bool public bpEnabled;
    bool public BPDisabledForever = false;

    constructor() public ERC20("MTM TOKEN", "MTM") {
        //testnet
        IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //mainnet
        // IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        // );
        // Create a pancakeswap pair for this new token
        address _pancakeswapV2Pair = IPancakeFactory(
            _pancakeswapV2Router.factory()
        ).createPair(address(this), _pancakeswapV2Router.WETH());
        pancakeswapV2Router = _pancakeswapV2Router;
        pancakeswapV2Pair = _pancakeswapV2Pair;

        setWhitelistAddr(address(this), true);
        setWhitelistAddr(owner(), true);
        setWhitelistAddr(mktAddr, true);

        _mint(owner(), 1200000000 * (10**18));
    }

    receive() external payable {}

    function setFee(uint256 _sellFee, uint256 _buyFee) public onlyOwner {
        require(0 <= _sellFee && _sellFee <= 10, "SellFee <= 10");
        require(0 <= _buyFee && _buyFee <= 10, "BuyFee <= 10");
        sellFee = _sellFee;
        buyFee = _buyFee;
    }

    function setMktAddress(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid Address");
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
        //Bot Protect
        if (bpEnabled && !BPDisabledForever) {
            BP.protect(from, to, amount);
        }

        require(amount > 0, "amount = 0");
        if (
            amount > maxAmount &&
            to == pancakeswapV2Pair &&
            !isWhitelistAddr(from)
        ) {
            revert("MaxAmount");
        }

        uint256 transferFee = to == pancakeswapV2Pair
            ? sellFee
            : (from == pancakeswapV2Pair ? buyFee : 0);

        if (transferFee > 0 && from != address(this) && to != address(this)) {
            uint256 _fee = amount.mul(transferFee).div(100);
            super._transfer(from, address(this), _fee);
            amount = amount.sub(_fee);
        }

        super._transfer(from, to, amount);
    }

    function setMaxAmount(uint256 _maxAmount) external onlyOwner {
        require(_maxAmount > 200 * 10**3 * 10**18, "maxAmount too small");
        maxAmount = _maxAmount;
    }

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount)
        external
        onlyOwner
    {
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function swapForMkt() public nonReentrant onlyOwner {
        uint256 _contractBalance = balanceOf(address(this));
        require(
            _contractBalance >= swapTokensAtAmount,
            "contractBalance < swapTokensAtAmount"
        );
        swapTokensForEth(swapTokensAtAmount);
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

    //Bot Protect Func
    function setBPAddrss(address _bp) external onlyOwner {
        require(address(BP) == address(0), "Can only be initialized once");
        BP = BPContract(_bp);
    }

    function setBpEnabled(bool _enabled) external onlyOwner {
        bpEnabled = _enabled;
    }

    function setBotProtectionDisableForever() external onlyOwner {
        require(BPDisabledForever == false);
        BPDisabledForever = true;
    }
}

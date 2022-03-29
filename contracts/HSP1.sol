//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

interface IHOGE {
    function reflect(uint256 tAmount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract HogeStandardPayable1 {
    /* 
        HSP1 accepts ETH, then purchases HOGE 
       and reflects it to all holders.
    */
    using SafeMath for uint256;
    IHOGE HOGE = IHOGE(0xfAd45E47083e4607302aa43c65fB3106F1cd7607);
    IUniswapV2Pair pair = IUniswapV2Pair(0x7FD1de95FC975fbBD8be260525758549eC477960);
    IUniswapV2Router02 router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    //Prices are based on previous blocks to avoid sandwich attacks on purchases.   
    struct PriceReading {
        uint64 ethReserves;
        uint64 hogeReserves;
        uint32 block;
    }
    PriceReading reading1 = PriceReading(0,0,0);
    PriceReading reading2 = PriceReading(0,0,1);
    receive() external payable {}

    function updatePrice() public {
        (uint ethReserves, uint hogeReserves, ) = pair.getReserves();
        if (reading1.block < reading2.block && reading2.block < block.number) {
            reading1.ethReserves = uint64(ethReserves / 10**9);
            reading1.hogeReserves = uint64(hogeReserves / 10**9);
            reading1.block = uint32(block.number);
        } else if (reading1.block > reading2.block && reading1.block < block.number) {
            reading2.ethReserves = uint64(ethReserves / 10**9);
            reading2.hogeReserves = uint64(hogeReserves / 10**9);
            reading2.block = uint32(block.number);
        }
    }

    function amountOut() public view returns (uint256) { 
        PriceReading memory toRead = reading1.block < reading2.block ? reading1 : reading2;
        uint ethReserves = uint256(toRead.ethReserves) * 10**9;
        uint hogeReserves = uint256(toRead.hogeReserves) * 10**9;
        uint out = router.getAmountOut(address(this).balance, ethReserves, hogeReserves);
        //3% slippage
        return out.mul(97).div(100);
    }

    function buyHoge() public {
        address[] memory path = new address[](2);
        path[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH
        path[1] = 0xfAd45E47083e4607302aa43c65fB3106F1cd7607; //HOGE
        router.swapExactETHForTokensSupportingFeeOnTransferTokens
            {value:address(this).balance}
            (amountOut(), path, address(this), block.timestamp);
    }

    function reflectHOGE() public {
        uint myHoge = HOGE.balanceOf(address(this));
        HOGE.reflect(myHoge);
    }

 
}

//SPDX-License-Identifier:MIT
pragma solidity 0.8.21;

/**
 * @title SWAPF DECENTRALISED EXCHANGE
 * @author Cipheriousxyz
 * @notice this is a just to verify my understanding of the mechanics of uniswapV2 codebase
 */

import {ERC20} from "lib/solady/src/tokens/ERC20.sol";

contract SwapFPair is ERC20 {
    address private s_token0;
    address private s_token1;
    uint112 private s_reserve0;
    uint112 private s_reserve1;
    uint32 private s_blockTimestampLast;
    uint256 private s_price0CummulativeLast;
    uint256 private s_price1CummulativeLast;

    error SwapFPair__coreInvariantBroken();
    error SwapFPair__bothSwapTokensOutputsAmountsCannotBeZero();
    error SwapFPair__poolReserveMustNotBeZero();
    error SwapFPair__NotEnoughLiquidity();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ERC20 METADATA                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the name of the token.
    function name() public view virtual returns (string memory) {
        return "SwapF-Token";
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view override returns (string memory) {
        return "SF";
    }

    /// @dev Returns the decimals places of the token.
    function decimals() public view override returns (uint8) {
        return 18;
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes memory data) public {
        if (amount0Out == 0 && amount1Out == 0) revert SwapFPair__bothSwapTokensOutputsAmountsCannotBeZero();
        //1.get the cache or internal balances of the pool tokens
        (uint112 _reserve0, uint112 _reserve1) = getReserves();
        if (_reserve0 == 0 || _reserve1 == 0) revert SwapFPair__poolReserveMustNotBeZero();
        if (amount0Out > _reserve0 || amount1Out > _reserve1) revert SwapFPair__NotEnoughLiquidity();
        uint256 balance0;
        uint256 balance1;
        {
            address _token0 = s_token0;
            address _token1 = s_token1;
            //2.Optimistically transfer the output tokens to
            if (amount0Out > 0) IERC20(_token0).safeTransfer(to, amount0Out);
            if (amount1Out > 0) IERC20(_token1).safeTransfer(to, amount1Out);
            //3.Make an external call to (Hand over execution )
            if (data > 0) IuniswapV2Callee(to).uniswapCall(msg.sender, amount0Out, amount1Out, data);
            //4.get the actual currrent balances of the pool  tokens
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        //5.Calculate the amount0In and the  Amount1In
        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        //6.Enforce that K_After >= K_Before
        {
            uint256 balance0Adjusted = (balance0 * 1000) - (3 * amount0In);
            uint256 balance1Adjusted = (balance1 * 1000) - (3 * amount1In);
            if ((balance0Adjusted * balance1Adjusted) < (1_000_000 * _reserve0 * _reserve1)) {
                revert SwapFPair__coreInvariantBroken();
            }
        }
        //7.Update the pool reserves and the cummulative prices
        _update(balance0, balance1, _reserve0, _reserve1);
    }

    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) internal {
        //1.get the current block timestamp
        uint32 blockTimestamp = uint32(block.timestamp % 32);
        //2.get the blocktimestampLast
        uint32 _blockTimestampLast = s_blockTimestampLast;
        //3.calculate the time elapsed
        uint256 timeElaspsed = blockTimestamp - _blockTimestampLast;
        //4.Calculate the price0CummulativeLast
        {
            s_price0CummulativeLast += (timeElaspsed * _reserve1) / _reserve0;
            //5.Calculate the price1CummulativeLast
            s_price1CummulativeLast += (timeElaspsed * _reserve0) / _reserve1;
        }
        //6.update the pool reserves
        s_reserve0 = balance0;
        s_reserve1 = balance1;
    }

    function getReserves() public returns (uint112 _reserve0, uint112 _reserve1) {
        _reserve0 = s_reserve0;
        _reserve1 = s_reserve1;
    }
}

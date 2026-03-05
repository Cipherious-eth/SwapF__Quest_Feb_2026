//SPDX-License-Identifier:MIT
pragma solidity 0.8.21;

/**
 * @title SWAPF DECENTRALISED EXCHANGE
 * @author Cipheriousxyz
 * @notice this is a just to verify my understanding of the mechanics of uniswapV2 codebase
 */
contract SwapFPair {
    address private s_token0;
    address private s_token1;
    uint112 private s_reserve0;
    uint112 private s_reserve1;

    error SwapFPair__coreInvariantBroken();
    error SwapFPair__bothSwapTokensOutputsAmountsCannotBeZero();
    error SwapFPair__poolReserveMustNotBeZero();
    error SwapFPair__NotEnoughLiquidity();

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
        amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
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
    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) internal {}

    function getReserves() public returns (uint112 _reserve0, uint112 _reserve1) {
        _reserve0 = s_reserve0;
        _reserve1 = s_reserve1;
    }
}

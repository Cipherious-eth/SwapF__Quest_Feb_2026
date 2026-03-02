## The Swap Algorithm
1. Get the internal(cache) balance of the pool tokens.
2. Optimistically transfer the output tokens to the user.This is a design choice to allow for flash swap.
3. Hand over execution to swapper
4. Get the actual balances of the pool
5. Calculate the amount of inputs tokens sent to the pool.
6. Adjust the balances to account for swap fees
7. Update the pool cache reserves and TWAP
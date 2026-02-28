## Technical Specification:SWAPF DECENTRALISED EXCHANGE(DEX)
   **SWAPF** is a constant Product Market Maker(CPMM) that seeks to improve the 
   efficiency and robustness of the uniswapV2 protocol.
   This version is just the start of the protocol 

## 1. Mathematical Model
 - Let  x and y $\in \mathbb{Z}^+$  and K represent  square of  liquidity $K = L^2$;
     __Core Invariant: f(x,y) = K__
   


## 2. State Variables
  - `uint112 private s_reserve0`
  - `uint112 private s_reserve1`
  - `uint256 private s_kLast`
  - `uint256 private _totalsupply`
  - `mapping(address account => uint256 userBalance) private _balances`
  - `mapping(address account => mapping(address spender => uint256)) private _allowances`
  - `address public token0`
  - `address public token1`


## 3. Formal Properties(Invariants)
  - The total liquidity,__K__ after a swap should be greater than or equal to  the __K__ before a swap :
    new_reserve0 * new_reserve1 $\geq$ reserve0 * reserve1.
  - The increase in pool shares should be  directly  proportional to the increase in total liquidity of the pool.
  - The price before adding liquidity to a pool should be equal to the price after adding liquidity.
    
  

## 4. State Transitions(Functions)
## 5. Hazard Analysis(Prohibited States)
 - Never round shares calculation in favour of the user.
 - Uses should not be able to add only one of the pool tokens as liquidity provision
 - The system


  
## Technical Specification:SWAPF DECENTRALISED EXCHANGE(DEX)
   **SWAPF** is a constant Product Market Maker(CPMM) that seeks to improve the 
   efficiency and robustness of the uniswapV2 protocol.
   

## 1. Mathematical Model
 - Let  x and y $\in \mathbb{Z}^+$  and K represent  square of  liquidity $K = L^2$;
     __Core Invariant: f(x,y) = K__
 - The protocol takes 30 bases ponts fee as incentive for liquidity provision.

   Let _f_   $\in$  $\mathbb{Z}^+$ : 0 $\leq$ _f_ $\leq$ 1 where _f_ represents fee, 

   **$d_y$**: amount of output token _y_ in a swap, 

   **$d_x$**: the amount of input token _x_,

   **$x_0$**: total amount of token _x_ in the pool and 

   **$y_0$**: the total amount of token _y_ in the same pool. 

   $\therefore$ **$d_y$** =  $\frac{d_x.y_0(1-f)}{x_0 + d_x(1 - f )}$

- Calculating the amount of output token in a swap;  
   $d_y$ = $\frac{d_x . y_0 }{\frac{1000 . x_0}{997} + d_x}$



   


## 2. State Variables
  - `uint112 private s_reserve0`
  - `uint112 private s_reserve1`
  - `uint256 private s_kLast`
  - `uint256 private _totalsupply`
  - `mapping(address account => uint256 userBalance) private _balances`
  - `mapping(address account => mapping(address spender => uint256)) private _allowances`
  - `address public token0`
  - `address public token1`
  - `uint256 private constant FEE_PRECISION_NUMERATOR` = 997 
  - `uint256 private constant FEE_PRECISION_DENOMINATOR` = 1000


## 3. Formal Properties(Invariants)
  - The total liquidity,__K__ after a swap should be greater than or equal to  the __K__ before a swap :
    new_reserve0 * new_reserve1 $\geq$ reserve0 * reserve1.
  - The increase in pool shares should be  directly  proportional to the increase in total liquidity of the pool.
  - The price before adding liquidity to a pool should be equal to the price after adding liquidity.
    
  

## 4. State Transitions(Functions)
  - `swap(amount0Out, amount1Out):`

    **Pre-condition**
    - `amount0Out`  > 0  
    - `amount1Out` > 0  
    - 
  
    **Logic**
    1. get th
   


  - **`getAmountOut(amountIn, reserveIn, reserveOut)`:**   
      *Pre-condition*  
       - `amountIn` > 0 , `reserveIn` > 0 and `reserveOut` >  0  

      *Logic*  
       1. `amountInWithFee` = (`amountIn` * `FEE_PRECISION_NUMERATOR`) / `FEE_PRECISION_DENOMINATOR`  
       2. `numerator`       = `amountInWithFee`  *  `reserveOut`  
       3. `denominator`     = `amountInWithFee`  +  `reserveIn`  
       4. return `numerator`  /  `denominator`  
           
      *Post-condition*   
       - Return value  < `reserveOut`  
       - It must not modify state.

  - **`updateReserves(newReserve0,newReserve1)`:**  
      *Pre-condition*
       - `newReserve0` <  $2^{112}$ - 1  
       - `newReserve1` <  $2^{112}$ - 1  
       - It must be an internal function  
  
      *Logic*  
       1. `s_reserve0` = `newReserve0`   
       2. `s_reserve1` = `newReserve1`  
       3. emit  `ReservesUpdated(newReserve0, newReserve1)`   
    
      *Post-condition*  


  - **`getReserves()`**:  
      *Pre-condition*  
       - Anybody can call this function  

      *Logic*  
       1. `reserve0` =  `s_reserve0`  
       2. `reserve1` =  `s_reserve1`  
       3. return `reserve0`  `reserve1`  
   
      *Post-Condition*    
       - must not change state

       


      


  
  
  
## 5. Hazard Analysis(Prohibited States)
 - Never round shares calculation in favour of the user.
 - Uses should not be able to add only one of the pool tokens as liquidity provision
 - The system 


  
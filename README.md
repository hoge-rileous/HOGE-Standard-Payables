# HOGE Standard Payables

> Hand me my scissors, it's time to fix this ecosystem.

\- rorih, 19/m/Cali

*HOGE Standard Payables* is a collection of contracts designed to transform revenue from HOGE ecosystem projects into tangible and uncontroversial benefit for HOGE holders.
They should be able to receive funds in some form, and transmute them in a trustless way, without any dependence on centralized leadership or multisig keyholders. 

## HSP-1

HSP-1 receives ETH, and does market purchases straight from the Uniswap V2 pool. It then calls HOGE.reflect() on the entire purchased balance, which distributes it evenly among all holders. There is a basic built-in protection against sandwich attacks that could drain value from the purchases: the updatePrice() function polls the pool for the current price, and forces the purchase to use quotes from a previous block.
```
                  ╒═════════╕                      ╒════════════════╕  
 ┌┈┈┈┈┈┈┈┈┈┐ ETH  │Generic  │ ETH ╒════════╕ETH ╭━>│ WETH-HOGE pool │
 ┆Customers┆═════>│Ecosystem│════>│  HSP1  │━━━━╯  ╘════════════════╛
 └┈┈┈┈┈┈┈┈┈┚      │ Project │     ╘════════╛━━━━━╮ ╒══━━━━━══╕
                  ╘═════════╛                HOGE╰>│ Holders │
                                                   ╘═════════╛
```





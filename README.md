# Fuzzing formally verified contracts to reproduce popular security issues

This repository contains solidity implementations of the selected invariants for popular projects. Follow instructions given below to run Echidna to test these invariants.

## Fundamental equation of  DAI

The code and test file for this project is in `fund-eq-of-dai-certora` directory. Steps to test it:

- Install `solc-select` from https://github.com/crytic/solc-select
- Install and configure solidity version `0.8.13` with:
    ```
    $ solc-select install 0.8.13
    $ solc-select use 0.8.13
    ```
- Install Echidna from https://github.com/crytic/echidna
- Run Echidna with: 
    ```
    $ echidna . --contract TestVat --config config.yaml
    ```

This will run the echidna and will show a sequence of transactions that will violate the invariant representing fundamental equation of the DAI protocol. We have included the corpus to reproduce the bug in this repository to facilitate quick verification.

## Compound Comet

The code and test file for Compound Comet project is in `comet` directory. Steps to run Echidna:

- Install nodejs dependencies with `yarn install`
- Run Echidna with:
    ```
    $ echidna . --contract TestComet --config config.yaml
    ```
Echidna will run for a few seconds and produce the sequence of transactions to violate the invariants.

## Semaphore

The code and test file for Sempahore project is in `semaphore` directory. 

- Install foundry tools from https://github.com/foundry-rs/foundry
- Run Echidna with:
    ```
    $ echidna . --contract TestSemaphore --config config.yaml
    ```

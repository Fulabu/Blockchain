1)Open Ganache first then QuickStart.
2)Make sure delete existing ganache MetaMask account
3)write commands in terminal.
  truffle compile
  truffle migrate
4)Open MetaMask and create a network call localhost for Ganache (HTTP://127.0.0.1:7545, 1337, ETH)
5)Import the first address which is the admin and any other account for testing using the private keys.
4)Go Remix Change the environment to Ganache Provider before Deploying. (use HTTP://127.0.0.1:7545 for RPC)
Note: If error deploying go to Solidity Compiler -> Advanced Configurations -> Change EVM Version to 'London' then deploy again.
5)get 'ABI' and 'Contract address' and Paste into .js files
6)Write command in 'live-server' in terminal.

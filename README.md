![Alt text](https://raw.githubusercontent.com/andreatedesco/RaffleFi/master/assets/images/logo-rect.png)

## Inspiration
The DeFi sector has shown robust growth in 2024, with a notable increase in trading volumes from $49.6 billion in 2023 to $52.8 billion as of May 2024, a 6.5% increase, indicating a sustained interest and expansion in decentralized finance. In contrast, the NFT market is experiencing a decline, with trading volumes dropping significantly. As of May 2024, the NFT trading volume is $333 million, down from $1.3 billion in the same period in 2023, a dramatic decrease of nearly 74%. This data indicates a divergence between the thriving DeFi market and the struggling NFT market.

RaffleFi emerges as a response to this incongruity, aiming to enhance the accessibility of NFTs through an innovative raffle system. This approach holds the promise of broadening participation, opening new avenues for artists and collectors, and potentially reversing the downward trajectory in NFT trading volumes. By democratizing access to high-value digital assets, RaffleFi endeavors to rejuvenate the NFT market and foster a more inclusive digital asset ecosystem


## What it does
RaffleFi is a groundbreaking marketplace platform designed to facilitate the buying and selling of NFTs through a dynamic raffle system, thereby democratizing access to high-value digital assets. Users are empowered to create, manage, and participate in NFT raffles, offering them enhanced opportunities to acquire valuable NFTs with minimal investment. This innovative approach delivers mutual benefits to both buyers and sellers: buyers gain access to coveted NFTs that might otherwise be out of reach, while sellers can tap into a broader audience and achieve faster, more lucrative sales compared to traditional methods.

With RaffleFi, users can:

- Start a new raffle, setting the ticket price, the number of participants, as well as the contract and the ID of the NFT token at stake.
  ```solidity
  function startRaffle(uint256 ticketPrice, uint256 participantsNumber, address tokenAddress, uint256 tokenId) external;
  ```

- Cancel a previously started raffle, allowing the withdrawal of the NFT token at stake.
  ```solidity
  function cancelRaffle(uint256 raffleId) external;
  ```

- Participate in a raffle by purchasing a ticket.
  ```solidity
  function participate(uint256 raffleId) external payable;
  ```

- Withdraw participation from a previously purchased raffle.
  ```solidity
  function cancelParticipation(uint256 raffleId) external;
  ```

The current MVP of RaffleFi operates with existing ERC721s on the Polygon Amoy Testnet.
I chose to develop the project on Polygon because it is the most cost-effective EVM-compatible blockchain with a larger community.


## How I built it
I developed Smart Contracts in Solidity and implemented them on the Polygon Amoy Testnet. As a development environment for testing and deployment, I used Hardhat.

The structure is composed of:

### [RaffleManager.sol](https://github.com/andreatedesco/RaffleFi/blob/master/blockchain/contracts/RaffleManager.sol)
The RaffleManager contract is responsible for managing the entire lifecycle of a raffle. It handles the creation of new raffles, participation by users, and the distribution of prizes. Key functions include:
- `startRaffle`: Allows users to create a new raffle by specifying the ticket price, number of participants, and prize details.
- `participate`: Enables users to join a raffle by purchasing a ticket.
- `closeRaffle`: Called by the RaffleChecker to close a raffle and trigger the random winner selection process.
- `selectWinner`: Finalizes the raffle by selecting a winner using the random number provided by the RandomGenerator.

### [RaffleChecker.sol](https://github.com/andreatedesco/RaffleFi/blob/master/blockchain/contracts/RaffleChecker.sol) 
The RaffleChecker contract ensures that raffles are automatically closed when the required number of participants is reached. It integrates with [Chainlink Automation](https://automation.chain.link/polygon-amoy/102041187230818838600297010846463060881052113143162711194908975718707472217471) to periodically check the status of raffles and call the `closeRaffle` function when necessary. Key functions include:
- `checkUpkeep`: Determines if any raffles need to be closed.
- `performUpkeep`: Executes the necessary actions to close a raffle when conditions are met.

### [RandomGenerator.sol](https://github.com/andreatedesco/RaffleFi/blob/master/blockchain/contracts/RandomGenerator.sol)
The RandomGenerator contract is responsible for generating random numbers used to select raffle winners. It utilizes [Chainlink VRF](https://vrf.chain.link/polygon-amoy/14520244658930558852487142517189753937245840530259462183108250821211829852522) to ensure the randomness is secure and verifiable. Key functions include:
- `requestRandom`: Requests a random number from Chainlink VRF.
- `fulfillRandomWords`: Receives the random number from Chainlink VRF and calls the `selectWinner` function in RaffleManager to finalize the raffle.

As for the front-end, I made the interface in Unity using C#. The web3 integrations were implemented using Nethereum.


## Challenges I ran into
Developing this project presented numerous challenges, with one of the most significant being the fair distribution of participation costs and the automation of the closure process to prevent the last participant from shouldering excessive gas fees.

The conventional method of closing a raffle presented a dilemma: if the final participant triggered the closure, they would incur a disproportionate share of the associated gas costs. To address this issue, I needed a solution that would automate the closure process while ensuring fairness and transparency.

A pivotal aspect of the solution was integrating the RaffleChecker contract, which took on the responsibility of closing the raffle without relying on individual participant actions. By offloading the closure process to RaffleFi, I ensured that the burden of gas fees for finalization rested on the platform rather than individual participants..

As per best practice, for efficient use of gas, in the checkUpkeep function, in addition to iterating the control only between two indices passed in the checkData, the first ID of the raffle to close to move on to performUpkeep is calculated.

  ```solidity
    function checkUpkeep(
        bytes calldata checkData
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (uint256 minRaffleId, uint256 maxRaffleId) = abi.decode(
            checkData,
            (uint256, uint256)
        );

        upkeepNeeded = false;
        uint256 raffleId = 0;
        uint256 raffleIdCounter = raffleManager.getRaffleCounter();
        maxRaffleId = raffleIdCounter < maxRaffleId
            ? raffleIdCounter
            : maxRaffleId;

        for (uint256 i = minRaffleId; i < maxRaffleId; i++) {
            if (raffleManager.isRaffleReadyToClose(i)) {
                raffleId = i;
                upkeepNeeded = true;
                break;
            }
        }

        performData = abi.encode(raffleId);
        return (upkeepNeeded, performData);
    }
  ```

None of this would have been possible without Chainlink Automation, which provided the technology to automate the process.


## Accomplishments that we're proud of
In this project I have achieved several significant milestones that I am incredibly proud of:
- Developed an idea that can immediately be launched on the market which uses, or rather makes almost indispensable, the functionalities of Chainlink Automation to equalize gas costs for all participants, and Chainlink VRF to generate a secure and verifiable random number.
- Successfully developed smart contracts and tests on the Amoy network. Given Polygon's large community and low costs, it could be the ideal chain for launching RaffleFi's first real product.
- Created a fully functional MVP with an essential and intuitive user interface.
- Produced a presentation video that effectively summarizes RaffleFi and its potential.


## What I learned
During the development journey of this project, I gained experience beyond technical knowledge. I deepened my understanding of smart contracts and blockchains, especially in integrating Chainlink functionalities, a crucial element for the project's success. I spent time analyzing the market, understanding how Chainlink features could be synergistically integrated to enhance NFT accessibility through a raffle system.

In parallel, I honed my skills in designing and implementing an intuitive user interface, essential for ensuring a smooth and enjoyable user experience. Creating detailed documentation was crucial not only for the development process but also for ensuring clear and easy understanding of the product by end users.

This experience taught me the importance of planning and time management in a complex project like this. It also made me aware of the importance of being flexible and ready to solve problems that may arise along the development journey.


## What's next for RaffleFi
My goal is to transform RaffleFi into a concrete platform within the NFT sector, moving beyond its current MVP stage. 

Future developments may include:
- integrating with other blockchains
- introducing advanced raffle customization features
- expanding payment options
- establishing partnerships with artists and content creators.


## Deployed Smart Contracts
| Contract | Address
| ----------- | ----------- |
| RaffleManager | [0xF395e5c42d46a16eE2726De9BEf26A1F8a3396b9](https://amoy.polygonscan.com/address/0xF395e5c42d46a16eE2726De9BEf26A1F8a3396b9) |
| RaffleChecker | [0x53dF38b479899F54b8EA8bda3cB562196f1dFA8d](https://amoy.polygonscan.com/address/0x53dF38b479899F54b8EA8bda3cB562196f1dFA8d) |
| RandomGenerator | [0x3F031Eb5E632561C3501c7355774E7D9A47a9316](https://amoy.polygonscan.com/address/0x3F031Eb5E632561C3501c7355774E7D9A47a9316) |

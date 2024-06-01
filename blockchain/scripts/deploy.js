const hre = require("hardhat");

async function main() {
  
  // ================================================ //

  const signers = await ethers.getSigners();
  var signer = signers[0];
  var signer01 = signers[1];
  var signer02 = signers[2];
  var signer03 = signers[3];
  var signer04 = signers[4];
  var signer05 = signers[5];


  // ================================================ //

  var deployNFTCollection = false;
  var NFTCollectionName = "NFTCollection";
  var NFTCollectionFactory;
  var NFTCollectionContract;
  var NFTCollectionAddress = "0xaDcaD1b3F5e16a3D59A9ba8BdB936391B3770c7C"; 
  
  var deployRaffleManager = false;
  var RaffleManagerName = "RaffleManager";
  var RaffleManagerFactory;
  var RaffleManagerContract;
  var RaffleManagerAddress = "0xF395e5c42d46a16eE2726De9BEf26A1F8a3396b9";

  var deployRandomGenerator = false;
  var RandomGeneratorName = "RandomGenerator";
  var RandomGeneratorFactory;
  var RandomGeneratorContract;
  var RandomGeneratorAddress = "0x4659F7241d827F9cd4EDCb494D5ddC78b80fe6B7";

  var deployRaffleChecker = false;
  var RaffleCheckerName = "RaffleChecker";
  var RaffleCheckerFactory;
  var RaffleCheckerContract;
  var RaffleCheckerAddress = "0x53dF38b479899F54b8EA8bda3cB562196f1dFA8d";

  var updateRandomGeneratorInRaffleManager = false;
  var updateRaffleManagerInRandomGenerator = false;

  var updateRaffleCheckerInRaffleManager = false;
  var updateRaffleManagerInRaffleChecker = false;

  var approveRaffleManager = false;
  var mintNFT = false;
  var mintNFTs = false;
  var startRaffle = false;
  var signer01Partecipate = false;
  var signer02Partecipate = false;
  var signer03Partecipate = false;
  var signer04Partecipate = false;
  var signer05Partecipate = false;
  var getRaffleInfo = true;

  var ticketPrice = ethers.utils.parseEther("0");
  var participants = 3;
  var automateTokenId = false;
  var tokenId = 0;

  var automateRaffleId = false;
  var raffleId = 0;

  var collectionName = "Collection #0001";
  var collectionSymbol = "NFT1";
  var metadataContactUri = "https://raw.githubusercontent.com/andreatedesco/Utilities/master/Metadata/collection";
  var metadataTokenUri = "https://raw.githubusercontent.com/andreatedesco/Utilities/master/Metadata/token-0000";

  var minTokenId = 0;
  var maxTokenId = 13;
  var metadataTokenUriN = "https://raw.githubusercontent.com/andreatedesco/Utilities/master/Metadata/token-00";

  // ================================================ //

  console.log("=== START ===");

  if(deployNFTCollection){
    NFTCollectionFactory = await hre.ethers.getContractFactory(NFTCollectionName);
    NFTCollectionContract = await NFTCollectionFactory.connect(signer).deploy(metadataContactUri, collectionName, collectionSymbol);
    NFTCollectionAddress = (await NFTCollectionContract.deployed()).address;
    console.log(`${NFTCollectionName} deployed to ${NFTCollectionAddress}`);
  }else{
    NFTCollectionFactory = await hre.ethers.getContractFactory(NFTCollectionName);
    NFTCollectionContract = await NFTCollectionFactory.attach(NFTCollectionAddress);
    console.log(`attached ${NFTCollectionName} to ${NFTCollectionAddress}`);
  }

  if(deployRaffleManager){
    RaffleManagerFactory = await hre.ethers.getContractFactory(RaffleManagerName);
    RaffleManagerContract = await RaffleManagerFactory.connect(signer).deploy();
    RaffleManagerAddress = (await RaffleManagerContract.deployed()).address;
    console.log(`${RaffleManagerName} deployed to ${RaffleManagerAddress}`);
  }else{
    RaffleManagerFactory = await hre.ethers.getContractFactory(RaffleManagerName);
    RaffleManagerContract = await RaffleManagerFactory.attach(RaffleManagerAddress);
    console.log(`attached ${RaffleManagerName} to ${RaffleManagerAddress}`);
  }

  if(deployRandomGenerator){
    RandomGeneratorFactory = await hre.ethers.getContractFactory(RandomGeneratorName);
    RandomGeneratorContract = await RandomGeneratorFactory.connect(signer).deploy();
    RandomGeneratorAddress = (await RandomGeneratorContract.deployed()).address;
    console.log(`${RandomGeneratorName} deployed to ${RandomGeneratorAddress}`);
  }else{
    RandomGeneratorFactory = await hre.ethers.getContractFactory(RandomGeneratorName);
    RandomGeneratorContract = await RandomGeneratorFactory.attach(RandomGeneratorAddress);
    console.log(`attached ${RandomGeneratorName} to ${RandomGeneratorAddress}`);
  }

  if(deployRaffleChecker){
    RaffleCheckerFactory = await hre.ethers.getContractFactory(RaffleCheckerName);
    RaffleCheckerContract = await RaffleCheckerFactory.connect(signer).deploy();
    RaffleCheckerAddress = (await RaffleCheckerContract.deployed()).address;
    console.log(`${RaffleCheckerName} deployed to ${RaffleCheckerAddress}`);
  }else{
    RaffleCheckerFactory = await hre.ethers.getContractFactory(RaffleCheckerName);
    RaffleCheckerContract = await RaffleCheckerFactory.attach(RaffleCheckerAddress);
    console.log(`attached ${RaffleCheckerName} to ${RaffleCheckerAddress}`);
  }

  if(updateRandomGeneratorInRaffleManager){
    Transaction = await RaffleManagerContract.updateRandomGenerator(RandomGeneratorAddress);
    console.log(`Update ${RandomGeneratorName} to ${RaffleManagerName}`);
  }

  if(updateRaffleManagerInRandomGenerator){
    Transaction = await RandomGeneratorContract.updateRaffleManager(RaffleManagerAddress);
    console.log(`Update ${RaffleManagerName} to ${RandomGeneratorName}`);
  }

  if(updateRaffleCheckerInRaffleManager){
    Transaction = await RaffleManagerContract.updateRaffleChecker(RaffleCheckerAddress);
    console.log(`Update ${RaffleCheckerName} to ${RaffleManagerName}`);
  }

  if(updateRaffleManagerInRaffleChecker){
    Transaction = await RaffleCheckerContract.updateRaffleManager(RaffleManagerAddress);
    console.log(`Update ${RaffleManagerName} to ${RaffleCheckerName}`);
  }

  if(approveRaffleManager){
    Transcation = await NFTCollectionContract.connect(signer).setApprovalForAll(RaffleManagerAddress, true);
    console.log(`setApprovalForAll COMPLETED`);
  }

  if(mintNFT){
    Transcation = await NFTCollectionContract.connect(signer).safeMint(signer.address, metadataTokenUri);
    console.log(`safeMint COMPLETED`);
  }

  if (mintNFTs) {
    for (var i = minTokenId; i <= maxTokenId; i++) {
      var id = i.toString().padStart(2, '0'); // Converti l'ID in una stringa a due caratteri
      const transaction = await NFTCollectionContract.connect(signer).safeMint(signer.address, metadataTokenUriN + id);
      console.log(`safeMint COMPLETED for tokenId: ${id}`);
    }
  }

  if(automateTokenId){
    tokenId = await NFTCollectionContract.currentSupply() - 1;
    console.log(`tokenId ${tokenId}`);
  }  

  if(startRaffle){
    Transcation = await RaffleManagerContract.connect(signer).startRaffle(ticketPrice, participants, NFTCollectionAddress, tokenId);
    console.log(`createRaffle COMPLETED`);
  }

  if(automateRaffleId){
    raffleId = await RaffleManagerContract.getRaffleCounter() - 1;
    console.log(`raffleId ${raffleId}`);
  }  

  if(signer01Partecipate){
    Transcation = await RaffleManagerContract.connect(signer01).participate(raffleId, { value: ticketPrice });
    console.log(`signer01 participate COMPLETED`);
    wait(2500);
  }

  if(signer02Partecipate){
    Transcation = await RaffleManagerContract.connect(signer02).participate(raffleId, { value: ticketPrice });
    console.log(`signer02 participate COMPLETED`);
    wait(2500);
  }
  
  if(signer03Partecipate){
    Transcation = await RaffleManagerContract.connect(signer03).participate(raffleId, { value: ticketPrice });
    console.log(`signer03 participate COMPLETED`);
    wait(2500);
  }

  if(signer04Partecipate){
    Transcation = await RaffleManagerContract.connect(signer04).participate(raffleId, { value: ticketPrice });
    console.log(`signer04 participate COMPLETED`);
    wait(2500);
  }

  if(signer05Partecipate){
    Transcation = await RaffleManagerContract.connect(signer05).participate(raffleId, { value: ticketPrice });
    console.log(`signer05 participate COMPLETED`);
    wait(2500);
  }

  if(getRaffleInfo){
    Transcation = await RaffleManagerContract.raffles(raffleId);
    console.log(`lotteries[${raffleId}] = [${Transcation}]`);

    Transcation = await RaffleManagerContract.getNumberOfParticipantsInRaffle(raffleId);
    console.log(`getNumberOfParticipantsInRaffle = [${Transcation}]`);

    Transcation = await RandomGeneratorContract.lastRequestId();
    console.log(`lastRequestId = [${Transcation}]`);

    Transcation = await RandomGeneratorContract.getRequestStatus(Transcation);
    console.log(`getRequestStatus = [${Transcation}]`);

    Transcation = await NFTCollectionContract.tokenURI(tokenId);
    console.log(`tokenURI = [${Transcation}]`);

    var url = Transcation;

    fetch(url)
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.text();
      })
      .then(data => {
        console.log("Data from URL:", data);
      })
      .catch(error => {
        console.error("Error fetching data:", error);
      });

  }

  console.log("=== END ===");
}

function wait(ms){
    var start = new Date().getTime();
    var end = start;
    while(end < start + ms) {
      end = new Date().getTime();
   }
  }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory("Staker");
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const waveContract = await waveContractFactory.deploy();
  await waveContract.deployed();
  console.log("Contract deployed to:", waveContract.address);

    let stakeA = await waveContract.stake({value: hre.ethers.utils.parseEther("0.01")})
    await stakeA.wait();
    await setTimeout(() => {
        console.log("5 sec...");
    }, 5000)
    let unStake = waveContract.unStake();
    console.log("Finished");

};

const runMain = async () => {
  try {
    await main();
    process.exit(0); // exit Node process without error
  } catch (error) {
    console.log(error);
    process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
  }
  // Read more about Node exit ('process.exit(num)') status codes here: https://stackoverflow.com/a/47163396/7974948
};

runMain();
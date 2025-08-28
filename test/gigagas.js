const { expect } = require("chai");
const { ethers } = require("hardhat");
const path = require("path");
const fs = require("fs");
const solc = require("solc");

function findImports(importPath) {
  try {
    const resolvedPath = path.join(__dirname, "..", "node_modules", importPath);
    const contents = fs.readFileSync(resolvedPath, "utf8");
    return { contents };
  } catch (e) {
    return { error: "File not found" };
  }
}

function compileContract(fileName, contractName) {
  const contractPath = path.join(__dirname, "..", "contracts", fileName);
  const source = fs.readFileSync(contractPath, "utf8");
  const input = {
    language: "Solidity",
    sources: { [fileName]: { content: source } },
    settings: { outputSelection: { "*": { "*": ["abi", "evm.bytecode"] } } },
  };
  const output = JSON.parse(solc.compile(JSON.stringify(input), { import: findImports }));
  return output.contracts[fileName][contractName];
}

describe("POLStaking", function () {
  it("allows staking and unstaking", async function () {
    const [owner, user] = await ethers.getSigners();
    const vtvArtifact = compileContract("VTV.sol", "VTV");
    const VTVFactory = new ethers.ContractFactory(vtvArtifact.abi, vtvArtifact.evm.bytecode.object, owner);
    const token = await VTVFactory.deploy();
    await token.deployed();

    const stakingArtifact = compileContract("POLStaking.sol", "POLStaking");
    const StakingFactory = new ethers.ContractFactory(stakingArtifact.abi, stakingArtifact.evm.bytecode.object, owner);
    const staking = await StakingFactory.deploy(token.address);
    await staking.deployed();

    await token.transfer(user.address, ethers.utils.parseEther("100"));
    await token.connect(user).approve(staking.address, ethers.utils.parseEther("50"));

    await staking.connect(user).stake(ethers.utils.parseEther("50"));
    const balAfterStake = await staking.balances(user.address);
    expect(balAfterStake.toString()).to.equal(ethers.utils.parseEther("50").toString());

    await staking.connect(user).unstake(ethers.utils.parseEther("20"));
    expect((await staking.balances(user.address)).toString()).to.equal(
      ethers.utils.parseEther("30").toString()
    );
  });
});

describe("AgglayerBridge", function () {
  it("handles deposits and withdrawals", async function () {
    const [owner, user] = await ethers.getSigners();
    const vtvArtifact = compileContract("VTV.sol", "VTV");
    const VTVFactory = new ethers.ContractFactory(vtvArtifact.abi, vtvArtifact.evm.bytecode.object, owner);
    const token = await VTVFactory.deploy();
    await token.deployed();

    const bridgeArtifact = compileContract("AgglayerBridge.sol", "AgglayerBridge");
    const BridgeFactory = new ethers.ContractFactory(bridgeArtifact.abi, bridgeArtifact.evm.bytecode.object, owner);
    const bridge = await BridgeFactory.deploy(token.address);
    await bridge.deployed();

    await token.transfer(user.address, ethers.utils.parseEther("10"));
    await token.connect(user).approve(bridge.address, ethers.utils.parseEther("10"));

    await bridge
      .connect(user)
      .deposit(ethers.utils.parseEther("10"), "polygon-zkevm", user.address);
    await bridge.withdraw(ethers.utils.parseEther("10"));
    expect((await token.balanceOf(bridge.address)).toString()).to.equal("0");
  });
});

describe("BatchProcessor", function () {
  it("executes batched calls", async function () {
    const [owner] = await ethers.getSigners();
    const batchArtifact = compileContract("BatchProcessor.sol", "BatchProcessor");
    const BatchFactory = new ethers.ContractFactory(batchArtifact.abi, batchArtifact.evm.bytecode.object, owner);
    const batch = await BatchFactory.deploy(2);
    await batch.deployed();

    const targetArtifact = compileContract("BatchTarget.sol", "BatchTarget");
    const TargetFactory = new ethers.ContractFactory(targetArtifact.abi, targetArtifact.evm.bytecode.object, owner);
    const target1 = await TargetFactory.deploy();
    const target2 = await TargetFactory.deploy();
    await target1.deployed();
    await target2.deployed();

    const txs = [
      target1.interface.encodeFunctionData("setValue", [1]),
      target2.interface.encodeFunctionData("setValue", [2])
    ];
    const targets = [target1.address, target2.address];

    await batch.executeBatch(targets, txs);
    expect((await target1.value()).toString()).to.equal("1");
    expect((await target2.value()).toString()).to.equal("2");
  });
});

describe("ZkVerifier", function () {
  it("verifies proofs", async function () {
    const [owner] = await ethers.getSigners();
    const verifierArtifact = compileContract("ZkVerifier.sol", "ZkVerifier");
    const VerifierFactory = new ethers.ContractFactory(verifierArtifact.abi, verifierArtifact.evm.bytecode.object, owner);
    const verifier = await VerifierFactory.deploy(owner.address);
    await verifier.deployed();

    const proof = "0x1234";
    const inputs = [ethers.constants.HashZero];
    expect(
      await verifier.callStatic.verifyProof(proof, inputs)
    ).to.equal(true);
  });
});

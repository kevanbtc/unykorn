const chai = require("chai");
const { expect } = chai;
chai.use(require("chai-as-promised").default);
const { ethers } = require("hardhat");
const solc = require("solc");
const fs = require("fs");
const path = require("path");

function compileContracts() {
  const basePath = path.join(__dirname, "..");

  function findImports(importPath) {
    if (importPath.startsWith("@")) {
      const fullPath = path.join(basePath, "node_modules", importPath);
      return { contents: fs.readFileSync(fullPath, "utf8") };
    }
    const fullPath = path.join(basePath, "contracts", importPath);
    return { contents: fs.readFileSync(fullPath, "utf8") };
  }

  const input = {
    language: "Solidity",
    sources: {
      "BondManager.sol": {
        content: fs.readFileSync(path.join(basePath, "contracts", "BondManager.sol"), "utf8"),
      },
    },
    settings: {
      outputSelection: {
        "*": {
          "*": ["abi", "evm.bytecode"],
        },
      },
    },
  };

  const output = JSON.parse(solc.compile(JSON.stringify(input), { import: findImports }));
  const manager = output.contracts["BondManager.sol"]["BondManager"];
  const token = output.contracts["BondToken.sol"]["BondToken"];
  return { manager, token };
}

describe("Bond access control", function () {
  let treasury, other, bondToken, bondManager;

  beforeEach(async function () {
    [treasury, other] = await ethers.getSigners();
    const { manager, token } = compileContracts();

    const BondTokenFactory = new ethers.ContractFactory(token.abi, token.evm.bytecode.object, treasury);
    bondToken = await BondTokenFactory.deploy(treasury.address);
    await bondToken.deployed();

    const BondManagerFactory = new ethers.ContractFactory(manager.abi, manager.evm.bytecode.object, treasury);
    bondManager = await BondManagerFactory.deploy(treasury.address, bondToken.address);
    await bondManager.deployed();
  });

  it("issueBond unauthorized", async function () {
    await expect(bondManager.connect(other).issueBond(other.address, 1)).to.be.rejectedWith("Unauthorized");
  });

  it("redeemBond unauthorized", async function () {
    await expect(bondManager.connect(other).redeemBond(1)).to.be.rejectedWith("Unauthorized");
  });

  it("payCoupon unauthorized", async function () {
    await expect(bondManager.connect(other).payCoupon(other.address, 1)).to.be.rejectedWith("Unauthorized");
  });

  it("BondToken payCoupon unauthorized", async function () {
    await expect(bondToken.connect(other).payCoupon(other.address, 1)).to.be.rejectedWith("Unauthorized");
  });
});


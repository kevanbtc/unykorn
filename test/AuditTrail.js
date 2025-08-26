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

function compileContract() {
  const contractPath = path.join(__dirname, "..", "contracts", "AuditTrail.sol");
  const source = fs.readFileSync(contractPath, "utf8");
  const input = {
    language: "Solidity",
    sources: { "AuditTrail.sol": { content: source } },
    settings: { outputSelection: { "*": { "*": ["abi", "evm.bytecode"] } } },
  };
  const output = JSON.parse(solc.compile(JSON.stringify(input), { import: findImports }));
  return output.contracts["AuditTrail.sol"].AuditTrail;
}

describe("AuditTrail", function () {
  let auditTrail, LOGGER_ROLE, owner, logger, other;

  beforeEach(async function () {
    [owner, logger, other] = await ethers.getSigners();
    const artifact = compileContract();
    const factory = new ethers.ContractFactory(artifact.abi, artifact.evm.bytecode.object, owner);
    auditTrail = await factory.deploy(owner.address);
    await auditTrail.deployed();
    LOGGER_ROLE = await auditTrail.LOGGER_ROLE();
  });

  it("allows addresses with LOGGER_ROLE to log transactions", async function () {
    await auditTrail.grantRole(LOGGER_ROLE, logger.address);
    await auditTrail.connect(logger).logTransaction(other.address, 123);
    const record = await auditTrail.records(0);
    expect(record.user).to.equal(other.address);
    expect(record.amount.toString()).to.equal("123");
  });

  it("reverts when non-authorized address attempts to log", async function () {
    let failed = false;
    try {
      await auditTrail.connect(other).logTransaction(other.address, 1, { gasLimit: 100000 });
    } catch (err) {
      failed = true;
    }
    expect(failed).to.equal(true);
  });
});


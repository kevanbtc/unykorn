// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/POLStaking.sol";
import "../contracts/AgglayerBridge.sol";
import "../contracts/BatchProcessor.sol";
import "../contracts/ZkVerifier.sol";

contract TestToken is ERC20 {
    constructor() ERC20("Test", "TST") {
        _mint(msg.sender, 1e24);
    }
}

contract Target {
    uint256 public value;
    function setValue(uint256 v) external { value = v; }
}

contract GigagasTest is Test {
    TestToken token;
    address user = address(0x1);

    function setUp() public {
        token = new TestToken();
        token.transfer(user, 100 ether);
    }

    function testStakeAndUnstake() public {
        POLStaking staking = new POLStaking(address(token));
        vm.prank(user);
        token.approve(address(staking), 50 ether);
        vm.prank(user);
        staking.stake(50 ether);
        assertEq(staking.balances(user), 50 ether);
        vm.prank(user);
        staking.unstake(20 ether);
        assertEq(staking.balances(user), 30 ether);
    }

    function testBridgeDepositWithdraw() public {
        AgglayerBridge bridge = new AgglayerBridge(address(token));
        vm.prank(user);
        token.approve(address(bridge), 10 ether);
        vm.prank(user);
        bridge.deposit(10 ether, "dest", user);
        bridge.withdraw(10 ether);
        assertEq(token.balanceOf(address(bridge)), 0);
    }

    function testBatchProcessor() public {
        BatchProcessor batch = new BatchProcessor(2);
        Target t1 = new Target();
        Target t2 = new Target();
        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(t1);
        targets[1] = address(t2);
        data[0] = abi.encodeWithSelector(t1.setValue.selector, 1);
        data[1] = abi.encodeWithSelector(t2.setValue.selector, 2);
        batch.executeBatch(targets, data);
        assertEq(t1.value(), 1);
        assertEq(t2.value(), 2);
    }

    function testZkVerifier() public {
        ZkVerifier verifier = new ZkVerifier(address(this));
        bytes memory proof = hex"01";
        bytes32[] memory inputs = new bytes32[](1);
        inputs[0] = bytes32(uint256(1));
        bool valid = verifier.verifyProof(proof, inputs);
        assertTrue(valid);
    }
}

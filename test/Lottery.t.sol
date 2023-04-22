// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import { Test } from "forge-std/Test.sol";
import { Lottery } from "../src/Lottery.sol";
import { ZuzaluOracle } from "../src/ZuzaluOracle.sol";

import { console2 as console } from "forge-std/console2.sol";

contract TestLottery is Test {
  Lottery internal lottery;
  address oracleAddr = address(0x20);
  address alice;
  address bob;

  function setUp() public {
    alice = makeAddr("alice");
    vm.deal(alice, 100 ether);
    bob = makeAddr("bob");
    vm.deal(bob, 100 ether);

    lottery = new Lottery({
      _oracle: ZuzaluOracle(oracleAddr),
      _end: block.timestamp + 1,
      _recipient: bob
    });
  }

  function test_register() public {
    vm.mockCall(
      oracleAddr,
      abi.encodeWithSelector(ZuzaluOracle.verify.selector),
      abi.encode(true)
    );

    assertFalse(lottery.residents(alice));

    vm.prank(alice);
    uint256[8] memory proof = [
      uint256(0),
      uint256(0),
      uint256(0),
      uint256(0),
      uint256(0),
      uint256(0),
      uint256(0),
      uint256(0)
    ];
    lottery.register(1, 0, 0, 0, proof);

    assertTrue(lottery.residents(alice));
  }

  function test_safeMint() external {
    test_register();

    vm.prank(alice);
    lottery.safeMint{ value: 0.1 ether }(alice);

    assertEq(lottery.balanceOf(alice), 1);
    assertEq(lottery.totalSupply(), 1);
    assertEq(lottery.ownerOf(0), alice);
  }

  function test_winners() external {
    test_register();

    for (uint256 i = 0; i < 100; i++) {
      bytes32 random = lottery.random();
      address recipient = address(uint160(uint256(random)));

      vm.prank(alice);
      lottery.safeMint{ value: 0.1 ether }(recipient);

      assertEq(lottery.balanceOf(recipient), 1);
      assertEq(lottery.totalSupply(), i + 1);
      assertEq(lottery.ownerOf(i), recipient);
    }

    address[] memory winners = lottery.winners();
    assertEq(winners.length, 10);
  }

  // TODO
  function test_transfer() external {
    vm.deal(address(lottery), 100 ether);
  }

}

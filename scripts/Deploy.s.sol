// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import {Script} from "forge-std/Script.sol";
import {ZuzaluOracle} from "../src/ZuzaluOracle.sol";
import {SemaphoreVerifier} from "@semaphore-protocol/contracts/base/SemaphoreVerifier.sol";
import {console2 as console} from "forge-std/console2.sol";

bytes32 constant SALT = "Zuzalu #1 2023";
address constant DEPLOYED_VERIFIER= 0x3889927F0B5Eb1a02C6E2C20b39a1Bd4EAd76131;
contract Deploy is Script{

  address $verifier;
  address $owner;

  constructor() {
    if (block.chainid == 5 || block.chainid == 11155111 || block.chainid == 80001 || block.chainid == 10 || block.chainid == 421613){
      $verifier = DEPLOYED_VERIFIER;
      console.log("Verifier is already deployed at address", $verifier);
    } else {
      _deployVerifier();
      console.log("Verifier deployed at address", $verifier);
    }
  }
  function run() public {
    $owner = msg.sender;
    deployOracle();
  }
  
  function run(address _verifier) public {
    $owner = msg.sender;
    $verifier = _verifier;
    deployOracle();
  }

  function _deployVerifier() internal {
    vm.startBroadcast();
    SemaphoreVerifier verifierContract = new SemaphoreVerifier();
    $verifier = address(verifierContract);
    vm.stopBroadcast();
  }

  function deployOracle() internal {
    vm.startBroadcast();
    ZuzaluOracle oracle = new ZuzaluOracle{salt: SALT}({
      _owner: $owner,
      _verifier: $verifier 
    });
    vm.stopBroadcast();
    console.log("Oracle deployed at address", address(oracle));
  }

  function printAddress(uint256 _chainId, address owner) public {
    vm.chainId(_chainId);
    bytes memory args = abi.encode(owner, $verifier);
    bytes32 initCodeHash = hashInitCode(type(ZuzaluOracle).creationCode, args);
    address oracle = computeCreate2Address(SALT, initCodeHash);
    console.log("Create2 Args");
    console.log("> Owner:  ", owner);
    console.log("> Verifier", $verifier);
    console.log("> Salt", vm.toString(SALT));
    console.log("Address");
    console.log("> Oracle: ", oracle);
  }
}

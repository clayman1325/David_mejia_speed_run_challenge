// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  uint256 startTime = block.timestamp;
  bool    public openForWithdraw = false;

  event Stake(address, uint256);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontebalancesnd `All Stakings` tab to display)

  function stake() public payable {
    require(timeLeft() > 0, "you can not stake any more try to withdraw");
    address sender = msg.sender;
    balances[sender] += msg.value;

    // console.log(":" , "................");
    emit Stake(sender, msg.value);
  }
  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() public {
    require(block.timestamp >= deadline, "Staking Time has not finished yet");
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
    openForWithdraw = true;
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public {
    require(balances[msg.sender] > 0, " You do not have anything to withdraw.");
    require(openForWithdraw, "You can not widthraw in the moment.");
    require(address(this).balance < threshold, "The treshhold was meet you can not withdraw");

    uint256 value = balances[msg.sender];

    (bool response, /*bytes data*/) = msg.sender.call{value: value}("");

    require(response, "Failed to send you founds");
    balances[msg.sender] = 0;
  }

  function timeLeft() public view returns (uint256){
    if(block.timestamp < deadline) {
      return deadline - block.timestamp;
    }
    return 0;
  }

  function receive() public {
    stake();
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}

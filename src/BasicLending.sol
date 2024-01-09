// users deposit funds
// users withdraw funds
// users borrow funds
// users repay borrowed funds

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BasicLending {
    address[] users; //a list of users addresses

    mapping(address user => uint256 deposited) userToAmountDeposited; //mapping for users to the amount they deposited

    uint256 public totalBalance; //variable for the total amount of funds in the contract

    address[] borrowers; //a list of borrowers

    mapping(address user => uint256 borrowed) userToAmountBorrowed; //mapping of borrowers to the amount they borrowed

    function deposit() public payable {
        users.push(msg.sender); //adds the address of the depositor into the users list
        userToAmountDeposited[msg.sender] += msg.value; //updates the amount each depositor deposits into the contract
    }

    function withdraw(uint256 amount) external {
        //checks if the user's balance is sufficient for the withdrawal request.
        require(
            amount <= userToAmountDeposited[msg.sender],
            "Insufficient balance in your account!"
        );

        //amount is deducted from the deposit
        userToAmountDeposited[msg.sender] -= amount;

        //amount is then sent to user address
        (bool callSuccess, ) = payable(msg.sender).call{value: amount}("");
        require(callSuccess, "transaction failed");
    }

    function borrow(uint256 amount) public {
        //get total balance in the contract
        totalBalance = 0;
        for (uint256 userIndex = 0; userIndex < users.length; userIndex++) {
            totalBalance =
                totalBalance +
                userToAmountDeposited[users[userIndex]];
        }
        //checks if the amount is less than the amount of funds available in the contract
        require(
            amount <= totalBalance,
            "Insufficient balance in the contract!"
        );

        // amount is sent to the borrower
        (bool callSuccess, ) = payable(msg.sender).call{value: amount}("");
        require(callSuccess, "transcation failed");

        //add the borrower address to borrower's list and updates the debt of the borrowers
        borrowers.push(msg.sender);
        userToAmountBorrowed[msg.sender] += amount;
    }

    function repay() public payable {
        //deducts amount repaid by borrower from amount borrowed
        userToAmountBorrowed[msg.sender] -= msg.value;
    }
}

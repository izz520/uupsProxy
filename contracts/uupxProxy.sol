// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UUPSProxy {
    address public implementation;
    address public admin;
    string public name;
    uint256 public count;

    // 构造函数，初始化admin和逻辑合约地址
    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }

    // fallback函数，将调用委托给逻辑合约
    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(
            msg.data
        );
    }
}

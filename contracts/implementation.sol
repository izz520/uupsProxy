// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract implementation1 {
    address public implementation;
    address public admin;
    string public name;
    uint256 public count;

    function init(string memory _name, uint256 _count) public {
        name = _name;
        count = _count;
        admin = msg.sender;
    }

    function setName(string memory _name) public {
        name = _name;
    }

    function addCount() public {
        count += 1;
    }

    function update(address _newAddress) public {
        require(msg.sender == admin, "must admin");
        implementation = _newAddress;
    }
}

contract implementation2 {
    address public implementation;
    address public admin;
    string public name;
    uint256 public count;

    function init(string memory _name, uint256 _count) public {
        name = _name;
        count = _count;
        admin = msg.sender;
    }

    function setName(string memory _name) public {
        name = _name;
    }

    function addCount() public {
        count += 1;
    }

    function setCount(uint256 _count) public {
        count = _count;
    }

    function update(address _newAddress) public {
        require(msg.sender == admin, "must admin");
        implementation = _newAddress;
    }
}

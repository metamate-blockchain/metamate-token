// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.2;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract MockToken is ERC20 {
  constructor(string memory name, string memory symbol) public ERC20(name, symbol) {
    _mint(msg.sender, 10**50);
  }
}

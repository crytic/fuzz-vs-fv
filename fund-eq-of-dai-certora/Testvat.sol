// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.13;

import "Vat.sol";

contract TestVat is Vat {
    bytes32[] public ilkIds;

    constructor() {
        Line = 1e66;
    }

    function init(bytes32 ilk) public override auth {
        super.init(ilk);
        ilks[ilk].spot = 1e66;
        ilks[ilk].line = 1e66;
        ilkIds.push(ilk);
    }

    function frob(bytes32 i, address u, int256 dink, int256 dart) public {
        frob(i, u, u, u,dink,dart);
    }

    function sumOfDebt() public view returns (uint256) {
        uint256 length = ilkIds.length;
        uint256 sum = 0;
        for (uint256 i=0; i < length; ++i){
            sum = sum + ilks[ilkIds[i]].Art * ilks[ilkIds[i]].rate;
        }
        return sum;
    }

    function echidna_fund_eq() public view returns (bool) {
        return debt == vice + sumOfDebt();
    }
}
// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.13;

import "Vat.sol";

contract TestVat is Vat {
    bytes32[] public ilkIds;

    function init(bytes32 ilk) public override auth {
        super.init(ilk);
        ilkIds.push(ilk);
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
